From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 5/10] spidernet: null out skb pointer after its been used.
Date: Tue, 22 May 2007 18:39:01 -0500
Message-ID: <20070522233901.GD2147@austin.ibm.com>
References: <20070522230942.GT5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Florin Malita <fmalita@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:43077 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757066AbXEVXjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 19:39:06 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4MNd5HB028937
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:39:05 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MNd2wG255702
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:39:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MNd15I010508
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:39:02 -0600
Content-Disposition: inline
In-Reply-To: <20070522230942.GT5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


If the ethernet interface is brought down while there is still
RX traffic in flight, the device shutdown routine can end up
trying to double-free an skb, leading to a crash in mm/slab.c
Avoid the double-free by nulling out the skb pointer.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |    1 +
 1 file changed, 1 insertion(+)

Index: netdev-2.6/drivers/net/spider_net.c
===================================================================
--- netdev-2.6.orig/drivers/net/spider_net.c	2007-05-22 18:03:32.000000000 -0500
+++ netdev-2.6/drivers/net/spider_net.c	2007-05-22 18:03:34.000000000 -0500
@@ -1136,6 +1136,7 @@ spider_net_decode_one_descr(struct spide
 
 	/* Ok, we've got a packet in descr */
 	spider_net_pass_skb_up(descr, card);
+	descr->skb = NULL;
 	hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	return 1;
 
