From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tc: add meta match on receive hash
Date: Tue, 24 Aug 2010 11:14:40 -0700
Message-ID: <20100824111440.37eebae1@nehalam>
References: <20100823130803.7736ebfb@nehalam>
	<AANLkTik3tnSQOXSQWxX+GqcJpjnEyGuWyZhQ9sbPFYAt@mail.gmail.com>
	<20100823.204422.85408087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, tgraf@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45140 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751812Ab0HXSOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 14:14:48 -0400
In-Reply-To: <20100823.204422.85408087.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial extension to existing meta data match rules to allow
matching on skb receive hash value.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This versions uses skb_get_rxhash()

--- a/include/linux/tc_ematch/tc_em_meta.h	2010-08-24 08:35:29.555651482 -0700
+++ b/include/linux/tc_ematch/tc_em_meta.h	2010-08-24 08:36:51.038237590 -0700
@@ -79,6 +79,7 @@ enum {
  	TCF_META_ID_SK_SENDMSG_OFF,
  	TCF_META_ID_SK_WRITE_PENDING,
 	TCF_META_ID_VLAN_TAG,
+	TCF_META_ID_RXHASH,
 	__TCF_META_ID_MAX
 };
 #define TCF_META_ID_MAX (__TCF_META_ID_MAX - 1)
--- a/net/sched/em_meta.c	2010-08-24 08:35:29.535662209 -0700
+++ b/net/sched/em_meta.c	2010-08-24 08:38:07.191510604 -0700
@@ -223,6 +223,11 @@ META_COLLECTOR(int_maclen)
 	dst->value = skb->mac_len;
 }
 
+META_COLLECTOR(int_rxhash)
+{
+	dst->value = skb_get_rxhash(skb);
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
 
