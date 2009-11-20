From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH] ixgbe: move tc variable to CONFIG_IXGBE_DCB
Date: Fri, 20 Nov 2009 19:32:27 +0530
Message-ID: <1258725747.3562.5.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>, Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:55764 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753214AbZKTODu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 09:03:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tc is required by CONFIG_IXGBE_DCB.
This also fixes compilation warning:

 drivers/net/ixgbe/ixgbe_main.c: In function =E2=80=98ixgbe_tx_is_pause=
d=E2=80=99:
 drivers/net/ixgbe/ixgbe_main.c:245: warning: unused variable =E2=80=98=
tc=E2=80=99

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index ebcec30..61a02ce 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -242,11 +242,11 @@ static void ixgbe_unmap_and_free_tx_resource(stru=
ct ixgbe_adapter *adapter,
 static inline bool ixgbe_tx_is_paused(struct ixgbe_adapter *adapter,
                                       struct ixgbe_ring *tx_ring)
 {
-	int tc;
 	u32 txoff =3D IXGBE_TFCS_TXOFF;
=20
 #ifdef CONFIG_IXGBE_DCB
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		int tc;
 		int reg_idx =3D tx_ring->reg_idx;
 		int dcb_i =3D adapter->ring_feature[RING_F_DCB].indices;
=20
--=20
1.6.5.3


