From: Jiri Pirko <jpirko@redhat.com>
Subject: =?UTF-8?q?=5Bpatch=20net-2=2E6=5D=20via-velocity=3A=20remove=20non-tagged=20packet=20filtering?=
Date: Tue, 16 Aug 2011 10:33:34 +0200
Message-ID: <1313483614-2188-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	romieu@fr.zoreil.com, stephan.baerwolf@tu-ilmenau.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020Ab1HPIdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2011 04:33:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's undesired to filter untagged packets at any time. So simply remove=
 this.

Reported-by: Stephan B=C3=A4rwolf <stephan.baerwolf@tu-ilmenau.de>
Tested-by: Stephan B=C3=A4rwolf <stephan.baerwolf@tu-ilmenau.de>
Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/via-velocity.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index deb1eca..7c5336c 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -515,10 +515,6 @@ static void velocity_init_cam_filter(struct veloci=
ty_info *vptr)
 	mac_set_cam_mask(regs, vptr->mCAMmask);
=20
 	/* Enable VCAMs */
-
-	if (test_bit(0, vptr->active_vlans))
-		WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
-
 	for_each_set_bit(vid, vptr->active_vlans, VLAN_N_VID) {
 		mac_set_vlan_cam(regs, i, (u8 *) &vid);
 		vptr->vCAMmask[i / 8] |=3D 0x1 << (i % 8);
--=20
1.7.6

