From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/6] [NET] dsa: add support for original DSA tagging
	format
Date: Fri, 03 Oct 2008 18:25:59 +0100
Message-ID: <1223054759.3984.76.camel@achroite>
References: <20080929023829.GI21560@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Tim Ellis <tim.ellis@mac.com>,
	Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>, Nicolas Pitre <nico@cam.org>,
	Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:40438 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753014AbYJCR0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 13:26:24 -0400
In-Reply-To: <20080929023829.GI21560@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-09-29 at 04:38 +0200, Lennert Buytenhek wrote:
> Most of the DSA switches currently in the field do not support the
> Ethertype DSA tagging format that one of the previous patches added
> support for, but only the original DSA tagging format.
> 
> The original DSA tagging format carries the same information as the
> Ethertype DSA tagging format, but with the difference that it does not
> have an ethertype field.  In other words, when receiving a packet that
> is tagged with an original DSA tag, there is no way of telling in
> eth_type_trans() that this packet is in fact a DSA-tagged packet.
> 
> This patch adds a hook into eth_type_trans() which is only compiled in
> if support for a switch chip that doesn't support Ethertype DSA is
> selected, and which checks whether there is a DSA switch driver
> instance attached to this network device which uses the old tag format.
> If so, it sets the protocol field to ETH_P_DSA without looking at the
> packet, so that the packet ends up in the right place.
[...]

Why should this go in eth_type_trans()?  Why don't you put the hook into
the specific network driver(s) that need it?

For that matter, why should dsa_ptr go in struct net_device and not in
the private state for the specific network drivers that need it?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

