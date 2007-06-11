From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 1/15] spidernet: null out skb pointer after its been used.
Date: Mon, 11 Jun 2007 13:17:02 -0500
Message-ID: <20070611181702.GA13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:41164 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbXFKSRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:17:04 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BIH4WJ011876
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:17:04 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BIH37b126488
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:17:03 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BIH2jm002138
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:17:03 -0600
Content-Disposition: inline
In-Reply-To: <20070611181429.GA4397@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Avoid kernel crash in mm/slab.c due to double-free of pointer.

If the ethernet interface is brought down while there is still
RX traffic in flight, the device shutdown routine can end up
trying to double-free an skb, leading to a crash in mm/slab.c
Avoid the double-free by nulling out the skb pointer.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-08 15:45:33.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-08 15:48:10.000000000 -0500
@@ -1131,6 +1131,7 @@ spider_net_decode_one_descr(struct spide
 
 	/* Ok, we've got a packet in descr */
 	spider_net_pass_skb_up(descr, card);
+	descr->skb = NULL;
 	hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	return 1;
 
