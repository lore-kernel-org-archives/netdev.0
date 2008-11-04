From: Johann Baudy <johaahn@gmail.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 04 Nov 2008 23:45:43 +0100
Message-ID: <1225838743.6116.20.camel@fry>
References: <1225450706.5301.94.camel@localhost>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g19.free.fr ([212.27.42.27]:41511 "EHLO smtp1-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754042AbYKDWpr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 17:45:47 -0500
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali,

> Here's the code I came up with to determine the offset - anyone see any problems?
> 
> union {
>    tpacket2_hdr *t2;
>    u8 *raw;
> }
> 
> struct page *first_frag;
> u32 page_offset;
> 
> first_frag = skb_shinfo(skb)->frags[0].page;
> page_offset = skb_shinfo(skb)->frags[0].page_offset;
> 
> page_offset -= (skb_headlen(skb) + sizeof(struct tpacket2_hdr));
> if (unlikely(page_offset < 0)) {
> 	first_frag--;
> 	page_offset += PAGE_SIZE;
> }
> frame.raw = page_address(first_frag) + page_offset;
> 

This won't work if your network card doesn't support Scatter/Gather IO.
Indeed, when SG is not supported, fragmented packets are linearized
after dev_queue_xmit() call. Thus addresses of pages are then lost.

Best regards,
Johann

