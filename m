From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 14:19:30 +0100
Message-ID: <20080731131929.GO10471@solarflare.com>
References: <20080731101425.GE23814@xi.wantstofly.org> <20080731.031654.44296685.davem@davemloft.net> <20080731122541.GA29176@xi.wantstofly.org> <20080731.053516.185810642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: buytenh@wantstofly.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org,
	dale@farnsworth.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:42910 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751157AbYGaNT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 09:19:58 -0400
Content-Disposition: inline
In-Reply-To: <20080731.053516.185810642.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Lennert Buytenhek <buytenh@wantstofly.org>
> Date: Thu, 31 Jul 2008 14:25:41 +0200
> 
> > At this point things seem to be CPU limited at the sender again.  E.g.
> > by simply dropping IRQF_SAMPLE_RANDOM from mv643xx_eth.c (the driver
> > used on the sender), throughput jumps to ~108 MiB/s, and I get:
>  ...
> > Putting the 5 * mss_now nagle hack back in doesn't seem to change
> > the gso_size distribution anymore at this point, and it doesn't
> > change the numbers much:
>  ...
> > The throughput with software GSO off again seems to be about ~93 MiB/s:
> 
> So I would conclude that at the moment we should just do the software
> GSO enabling thing (with the recent suggestions made by Herbert) and
> for the time being the nagle hack isn't something to consider closely.

You might want to think about providing a way for soft-GSO to generate
more lightweight structures than skbs.  The overhead for skb allocation
becomes quite significant beyond 1 Gbit/s, which is why we added the soft-
TSO implementation in sfc using per-interface pools of header buffers.  I
would guess niu would benefit from this sort of approach, though it looks
like all the other 10G NICs do TSO in hardware/firmware.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
