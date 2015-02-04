From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] vxlan: Only set has-GBP bit in header if any other bits would be set
Date: Wed,  4 Feb 2015 17:00:04 +0100
Message-ID: <776a985ae0db9e2c24aefe6d7d6cef1794eb685a.1423065534.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemlof.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39591 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933989AbbBDQAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 11:00:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows for a VXLAN-GBP socket to talk to a Linux VXLAN socket by
not setting any of the bits.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/vxlan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 31bac2a..fd68dc2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1681,6 +1681,9 @@ static void vxlan_build_gbp_hdr(struct vxlanhdr *vxh, u32 vxflags,
 {
 	struct vxlanhdr_gbp *gbp;
 
+	if (!md->gbp)
+		return;
+
 	gbp = (struct vxlanhdr_gbp *)vxh;
 	vxh->vx_flags |= htonl(VXLAN_HF_GBP);
 
-- 
1.9.3
