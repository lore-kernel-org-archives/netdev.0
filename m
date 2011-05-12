From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 15/15] ehea: Remove unused tcp_end field in send WQ
Date: Thu, 12 May 2011 10:52:28 +1000
Message-ID: <20110512005623.854973618@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37047 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755347Ab1ELB17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:27:59 -0400
Content-Disposition: inline; filename=ehea_22.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tcp_end field is not actually used by the hardware, so there
is no need to set it. 

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:48:05.100361788 +1000
+++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:48:06.380382084 +1000
@@ -1995,7 +1995,6 @@ static void xmit_common(struct sk_buff *
 
 		swqe->tcp_offset = swqe->ip_end + 1 +
 				   offsetof(struct udphdr, check);
-		swqe->tcp_end = skb->len - 1;
 		break;
 
 	case IPPROTO_TCP:
@@ -2004,7 +2003,6 @@ static void xmit_common(struct sk_buff *
 
 		swqe->tcp_offset = swqe->ip_end + 1 +
 				   offsetof(struct tcphdr, check);
-		swqe->tcp_end = skb->len - 1;
 		break;
 	}
 }
Index: linux-net/drivers/net/ehea/ehea_qmr.h
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_qmr.h	2011-05-12 07:47:05.399415238 +1000
+++ linux-net/drivers/net/ehea/ehea_qmr.h	2011-05-12 07:48:06.380382084 +1000
@@ -106,7 +106,7 @@ struct ehea_swqe {
 	u8 immediate_data_length;
 	u8 tcp_offset;
 	u8 reserved2;
-	u16 tcp_end;
+	u16 reserved2b;
 	u8 wrap_tag;
 	u8 descriptors;		/* number of valid descriptors in WQE */
 	u16 reserved3;


