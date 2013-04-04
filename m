From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] ixgbe: Mask off check of frag_off as we only want fragment offset
Date: Thu,  4 Apr 2013 04:37:48 -0700
Message-ID: <1365075480-20183-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25690 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757852Ab3DDLiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 07:38:21 -0400
In-Reply-To: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We were incorrectly checking the entire frag_off field when we only wanted the
fragment offset.  As a result we were not pulling in TCP headers when the DNF
flag was set.

To correct that we will now check for frag off using the IP_OFFSET mask.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e56a3d1..5cee5de 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1337,7 +1337,7 @@ static unsigned int ixgbe_get_headlen(unsigned char *data,
 			return hdr.network - data;
 
 		/* record next protocol if header is present */
-		if (!hdr.ipv4->frag_off)
+		if (!(hdr.ipv4->frag_off & htons(IP_OFFSET)))
 			nexthdr = hdr.ipv4->protocol;
 	} else if (protocol == __constant_htons(ETH_P_IPV6)) {
 		if ((hdr.network - data) > (max_len - sizeof(struct ipv6hdr)))
-- 
1.7.11.7
