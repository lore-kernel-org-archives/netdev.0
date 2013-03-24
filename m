From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or
 Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba
 (updated) Version 2
Date: Sun, 24 Mar 2013 10:22:48 -0700
Message-ID: <1364145768.29473.9.camel@edumazet-glaptop>
References: <20130324012625.GA17948@order.stressinduktion.org>
	 <89joa2largv8@mids.svenhartge.de>
	 <20130324014125.GB17948@order.stressinduktion.org>
	 <157393863283F442885425D2C4542856489E7C79@nasanexd02f.na.qualcomm.com>
	 <20130324034037.GC17948@order.stressinduktion.org>
	 <157393863283F442885425D2C4542856489E7CA8@nasanexd02f.na.qualcomm.com>
	 <20130324043738.GD17948@order.stressinduktion.org>
	 <157393863283F442885425D2C4542856489E7CCD@nasanexd02f.na.qualcomm.com>
	 <20130324051325.GE17948@order.stressinduktion.org>
	 <157393863283F442885425D2C4542856489E7CFC@nasanexd02f.na.qualcomm.com>
	 <20130324052300.GA12968@order.stressinduktion.org>
	 <157393863283F442885425D2C4542856489E7D1E@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:42890 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754112Ab3CXRWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 13:22:51 -0400
Received: by mail-pd0-f177.google.com with SMTP id y14so2186077pdi.22
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 10:22:51 -0700 (PDT)
In-Reply-To: <157393863283F442885425D2C4542856489E7D1E@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-24 at 05:42 +0000, Huang, Xiong wrote:

> 1.  pages cross 4GB bouandary ?  or overlap with each other ?

Normally this should not happen.

However the frame could span two 4K pages.

(physically contigous, and not spanning a 32K boundary)

> 2. try to set hw->dmaw_block = atl1e_dma_req_128 
> 3. can you print reg15C0 content when the NIC is in normal tx/rx status ?
> 4. other possible may be related the diff register configuration, but it's very difficult to compare with Windows driver :(  
> 

What could be tried is to remove the possibility of page spanning.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 441f5bf..d0f4dd1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1849,7 +1849,7 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 		kfree_skb(skb);
 }
 
-#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
+#define NETDEV_FRAG_PAGE_MAX_ORDER 0
 #define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)
 #define NETDEV_PAGECNT_MAX_BIAS	   NETDEV_FRAG_PAGE_MAX_SIZE
 
