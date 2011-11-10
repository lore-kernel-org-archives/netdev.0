From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: more driver shutdown WoL regression.
Date: Thu, 10 Nov 2011 11:41:17 +0100
Message-ID: <20111110104117.GA23906@electric-eye.fr.zoreil.com>
References: <20111108223502.GA20437@electric-eye.fr.zoreil.com> <E6A5E7482020466E82FD141C8CD92D9A@realtek.com.tw> <20111109222556.GA8226@electric-eye.fr.zoreil.com> <DCB55CA56A5546B4B7350912D30EC679@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "'Stefan Becker'" <chemobejk@gmail.com>,
	"'David Miller'" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49983 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932396Ab1KJKqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 05:46:13 -0500
Content-Disposition: inline
In-Reply-To: <DCB55CA56A5546B4B7350912D30EC679@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> I find that the magic packet which I send is the broadcast packet, and the one
> which you send is the unicast packet. That is, you could wake up the system by
> using broadcast magic packet for the previous chips without the patch. However,
> if you prefer to unicast magic packet, this patch is necessary. Besides, no
> matter broadcast or unicast magic packet, the patch is necessary for 8105,
> 8168e, and later chips.

Ok, it makes some sense now.

I am inclined to enable a broad understanding of ethtool WAKE_MAGIC
feature as AMD's magic packet white paper does not limit it to
broadcast packets and explicitely quotes unicast and multicast.
Ben (and others), any opinion ?

Hayes, should I consider similar cross-behaviors between RxConfig and WoL
ConfigX bits with different configurations ?

I.e., assuming Config5.UWF is active and Config3.MagicPacket is not, can
RxConfig.AcceptMyPhys make a difference to the WoL function ?

> Further, it may be dangerous to enable both rx_enable (ChipCmd bit 3) and
> RxConfig for 8168b for WOL, because the hw would try to write the rx buffer.

Ok.

-- 
Ueimor
