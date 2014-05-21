From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH] qlogic: Use time_before()
Date: Wed, 21 May 2014 19:24:03 +0200
Message-ID: <1400693043-15786-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dept-HSGLinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
To: shahed.shaikh@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be future-proof and for better readability the time comparisons are =
modified
to use time_before() instead of plain, error-prone math.

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/n=
et/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 9f3adf4..c2a2ad4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -630,7 +630,7 @@ void qlcnic_prune_lb_filters(struct qlcnic_adapter =
*adapter)
 	struct hlist_node *n;
 	struct hlist_head *head;
 	int i;
-	unsigned long time;
+	unsigned long expires;
 	u8 cmd;
=20
 	for (i =3D 0; i < adapter->fhash.fbucket_size; i++) {
@@ -638,8 +638,8 @@ void qlcnic_prune_lb_filters(struct qlcnic_adapter =
*adapter)
 		hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
 			cmd =3D  tmp_fil->vlan_id ? QLCNIC_MAC_VLAN_DEL :
 						  QLCNIC_MAC_DEL;
-			time =3D tmp_fil->ftime;
-			if (jiffies > (QLCNIC_FILTER_AGE * HZ + time)) {
+			expires =3D tmp_fil->ftime + QLCNIC_FILTER_AGE * HZ;
+			if (time_before(expires, jiffies)) {
 				qlcnic_sre_macaddr_change(adapter,
 							  tmp_fil->faddr,
 							  tmp_fil->vlan_id,
@@ -657,8 +657,8 @@ void qlcnic_prune_lb_filters(struct qlcnic_adapter =
*adapter)
=20
 		hlist_for_each_entry_safe(tmp_fil, n, head, fnode)
 		{
-			time =3D tmp_fil->ftime;
-			if (jiffies > (QLCNIC_FILTER_AGE * HZ + time)) {
+			expires =3D tmp_fil->ftime + QLCNIC_FILTER_AGE * HZ;
+			if (time_before(expires, jiffies)) {
 				spin_lock_bh(&adapter->rx_mac_learn_lock);
 				adapter->rx_fhash.fnum--;
 				hlist_del(&tmp_fil->fnode);
--=20
1.7.10.4
