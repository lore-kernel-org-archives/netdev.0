From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v3 net-next 3/5] net: Add VLAN ID to flow_keys
Date: Tue, 12 May 2015 08:23:00 -0700
Message-ID: <1431444182-3935169-4-git-send-email-tom@herbertland.com>
References: <1431444182-3935169-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:11465 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933009AbbELPXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:23:23 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4CFNNY7004730
	for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:23:23 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1ubgabrdyq-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:23:23 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 d17b4d26f8ba11e4b0490002c9521c9e-ca2db1e0 for <netdev@vger.kernel.org>;	Tue,
 12 May 2015 08:23:19 -0700
In-Reply-To: <1431444182-3935169-1-git-send-email-tom@herbertland.com>
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
index 0a3ad45..312a11a 100644
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
