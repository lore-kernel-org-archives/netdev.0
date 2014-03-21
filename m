From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Thu, 20 Mar 2014 19:51:51 -0700
Message-ID: <1395370311.9114.121.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cknwk4.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>,
	netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:62811 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759782AbaCUCvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 22:51:53 -0400
Received: by mail-pa0-f42.google.com with SMTP id fb1so1808334pad.15
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 19:51:52 -0700 (PDT)
In-Reply-To: <87a9cknwk4.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-20 at 18:56 -0700, Andi Kleen wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> >
> > I saw csum_partial() consuming 1% of cpu cycles in a GRO workload, that
> > is insane...
> 
> 
> Couldn't it just be the cache miss?

Well, no, because we aggregate frames that were already fully checked
(by GRO engine/layers) in the same NAPI run.

In this particular case, it seems we aggregate few frames per run (its a
40Gb Intel NIC, it apparently is tuned for low latency)
