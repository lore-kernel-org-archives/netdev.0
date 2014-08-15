From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Fri, 15 Aug 2014 10:59:24 -0700
Message-ID: <1408125564.6804.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ECFDAB.5010701@intel.com>
		<1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
		<53ED4354.9090904@intel.com>
	 <20140814.162024.2218312002979492106.davem@davemloft.net>
	 <53EE4023.6080902@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36778 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbaHOR70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 13:59:26 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so3874101pad.11
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 10:59:25 -0700 (PDT)
In-Reply-To: <53EE4023.6080902@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-08-15 at 10:15 -0700, Alexander Duyck wrote:

> I realize most of my data is anecdotal as I only have the ixgbe/igb
> adapters and netperf to work with.  This is one of the reasons why I
> keep asking if someone can tell me what the use case is for this where
> it performs well.  From what I can tell it might have had some value
> back in the day before the introduction of things such as RPS/RFS where
> some of the socket processing would be offloaded to other CPUs for a
> single queue device, but even that use case is now deprecated since
> RPS/RFS are there and function better than this.  What I am basically
> looking for is a way to weight the gain versus the penalties to
> determine if this code is even viable anymore.
> 
> In the meantime I think I will put together a patch to default
> tcp_low_latency to 1 for net and stable, and if we cannot find a good
> reason for keeping it then I can submit a patch to net-next that will
> strip it out since I don't see any benefit to having this code.

prequeue is useful on low end hosts, because it allows an application to
delay ACK packets if it is slow. You get a nicer TCP behavior, because
its more tied to scheduling glitches. Especially if TCP windows are not
autotuned. I guess some embedded platforms benefit from this.

I would keep it the way it is, because modern high performance
applications do not trigger prequeue anyway.

It is trivial to add into netperf a poll() before recvmsg() to avoid the
prequeue, or start your benchmarks with appropriate sysctl.

It is certainly not a 'stable' candidate change, it has been there for
years.

Note that we have include/linux/percpu-refcount.h now, we might
autodetect some dst are heavily used by different cpus and switch to a
percpu refcount.
