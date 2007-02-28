From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/5] r8169: more alignment for the 0x8168
Date: Wed, 28 Feb 2007 22:48:39 +0100
Message-ID: <20070228214839.GA23772@electric-eye.fr.zoreil.com>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com> <20061204000327.GE3625@electric-eye.fr.zoreil.com> <45D13578.8040405@snapgear.com> <20070213081439.GA21261@electric-eye.fr.zoreil.com> <Pine.LNX.4.64.0702131730570.14346@cnc.isely.net> <20070223231355.GA10930@electric-eye.fr.zoreil.com> <45E28F63.8000208@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Isely <isely@pobox.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55538 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932486AbXB1VvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 16:51:03 -0500
Content-Disposition: inline
In-Reply-To: <45E28F63.8000208@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the delay, I took some time to check the history of the
r8169 alignment issues.

Philip Craig <philipc@snapgear.com> :
[...]
> This only partially helps.  Many of the packets are greater than 200
> bytes so copybreak doesn't apply to them.

Yes.

> Can we assume anything about the alignment of skb->data?  I think it
> should be 4 byte aligned, otherwise the whole NET_IP_ALIGN thing
> won't work.  All the drivers I looked at just reserve NET_IP_ALIGN
> without checking the alignment first.
> 
> So can you do something like set align to 0 for RTL_CFG_0 and change
> rtl8169_alloc_rx_skb() to:
> 	skb_reserve(skb, align ? (align - 1) & (u32)skb->data : NET_IP_ALIGN);

The "So" part assumes that the 0x8169 can DMA at any address.

/me ponders...

It's easy to debug if it misbehaves now or in 6 months on some obscure
system. It's consistent with the preprevious code. Ok, good idea, I like it.

[...]
> BTW, should the alignment expression be:
> 	(((u32)skb->data + (align - 1)) & ~(align - 1)) - (u32)skb->data

I'll see if something can be hacked with a zero or power of two alignment.

-- 
Ueimor
