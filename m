From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
 (v3)
Date: Sun, 10 Jan 2010 22:45:04 -0800 (PST)
Message-ID: <20100110.224504.247142858.davem@davemloft.net>
References: <20100108.160252.189352309.davem@davemloft.net>
	<1263088638.2480.210.camel@localhost>
	<20100110235017.GA8959@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40086
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752027Ab0AKGoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 01:44:55 -0500
In-Reply-To: <20100110235017.GA8959@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 11 Jan 2010 00:50:17 +0100

> Iff the FirstFrag and LastFrag bits can not be set on these packets,
> it should be enough to (1) do the fragmented_frame test sooner and
> return the descriptor to the chipset. Otherwise we can (2) take a
> complete reset on the first suspect packet (whose pattern is more
> specific) to stop the challenger here.
> 
> FWIW, a netratelimited printk of the source mac address may help too.
> 
> I am biased in favor of (2) as:
> - it will not inhibit multi-desc packets
> - the challenger is supposed to be in the LAN and can already hurt
>   quite a lot anyway
> 
> Comments ?

In my opinion if you reset, you give them more power.

Instead of just dropping the next few frames, you allow them
to cause a drop of how ever many RX frames can arrive during
the reset period _PLUS_ the amount of other RX frames which
were in the receive ring at the point of detection.
