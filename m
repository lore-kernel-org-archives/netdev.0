From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-05-23
Date: Fri, 23 May 2014 11:07:34 -0400
Message-ID: <20140523150733.GC13311@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

I have two more fixes intended for the 3.15 stream...

For the iwlwifi one, Emmanuel says:

"A race has been discovered in the beacon filtering code. Since the
fix is too big for 3.15, I disable here the feature."

For the bluetooth one, Gustavo says:

"This pull request contains a very important fix for 3.15. Here we fix the
permissions of a debugfs file that would otherwise allow unauthorized users
to write content to it."

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit b6ed5498601df40489606dbc14a9c7011c16630b:

  batman: fix a bogus warning from batadv_is_on_batman_iface() (2014-05-22 17:23:00 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

for you to fetch changes up to 5ca2504ea36df1da815029a9e9277c08540042eb:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless into for-davem (2014-05-23 10:55:58 -0400)

----------------------------------------------------------------

Emmanuel Grumbach (1):
      iwlwifi: mvm: disable beacon filtering

John W. Linville (3):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Samuel Ortiz (1):
      Bluetooth: Fix L2CAP LE debugfs entries permissions

 drivers/net/wireless/iwlwifi/mvm/mac80211.c | 2 +-
 net/bluetooth/l2cap_core.c                  | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
index b41dc84e9431..8735ef1f44ae 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -826,7 +826,7 @@ static int iwl_mvm_mac_add_interface(struct ieee80211_hw *hw,
 	if (ret)
 		goto out_remove_mac;
 
-	if (!mvm->bf_allowed_vif &&
+	if (!mvm->bf_allowed_vif && false &&
 	    vif->type == NL80211_IFTYPE_STATION && !vif->p2p &&
 	    mvm->fw->ucode_capa.flags & IWL_UCODE_TLV_FLAGS_BF_UPDATED){
 		mvm->bf_allowed_vif = mvmvif;
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index a1e5bb7d06e8..dc4d301d3a72 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -7519,9 +7519,9 @@ int __init l2cap_init(void)
 	l2cap_debugfs = debugfs_create_file("l2cap", 0444, bt_debugfs,
 					    NULL, &l2cap_debugfs_fops);
 
-	debugfs_create_u16("l2cap_le_max_credits", 0466, bt_debugfs,
+	debugfs_create_u16("l2cap_le_max_credits", 0644, bt_debugfs,
 			   &le_max_credits);
-	debugfs_create_u16("l2cap_le_default_mps", 0466, bt_debugfs,
+	debugfs_create_u16("l2cap_le_default_mps", 0644, bt_debugfs,
 			   &le_default_mps);
 
 	bt_6lowpan_init();
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
