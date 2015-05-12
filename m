From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 3/5] net: Add VLAN ID to flow_keys
Date: Mon, 11 May 2015 20:26:42 -0700
Message-ID: <1431401204-731380-4-git-send-email-tom@herbertland.com>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58766 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752415AbbELD1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 23:27:52 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4C3Oruh009037
	for <netdev@vger.kernel.org>; Mon, 11 May 2015 20:27:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1ub428gh62-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 11 May 2015 20:27:51 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 ddda056cf85611e4bf310002c9521c9e-cbade1e0 for <netdev@vger.kernel.org>;	Mon,
 11 May 2015 20:27:50 -0700
In-Reply-To: <1431401204-731380-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flow_dissector set vlan_id in flow_keys when VLAN is found.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_keys.h   | 1 +
 net/core/flow_dissector.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index c8bc6aa..14298e2 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -26,6 +26,7 @@ struct flow_keys {
 	__be16	n_proto;
 	u8	ip_proto;
 	u8	padding;
+	u32	vlan_id:12;
 
 	union {
 		__be32 ports;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 69fbaf9..148b989 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -143,6 +143,7 @@ ipv6:
 		if (!vlan)
 			return false;
 
+		flow->vlan_id = skb_vlan_tag_get_id(skb);
 		proto = vlan->h_vlan_encapsulated_proto;
 		nhoff += sizeof(*vlan);
 		goto again;
-- 
1.8.1
