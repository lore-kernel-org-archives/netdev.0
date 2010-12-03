From: Junchang Wang <junchangwang@gmail.com>
Subject: Question about __alloc_skb() speedup
Date: Fri, 3 Dec 2010 18:14:52 +0800
Message-ID: <20101203101450.GA9573@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:42862 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746Ab0LCKPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 05:15:09 -0500
Received: by pxi15 with SMTP id 15so1416553pxi.19
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 02:15:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

I'm reading your patch (ec7d2f2cf3a1 __alloc_skb() speedup),
in which you prefetch skb and the shinfo part. I'm very
curious why we don't prefetch skb->data. It seems that will
help tx path a lot.

I added the following code

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 104f844..c60a808 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -222,6 +222,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
 	}
+	prefetchw(data);
+
 out:
 	return skb;
 nodata:

and the pktgen in my server (A Intel SR1625 server with two E5530 
4-core processors and a single ixgbe-based NIC) goes from 7.6Mpps to
8.4Mpps (64 byte), with 10% performance gain.

For rx path, I did experiments on both ixgbe and igb with pktgen+kute,
and there is no change in system performance.

welcome any suggestions and corrections.

Thanks.

--Junchang
