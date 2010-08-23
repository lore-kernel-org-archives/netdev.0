From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tc: add meta match on receive hash
Date: Mon, 23 Aug 2010 13:08:03 -0700
Message-ID: <20100823130803.7736ebfb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51818 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753621Ab0HWUIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 16:08:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial extension to existing meta data match rules to allow
matching on skb receive hash value.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/tc_ematch/tc_em_meta.h	2010-08-22 11:28:09.208550912 -0700
+++ b/include/linux/tc_ematch/tc_em_meta.h	2010-08-22 11:28:20.560321846 -0700
@@ -79,6 +79,7 @@ enum {
  	TCF_META_ID_SK_SENDMSG_OFF,
  	TCF_META_ID_SK_WRITE_PENDING,
 	TCF_META_ID_VLAN_TAG,
+	TCF_META_ID_RXHASH,
 	__TCF_META_ID_MAX
 };
 #define TCF_META_ID_MAX (__TCF_META_ID_MAX - 1)
--- a/net/sched/em_meta.c	2010-08-22 11:23:29.394155391 -0700
+++ b/net/sched/em_meta.c	2010-08-22 11:25:16.088029057 -0700
@@ -223,6 +223,11 @@ META_COLLECTOR(int_maclen)
 	dst->value = skb->mac_len;
 }
 
+META_COLLECTOR(int_rxhash)
+{
+	dst->value = skb->rxhash;
+}
+
 /**************************************************************************
  * Netfilter
  **************************************************************************/
@@ -541,6 +546,7 @@ static struct meta_ops __meta_ops[TCF_ME
 		[META_ID(SK_SENDMSG_OFF)]	= META_FUNC(int_sk_sendmsg_off),
 		[META_ID(SK_WRITE_PENDING)]	= META_FUNC(int_sk_write_pend),
 		[META_ID(VLAN_TAG)]		= META_FUNC(int_vlan_tag),
+		[META_ID(RXHASH)]		= META_FUNC(int_rxhash),
 	}
 };
 
