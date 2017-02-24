From: David Forster <dforster@brocade.com>
Subject: [PATCH] vti6: return GRE_KEY for vti6
Date: Fri, 24 Feb 2017 14:20:32 +0000
Message-ID: <1487946032-5866-1-git-send-email-dforster@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:58732 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751314AbdBXPHq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 10:07:46 -0500
Received: from pps.filterd (m0000542.ppops.net [127.0.0.1])
        by mx0a-000f0801.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1OELTD5008856
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 06:23:57 -0800
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
        by mx0a-000f0801.pphosted.com with ESMTP id 28sctfh4uf-4
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 06:23:57 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Align vti6 with vti by returning GRE_KEY flag. This enables iproute2
to display tunnel keys on "ip -6 tunnel show"

Signed-off-by: David Forster <dforster@brocade.com>
---
 net/ipv6/ip6_vti.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index c795fee..644ba59 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -693,6 +693,10 @@ vti6_parm_to_user(struct ip6_tnl_parm2 *u, const struct __ip6_tnl_parm *p)
 	u->link = p->link;
 	u->i_key = p->i_key;
 	u->o_key = p->o_key;
+	if (u->i_key)
+		u->i_flags |= GRE_KEY;
+	if (u->o_key)
+		u->o_flags |= GRE_KEY;
 	u->proto = p->proto;
 
 	memcpy(u->name, p->name, sizeof(u->name));
-- 
2.1.4
