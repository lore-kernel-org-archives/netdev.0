From: Li Yu <raise.sail@gmail.com>
Subject: A GRO question
Date: Tue, 05 Jul 2011 13:41:00 +0800
Message-ID: <4E12A3EC.7010803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37961 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220Ab1GEFlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 01:41:14 -0400
Received: by iyb12 with SMTP id 12so4926935iyb.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 22:41:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

	I have a question about GRO implementation, this indeed confuses me.

	I found that we assume that NAPI_GRO_CB(skb)->frag0 starts 
with a mac/L2 header in compare_ether_header(), which is called in
__napi_gro_receive()

	However, in further dev_gro_receive() -> ptype->gro_receive [inet_gro_receive],
we use same address as IPv4/L3 header, like below:

        off = skb_gro_offset(skb); //it should keep zero until now, in my words.
        hlen = off + sizeof(*iph);      
        iph = skb_gro_header_fast(skb, off);  //just return NAPI_GRO_CB(skb)->frag0 + 0

	So we forget that updating NAPI_GRO_CB(skb)->data_offset here, or I miss sth?

	And, in my understanding against igb source code, if rx_ring->rx_buffer_len < 1024 
(if we used large MTU), then igb driver use header split mode, in such case, the mac header
should be saved in skb->data : skb_put(skb, igb_get_hlen(rx_ring, rx_desc)), the rest data
is loaded by below skb_fill_page_desc() call. so NAPI_GRO_CB(skb)->frag0 should start with
L3 header. 

	Thanks.

Yu
