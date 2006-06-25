From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3] [PKT_SCHED]: Add iif meta match
Date: Mon, 26 Jun 2006 00:00:03 +0200
Message-ID: <20060626145516.182347000@postel.suug.ch>
References: <20060626145446.948105000@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:25258 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932365AbWFZO6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 10:58:46 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=iif_meta
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.git/include/linux/tc_ematch/tc_em_meta.h
===================================================================
--- net-2.6.git.orig/include/linux/tc_ematch/tc_em_meta.h
+++ net-2.6.git/include/linux/tc_ematch/tc_em_meta.h
@@ -81,6 +81,7 @@ enum
  	TCF_META_ID_SK_SNDTIMEO,
  	TCF_META_ID_SK_SENDMSG_OFF,
  	TCF_META_ID_SK_WRITE_PENDING,
+	TCF_META_ID_IIF,
 	__TCF_META_ID_MAX
 };
 #define TCF_META_ID_MAX (__TCF_META_ID_MAX - 1)
Index: net-2.6.git/net/sched/em_meta.c
===================================================================
--- net-2.6.git.orig/net/sched/em_meta.c
+++ net-2.6.git/net/sched/em_meta.c
@@ -170,6 +170,11 @@ META_COLLECTOR(var_dev)
 	*err = var_dev(skb->dev, dst);
 }
 
+META_COLLECTOR(int_iif)
+{
+	dst->value = skb->iif;
+}
+
 /**************************************************************************
  * skb attributes
  **************************************************************************/
@@ -525,6 +530,7 @@ static struct meta_ops __meta_ops[TCF_ME
 		[META_ID(SK_SNDTIMEO)]		= META_FUNC(int_sk_sndtimeo),
 		[META_ID(SK_SENDMSG_OFF)]	= META_FUNC(int_sk_sendmsg_off),
 		[META_ID(SK_WRITE_PENDING)]	= META_FUNC(int_sk_write_pend),
+		[META_ID(IIF)]			= META_FUNC(int_iif),
 	}
 };
 

--

