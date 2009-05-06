From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: bond + tc regression ?
Date: Wed, 6 May 2009 13:49:29 +0300
Message-ID: <200905061349.29805.denys@visp.net.lb>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <20090506102845.GA24920@francoudi.com> <4A016955.6030901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Vladimir Ivashchenko <hazard@francoudi.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:52907 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755955AbZEFKth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 06:49:37 -0400
In-Reply-To: <4A016955.6030901@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 May 2009 13:41:25 Eric Dumazet wrote:
> You must do for example (to bind on CPU 0)
>
> echo 1 >/proc/irq/default_smp_affinity
>
> ifconfig eth1 down
> # IRQ of eth1 handled by CPU0 only
> echo 1 >/proc/irq/34/smp_affinity
> ifconfig eth1 up
>
> ifconfig eth0 down
> # IRQ of eth0 handled by CPU0 only
> echo 1 >/proc/irq/36/smp_affinity
> ifconfig eth0 up
I think better to use some method over ethtool, that will cause reset.
WHen you do down - you will loose default route, beware of that
>
>
> One thing to consider too is the BIOS option you might have, labeled
> "Adjacent Sector Prefetch"
>
> This basically tells your cpu to use 128 bytes cache lines, instead of 64
>
> In your forwarding worload, I believe this extra prefetch can slowdown your
> machine.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


