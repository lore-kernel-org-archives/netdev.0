From: David Miller <davem@davemloft.net>
Subject: Re: KS8851: Possible NULL dereferenced in ks8851_rx_pkts
Date: Tue, 13 Apr 2010 01:28:44 -0700 (PDT)
Message-ID: <20100413.012844.26960227.davem@davemloft.net>
References: <z2ocb8016981004080003h7f5ca358r7a1a4106809909ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: abraham.arce.moreno@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38243
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751307Ab0DMI2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:28:40 -0400
In-Reply-To: <z2ocb8016981004080003h7f5ca358r7a1a4106809909ce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Abraham Arce <abraham.arce.moreno@gmail.com>
Date: Thu, 8 Apr 2010 02:03:57 -0500

> Hi,
> 
> These changes avoid a possible dereference in skb_reserve when skb is
> NULL. I am increasing rx dropped packet count but not sure about how
> to handle the dump of frames. Any advice is appreciated.

This isn't sufficient to handle the NULL pointer.

At a minimum you're going to have to do something about
the fact that the chip has already been told to start
bringing the packet into the RX fifo.

If we just return without finishing up the hardware
operation, the chip is probably going to hang the next
time we come in here and tell it to start another RX
DMA operation without having completed the previous one.

The bug definitely needs to be fixed, however, but someone who knows
this hardware and has access to it for testing will need to implement
the fix.
