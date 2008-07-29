From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Tue, 29 Jul 2008 21:10:44 +0300
Message-ID: <200807292110.45320.opurdila@ixiacom.com>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com> <200807291911.10364.opurdila@ixiacom.com> <200807291930.20033.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick Ohly <patrick.ohly@intel.com>, netdev@vger.kernel.org
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:6101 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754624AbYG2SNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 14:13:20 -0400
In-Reply-To: <200807291930.20033.netdev@axxeo.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 29 July 2008, Ingo Oeser wrote:
> Hi Octavian,
>

Hi Ingo,

> Just convert your hardware specific cookie you have into the nanoseconds
> resolution timstamp in skb->tstamp just before calling netif_rx()
> or net_receive_skb().
>
> These functions will not touch it, as long as they never see a ZERO
> value there. A ZERO value in tstamp.tv64 means, we have no timestamp.
>
> The difference to CPU clock doesn't matter.
> That compensation can be done by your driver or application at will.
> For mainline, compensation in driver might be preferred.
>
> As long as it is montonic increasing and related to time in any way,
> you could put anything there, I think :-)
>

In here:

net/netfilter/xt_time.c

it seems that the skb->tstamp needs to be CPU time. 

Frankly I don't care about that, but the tstamp is also used in other places 
like the IP and TCP code paths and I can't say that I barely understand that 
part :) 

But if it is ok to use any kind of monotonic increasing timestamp, that will 
solve my problem, indeed.

Thanks,
tavi
