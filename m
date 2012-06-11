From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: kernel ipsec error
Date: Mon, 11 Jun 2012 18:49:23 +0100
Message-ID: <1339436963.2665.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <DUB108-W3906ACEA67D9618490CB02B2F70@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21878 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750738Ab2FKRt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 13:49:29 -0400
In-Reply-To: <DUB108-W3906ACEA67D9618490CB02B2F70@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-11 at 14:45 +0200, Marco Berizzi wrote:
> Hello everybody.
> 
> After 12 days uptime I got this message.
> Linux is 3.3.5 32bit, running openswan
> (this is an ipsec gateway/netfilter
> firewall) and squid.
> 
> Jun 11 12:53:02 Pleiadi kernel: SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Jun 11 12:53:02 Pleiadi kernel:   cache: kmalloc-2048, object size: 2048, buffer size: 2048, default order: 2, min order: 0
> Jun 11 12:53:02 Pleiadi kernel:   node 0: slabs: 61, objs: 476, free: 0
> Jun 11 12:53:02 Pleiadi kernel: kworker/0:2: page allocation failure: order:0, mode:0x4020

So a single page allocation in atomic (non-sleeping) context failed.

[...]
> Jun 11 12:53:02 Pleiadi kernel: Free swap  = 130908kB
> Jun 11 12:53:02 Pleiadi kernel: Total swap = 151164kB
> Jun 11 12:53:02 Pleiadi kernel: 40944 pages RAM
[...]

Not too surprising with this little RAM available (swap didn't help
since we couldn't wait for swap-out).

There could be a memory leak, but you would need to read /proc/meminfo
and /proc/slabinfo at intervals to work out whether that was the case.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
