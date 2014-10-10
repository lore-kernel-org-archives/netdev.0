From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 14:22:55 -0400 (EDT)
Message-ID: <20141010.142255.359367991309840826.davem@davemloft.net>
References: <20141010.135851.1743803688676076555.davem@davemloft.net>
	<54381F1C.2030800@gmail.com>
	<20141010.141559.2024576018585843684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, eric.dumazet@gmail.com,
	David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbaJJSW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 14:22:58 -0400
In-Reply-To: <20141010.141559.2024576018585843684.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 10 Oct 2014 14:15:59 -0400 (EDT)

> Your original code works because you do things like "byte[12] & 0xf0" to
> extract these fields.

Changing that th->doff sequence to instead be:

		const u8 *bp;
		u8 buf[13];

		bp = __skb_header_pointer(skb, poff, sizeof(buf),
					  data, hlen, &buf);
		if (!bp)
			return poff;

		poff += max_t(u32, sizeof(struct tcphdr), (bp[12] & 0xf0) >> 2);
		break;

on top of your v3 patch works for me.

Please double-check my calculations.
