From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ethernet: cisco: enic: enic_dev:  Remove some unused functions
Date: Fri,  2 Jan 2015 21:29:24 +0100
Message-ID: <1420230564-2060-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Neel Patel <neepatel@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removes some functions that are not used anywhere:
enic_dev_enable2_done() enic_dev_enable2() enic_dev_deinit_done()
enic_dev_init_prov2() enic_vnic_dev_deinit()

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/ethernet/cisco/enic/enic_dev.c |   56 ----------------------------
 drivers/net/ethernet/cisco/enic/enic_dev.h |    5 ---
 2 files changed, 61 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.c b/drivers/net/ethernet/cisco/enic/enic_dev.c
index 87ddc44..f8d2a6a 100644
--- a/drivers/net/ethernet/cisco/enic/enic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/enic_dev.c
@@ -177,40 +177,6 @@ int enic_dev_intr_coal_timer_info(struct enic *enic)
 	return err;
 }
 
-int enic_vnic_dev_deinit(struct enic *enic)
-{
-	int err;
-
-	spin_lock_bh(&enic->devcmd_lock);
-	err = vnic_dev_deinit(enic->vdev);
-	spin_unlock_bh(&enic->devcmd_lock);
-
-	return err;
-}
-
-int enic_dev_init_prov2(struct enic *enic, struct vic_provinfo *vp)
-{
-	int err;
-
-	spin_lock_bh(&enic->devcmd_lock);
-	err = vnic_dev_init_prov2(enic->vdev,
-		(u8 *)vp, vic_provinfo_size(vp));
-	spin_unlock_bh(&enic->devcmd_lock);
-
-	return err;
-}
-
-int enic_dev_deinit_done(struct enic *enic, int *status)
-{
-	int err;
-
-	spin_lock_bh(&enic->devcmd_lock);
-	err = vnic_dev_deinit_done(enic->vdev, status);
-	spin_unlock_bh(&enic->devcmd_lock);
-
-	return err;
-}
-
 /* rtnl lock is held */
 int enic_vlan_rx_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
@@ -237,28 +203,6 @@ int enic_vlan_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	return err;
 }
 
-int enic_dev_enable2(struct enic *enic, int active)
-{
-	int err;
-
-	spin_lock_bh(&enic->devcmd_lock);
-	err = vnic_dev_enable2(enic->vdev, active);
-	spin_unlock_bh(&enic->devcmd_lock);
-
-	return err;
-}
-
-int enic_dev_enable2_done(struct enic *enic, int *status)
-{
-	int err;
-
-	spin_lock_bh(&enic->devcmd_lock);
-	err = vnic_dev_enable2_done(enic->vdev, status);
-	spin_unlock_bh(&enic->devcmd_lock);
-
-	return err;
-}
-
 int enic_dev_status_to_errno(int devcmd_status)
 {
 	switch (devcmd_status) {
diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.h b/drivers/net/ethernet/cisco/enic/enic_dev.h
index 10bb970..f5bb058 100644
--- a/drivers/net/ethernet/cisco/enic/enic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/enic_dev.h
@@ -55,11 +55,6 @@ int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic);
 int enic_dev_enable(struct enic *enic);
 int enic_dev_disable(struct enic *enic);
 int enic_dev_intr_coal_timer_info(struct enic *enic);
-int enic_vnic_dev_deinit(struct enic *enic);
-int enic_dev_init_prov2(struct enic *enic, struct vic_provinfo *vp);
-int enic_dev_deinit_done(struct enic *enic, int *status);
-int enic_dev_enable2(struct enic *enic, int arg);
-int enic_dev_enable2_done(struct enic *enic, int *status);
 int enic_dev_status_to_errno(int devcmd_status);
 
 #endif /* _ENIC_DEV_H_ */
-- 
1.7.10.4
