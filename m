From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 3/4] ipv6: Add gro functions to sit_offloads
Date: Mon, 3 Aug 2015 10:11:17 -0700
Message-ID: <1438621878-1113072-4-git-send-email-tom@herbertland.com>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46559 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755217AbbHCRMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 13:12:01 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t73H98Si024756
	for <netdev@vger.kernel.org>; Mon, 3 Aug 2015 10:12:00 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1w2b7386xx-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 10:12:00 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 bf86f33e3a0211e5bf5924be05956610-dbbfd2b0 for <netdev@vger.kernel.org>;	Mon,
 03 Aug 2015 10:11:58 -0700
In-Reply-To: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For GRO to work with sit we need gro_receive and gro_complete populated
in the sit_offload structure.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_offload.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 08b6204..e893cd1 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -292,6 +292,8 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
 static const struct net_offload sit_offload = {
 	.callbacks = {
 		.gso_segment	= ipv6_gso_segment,
+		.gro_receive	= ipv6_gro_receive,
+		.gro_complete	= ipv6_gro_complete,
 	},
 };
 
-- 
1.8.5.6
