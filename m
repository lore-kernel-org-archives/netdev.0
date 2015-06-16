From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next] openvswitch: allow output of MPLS packets on tunnel vports
Date: Tue, 16 Jun 2015 09:39:49 +0900
Message-ID: <1434415189-16006-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Simon Horman <simon.horman@netronome.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34638 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbbFPAkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 20:40:24 -0400
Received: by pdbki1 with SMTP id ki1so1566869pdb.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 17:40:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently output of MPLS packets on tunnel vports is not allowed by the
datapath and, moreover, flows that match on MPLS packets and output to
tunnel vports are rejected by the datapath. The flows are rejected
regardless of if they also output to non-tunnel vports which is allowed for
MPLS packets and the following is logged by the kernel.

openvswitch: netlink: Flow actions may not be safe on all matching packets.

This patch addresses the above by allowing output of MPLS packets to tunnel
vports.

My recollection of adding MPLS support to the datapath was that a rather
conservative approach was taken in order to minimise the chance of fallout.
This patch proposes relaxing one restriction which was introduced at that
time.

My limited testing has not isolated any side effects of this change.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/openvswitch/flow_netlink.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 624e41c4267f..a5d3c0ae8ac8 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1847,9 +1847,6 @@ static int validate_set(const struct nlattr *a,
 		break;
 
 	case OVS_KEY_ATTR_TUNNEL:
-		if (eth_p_mpls(eth_type))
-			return -EINVAL;
-
 		if (masked)
 			return -EINVAL; /* Masked tunnel set not supported. */
 
-- 
2.1.4
