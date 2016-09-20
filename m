From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next V2] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Tue, 20 Sep 2016 14:57:37 -0400
Message-ID: <20160920185737.GU8920@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sowmini.varadhan@oracle.com, jbenc@redhat.com, davem@davemloft.net,
        hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18934 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932189AbcITS57 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 14:57:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vxlan header may not be aligned to 4 bytes in
vxlan_build_skb (e.g., for MLD packets). This patch
avoids unaligned access traps from vxlan_build_skb
(in platforms like sparc) by making struct vxlanhdr __packed.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 include/net/vxlan.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 0255613..1ec56f4 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -18,7 +18,7 @@
 struct vxlanhdr {
 	__be32 vx_flags;
 	__be32 vx_vni;
-};
+} __packed;
 
 /* VXLAN header flags. */
 #define VXLAN_HF_VNI	cpu_to_be32(BIT(27))
-- 
1.7.1
