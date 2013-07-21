From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] arm: ixp4xx: set cohorent_dma_mask for ethernet
 platform devices
Date: Sun, 21 Jul 2013 17:40:23 +0100
Message-ID: <1374424823.2804.25.camel@deadeye.wl.decadent.org.uk>
References: <1374315339-31469-1-git-send-email-jogo@openwrt.org>
	 <1374315339-31469-2-git-send-email-jogo@openwrt.org>
	 <m3ip04ezty.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jonas Gorski <jogo@openwrt.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	"Imre Kaloz" <kaloz@openwrt.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26390 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755868Ab3GUQk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 12:40:28 -0400
In-Reply-To: <m3ip04ezty.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-07-21 at 16:45 +0200, Krzysztof Halasa wrote:
> Jonas Gorski <jogo@openwrt.org> writes:
> 
> > ARM requires the cohorent_dma_mask set, so set it for the platform
> > devices so that the ethernet driver has access to it.
> 
> I recognize the need to fix this issue and I appreciate your efforts,
> but... I think this patch tries to make the driver functional again at
> all costs and this a very bad idea. The IXP4xx Ethernet MACs are not
> normal platform devices, they are in fact built-in CPU resources.

Sounds like a normal platform device to me...

> The
> platform device structs are only used to set parameters. What the patch
> does is unneeded and IMHO harmful code duplication. It makes completely
> no sense to set DMA masks in code for individual platforms as it's not
> something platforms can decide, or *even should know of*. It's simply
> a CPU attribute, a value that is shared by all IXP4xx CPUs and thus all
> platforms and systems using it.
> 
> This is against the "line of code" count rules (or "rules").
> 
> Also the dev->dev.parent is IMHO a bad idea. The queue numbers and MAC
> addresses are in no way "parents" of Ethernet controllers,

Well, those are the platform data.

> and even if
> they somehow were, I find it rather hard to believe they can have DMA
> masks.

I think the problem is that the platform device and the platform data
have not been properly separated.  The machine-specific setup functions
should be passing the eth_plat_info and MAC ID into a common ixp4xx
function which would then create the platform device with the correct
DMA mask etc.

Ben.

> I think the previous patch (which sets the masks in one place, in
> Ethernet driver code) was better, though not perfect.
> 
> My fault is I haven't fixed it yet. Will try to invent something.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
