From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: differences in skb allocation in fill_packet_ipv4 and fill_packet_ipv6
Date: Mon, 31 Aug 2009 19:08:12 +0300
Message-ID: <4A9BF56C.3030002@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:12174 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752489AbZHaQIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 12:08:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb is allocated differently in fill_packet_ipv4 and fill_packet_ipv6 (net/core/pktgen.c).


in fill_packet_ipv4():
        datalen = (odev->hard_header_len + 16) & ~0xf;
        skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + datalen +
                        pkt_dev->pkt_overhead, GFP_ATOMIC);


but in fill_packet_ipv6():
        skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + 16 +
                        pkt_dev->pkt_overhead, GFP_ATOMIC);




hard_header_len was first added here in:
    7ac5459ec0f074022818af35c589b9e2b406d7c3
    [PKTGEN]: Respect hard_header_len of device.

A snip from the patch:
-	skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + 16, GFP_ATOMIC);
+	datalen = (odev->hard_header_len + 16) & ~0xf;
+	skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + datalen, GFP_ATOMIC);


This patch only modifies fill_packet_ipv4(). Did someone forget to update
fill_packet_ipv6() as well or was this an ipv4-specific change (and why
would it be so)?

--
 .
..: Lucian
