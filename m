From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 29 Jan 2010 17:20:20 +0530
Message-ID: <OF86A1176E.28B1CB96-ON652576BA.003FC2E2-652576BA.003FEDE3@in.ibm.com>
References: <20100121.012520.254679483.davem@davemloft.net> <20100121094157.GA15262@gondor.apana.org.au> <OF7EA723DA.DC2FF4FC-ON652576B8.002064CB-652576B8.00267739@in.ibm.com> <20100129090625.GD23140@gondor.apana.org.au> <OFA813CB35.7FC6144E-ON652576BA.003C3B2C-652576BA.003CB215@in.ibm.com> <20100129113346.GB1309@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:39644 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756735Ab0A2LiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 06:38:23 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp05.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0TBcKjm020344
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 17:08:20 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0TBcKpA2658330
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 17:08:20 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0TBcJbV003154
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 17:08:20 +0530
In-Reply-To: <20100129113346.GB1309@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote on 01/29/2010 05:03:46 PM:
>
> > Same 5 runs of single netperf's:
> >
> > 0. Driver unsets F_SG but sets F_GSO:
> >         Org (16K):      BW: 18180.71    SD: 13.485
> >         New (16K):      BW: 18113.15    SD: 13.551
> >         Org (64K):      BW: 21980.28    SD: 10.306
> >         New (64K):      BW: 21386.59    SD: 10.447
> >
> > 1. Driver unsets F_SG, and with GSO off
> >         Org (16K):      BW: 10894.62    SD: 26.591
> >         New (16K):      BW: 7262.10     SD: 35.340
> >         Org (64K):      BW: 12396.41    SD: 23.357
> >         New (64K):      BW: 7853.02     SD: 32.405
> >
> >
> > 2. Driver unsets F_SG and uses ethtool to set GSO:
> >         Org (16K):      BW: 18094.11    SD: 13.603
> >         New (16K):      BW: 17952.38    SD: 13.743
> >         Org (64K):      BW: 21540.78    SD: 10.771
> >         New (64K):      BW: 21818.35    SD: 10.598
>
> Hmm, any idea what is causing case 0 to be different from case 2?
> In particular, the 64K performance in case 0 appears to be a
> regression but in case 2 it's showing up as an improvement.
>
> AFAICS these two cases should produce identical results, or is
> this just jitter across tests?

You are right about the jitter. I have run this many times, most
of the times #0 and #2 are almost identical, but sometimes varies
a bit.

Also about my earlier ethtool comment:

> Yes, an ethtool bug (version 6). The test case #1 above, I
> have written that GSO is off but ethtool "thinks" it is on
> (after a modprobe -r cxgb3; modprobe cxgb3). So for test #2,
> I simply run "ethtool ... gso on", and GSO is now really on
> in the kernel, explaining the better results.

Hmmm, I had a bad ethtool it seems. I built the latest one to
debug this problem but this shows settings correctly.

thanks,

- KK

