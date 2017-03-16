From: Kris Murphy <kriskend@linux.vnet.ibm.com>
Subject: [PATCH 1/1] openvswitch: Add missing case OVS_TUNNEL_KEY_ATTR_PAD
Date: Thu, 16 Mar 2017 10:26:03 -0500
Message-ID: <1b8ba07efdee3db310d4504462924565684ebd64.1489677257.git.kriskend@linux.vnet.ibm.com>
References: <cover.1489677257.git.kriskend@linux.vnet.ibm.com>
Cc: seroyer@linux.vnet.ibm.com, adreznec@linux.vnet.ibm.com,
        Kris Murphy <kriskend@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:42440 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752029AbdCPP0X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 11:26:23 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2GFDwYP064970
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 11:26:20 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
        by mx0a-001b2d01.pphosted.com with ESMTP id 297u87pe5k-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 11:26:20 -0400
Received: from localhost
        by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <kriskend@linux.vnet.ibm.com>;
        Thu, 16 Mar 2017 11:26:18 -0400
In-Reply-To: <cover.1489677257.git.kriskend@linux.vnet.ibm.com>
In-Reply-To: <cover.1489677257.git.kriskend@linux.vnet.ibm.com>
References: <cover.1489677257.git.kriskend@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added a case for OVS_TUNNEL_KEY_ATTR_PAD to the switch statement
in ip_tun_from_nlattr in order to prevent the default case
returning an error.

Fixes: b46f6ded906e ("libnl: nla_put_be64(): align on a 64-bit area")
Signed-off-by: Kris Murphy <kriskend@linux.vnet.ibm.com>
---
 net/openvswitch/flow_netlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 6f5fa50..1e75fec 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -665,6 +665,8 @@ static int ip_tun_from_nlattr(const struct nlattr *attr,
 			tun_flags |= TUNNEL_VXLAN_OPT;
 			opts_type = type;
 			break;
+                case OVS_TUNNEL_KEY_ATTR_PAD:
+                        break;
 		default:
 			OVS_NLERR(log, "Unknown IP tunnel attribute %d",
 				  type);
-- 
2.7.4
