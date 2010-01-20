From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Wed, 20 Jan 2010 17:49:18 +0530
Message-ID: <OF0A3AFFAB.FFA8088C-ON652576B1.001D7B08-652576B1.0042980B@in.ibm.com>
References: <20100115.003636.199394610.davem@davemloft.net>	<OF1B0853DD.2824263E-ON652576AC.002FA9D4-652576AC.0030AC47@LocalDomain>
	<OF0D3FEC3A.84663D58-ON652576AC.0031CA59-652576AC.003232CF@in.ibm.com> <20100115.011829.03057807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: eric.dumazet@gmail.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:55462 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477Ab0ATMH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 07:07:28 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0KC7Pow013815
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 17:37:25 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0KC7PcL688336
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 17:37:25 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0KC7PhO020299
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 23:07:25 +1100
In-Reply-To: <20100115.011829.03057807.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> David Miller <davem@davemloft.net> wrote on 01/15/2010 02:48:29 PM:
>
> Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
>
> From: Krishna Kumar2 <krkumar2@in.ibm.com>
> Date: Fri, 15 Jan 2010 14:50:04 +0530
>
> > I wonder if there is some other way to test it. I could test it on
> > the card I have, cxgbe, by ethtool F_SG off, and then testing
> > this patch with existing code (both with ethtool F_SG off)? Will
> > that be enough to get an idea, or I cannot assume this is
> > reasonable for real non-sg drivers? I am sure there is a
> > degradation, and mentioned that part as a "penalty" for those
> > drivers in my patch.
>
> I think such a test would provide useful data by which to judge this
> change.

I had to remove the F_SG flag from cxgb3 driver (using ethtool
didn't show any difference in performance since GSO was enabled
on the device due to register_netdev setting it). Testing show a
drop of 25% in performance with this patch for non-SG device,
the extra alloc/memcpy is showing up.

For the SG driver, I get a good performace gain (not anywhere
close to 25% though). What do you suggest?

Thanks,

- KK

