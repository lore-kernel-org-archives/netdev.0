From: Ben Greear <greearb@candelatech.com>
Subject: [iproute2] iproute2:  Fix batch-mode for mrules.
Date: Thu, 15 Jul 2010 15:48:10 -0700
Message-ID: <1279234090-18624-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57154 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934934Ab0GOWsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 18:48:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The do_multirule logic was broken in batch mode because
it expected the preferred_family to be AF_INET or AF_INET6,
but it then assigned it to RTNL_FAMILY_IPMR or RTNL_FAMILY_IP6MR.
So, the next iteration of the batch processing, it failed
the check for AF_INET or AF_INET6.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 9c8c6ef... d3b97e2... M	ip/iprule.c
 ip/iprule.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/ip/iprule.c b/ip/iprule.c
index 9c8c6ef..d3b97e2 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -446,8 +446,12 @@ int do_multirule(int argc, char **argv)
 	case AF_INET6:
 		preferred_family = RTNL_FAMILY_IP6MR;
 		break;
+	case RTNL_FAMILY_IPMR:
+	case RTNL_FAMILY_IP6MR:
+		break;
 	default:
-		fprintf(stderr, "Multicast rules are only supported for IPv4/IPv6\n");
+		fprintf(stderr, "Multicast rules are only supported for IPv4/IPv6, was: %i\n",
+			preferred_family);
 		exit(-1);
 	}
 
-- 
1.6.2.5

