From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 10:40:10 -0800
Message-ID: <1454092810.7627.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160129180651.GA17127@oracle.com>
	 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35790 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932552AbcA2SkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 13:40:12 -0500
Received: by mail-pf0-f182.google.com with SMTP id 65so46151229pfd.2
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 10:40:12 -0800 (PST)
In-Reply-To: <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 10:33 -0800, Eric Dumazet wrote:

> 
> Why ipv6 stack itself does not trigger the issue ?
> 
> Maybe the driver itself does not properly align IP headers on sparc ?
> 
> Make sure NET_IP_ALIGN is 2 on your build.
> 
> Note that x86 does not care, but a driver should always align Ethernet
> header to NET_IP_ALIGN, so that IP headers are aligned to 4 bytes
> boundaries.
> 

I would try following ixgbe fix (sorry, totally untested, but you get
the idea...)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c4003a88bbf6..7ba64ed463a6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1525,7 +1525,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 
 	bi->dma = dma;
 	bi->page = page;
-	bi->page_offset = 0;
+	bi->page_offset = NET_IP_ALIGN;
 
 	return true;
 }
