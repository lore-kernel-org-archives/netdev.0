From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] rtnetlink: Fix VF IFLA policy
Date: Wed, 29 Feb 2012 23:33:08 -0800
Message-ID: <1330587188-28717-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330587188-28717-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59707 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758405Ab2CAHdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 02:33:19 -0500
In-Reply-To: <1330587188-28717-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add VF spoof check to IFLA policy.  The original patch I submitted to
add the spoof checking feature to rtnl failed to add the proper policy
rule that identifies the data type and len.  This patch corrects that
oversight.  No bugs have been reported against this but it may cause
some problem for the netlink message parsing that uses the policy
table.

CC: stable@vger.kernel.org
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/core/rtnetlink.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5cf39cd..2be1018 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1132,6 +1132,8 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 				    .len = sizeof(struct ifla_vf_vlan) },
 	[IFLA_VF_TX_RATE]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct ifla_vf_tx_rate) },
+	[IFLA_VF_SPOOFCHK]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_vf_spoofchk) },
 };
 
 static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
-- 
1.7.7.6
