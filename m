From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-11-08
Date: Fri, 8 Nov 2013 10:48:03 -0500
Message-ID: <20131108154802.GG2002@tuxdriver.com>
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

Here is one more pull request for the 3.13 window.  This is primarily
composed of downstream pull requests that were posted while I was
traveling during the last part of the 3.12 release.

For the mac80211 bits, Johannes says:

"I have two DFS fixes (ath9k already supports DFS) and a fix for a
pointer race."

And...

"In this round for mac80211-next I have:
 * mesh channel switch support
 * a CCM rewrite, using potential hardware offloads
 * SMPS for AP mode
 * RF-kill GPIO driver updates to make it usable as an ACPI driver
 * regulatory improvements
 * documentation fixes
 * DFS for IBSS mode
 * and a few small other fixes/improvements"

For the TI driver bits, Luca says:

"Some patches intended for 3.13.  Eliad continues upstreaming pending
patches from the internal tree."

For the iwlwifi bits, Emmanuel says:

"There are a few fixes from Johannes mostly clean up patches. We have
also a few other fixes that are relevant for the new firmware that has
not been released yet."

For the Bluetooth bits, Gustavo says:

"A last fix to the 3.12. I ended forgetting to send it before, I hope we can
still make the way to 3.12. It is a revert and it fixes an issue with bluetooth
suspend/hibernate that had many bug reports. Please pull or let me know of any
problems. Thanks!"  (Obviously, that one didn't make 3.12...)

Also...

"One more big pull request for 3.13. These are the patches we queued during
last week. Here you will find a lot of improvements to the HCI and L2CAP and
MGMT layers with the main ones being a better debugfs support and end of work
of splitting L2CAP into Core and Socket parts."

Additionally, there is one ath9k patch to enable DFS in IBSS mode for
that driver.

I appreciate your consideration for taking this extra pull request
this cycle.  Please let me know if there are problems!

Thanks,

John

---

The following changes since commit dcd607718385d02ce3741de225927a57f528f93b:

  inet: fix a UFO regression (2013-11-08 02:07:59 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git for-davem

for you to fetch changes up to c1f3bb6bd317994beb3af7bbec4bf54ed0035509:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next into for-davem (2013-11-08 09:03:10 -0500)

----------------------------------------------------------------

Alexander Bondar (1):
      iwlwifi: mvm: update UAPSD support TLV bits

Andrei Otcheretianski (1):
      nl80211: fix channel switch parsing

Ard Biesheuvel (1):
      mac80211: port CCMP to cryptoapi's CCM driver

Barak Bercovitz (3):
      wlcore: read fw panic log only in host mode
      wlcore: Allow stopping fw log in recovery
      wlcore: wakeup from ELP before starting recovery

Chun-Yeow Yeoh (5):
      mac80211: refactor the parsing of chan switch ie
      mac80211: process the CSA frame for mesh accordingly
      {nl,cfg,mac}80211: enable the triggering of CSA frame in mesh
      {nl,cfg,mac}80211: implement mesh channel switch userspace API
      mac80211: process mesh channel switching using beacon

Eliad Peller (3):
      wlcore: add ap_event_mask
      wlcore: fix started_vifs calculation
      wlcore: save last regdom configuration on stop

Emmanuel Grumbach (3):
      mac80211: implement SMPS for AP
      iwlwifi: mvm: BT Coex fix NULL pointer dereference
      iwlwifi: mvm: BT Coex - fix copy paste issue

Felix Fietkau (1):
      mac80211: add ieee80211_tx_prepare_skb() helper function

Gustavo Padovan (14):
      Bluetooth: Extend state_change() call to report errors too
      Bluetooth: Add l2cap_state_change_and_error()
      Bluetooth: Access sk_sndtimeo indirectly in l2cap_core.c
      Bluetooth: Add chan->ops->set_shutdown()
      Bluetooth: Move l2cap_wait_ack() to l2cap_sock.c
      Bluetooth: use l2cap_chan_ready() instead of duplicate code
      Bluetooth: Remove not used struct sock
      Bluetooth: Do not access chan->sk directly
      Bluetooth: Hold socket in defer callback in L2CAP socket
      Bluetooth: Remove socket lock from l2cap_state_change()
      Bluetooth: Remove parent socket usage from l2cap_core.c
      Bluetooth: Add L2CAP channel to skb private data
      Bluetooth: Use bt_cb(skb)->chan to send raw data back
      Bluetooth: Remove sk member from struct l2cap_chan

Hans de Goede (1):
      Bluetooth: revert: "Bluetooth: Add missing reset_resume dev_pm_ops"

Heikki Krogerus (5):
      net: rfkill: gpio: convert to resource managed allocation
      net: rfkill: gpio: clean up clock handling
      net: rfkill: gpio: spinlock-safe GPIO access
      net: rfkill: gpio: prepare for DT and ACPI support
      net: rfkill: gpio: add ACPI support

Ido Reis (2):
      wlcore: fwlog dynamic mem_block control
      wl12xx/wl18xx: update default fw logger's settings

Igal Chernobelsky (3):
      wl18xx: default config alignment with phy defaults
      wlcore: fix interrogate command length
      wlcore/wl18xx/wl12xx: FW log params per chip arch

Johan Hedberg (20):
      Bluetooth: Fix L2CAP "Command Reject: Invalid CID" response
      Bluetooth: Remove unused command reject mapping for EMSGSIZE
      Bluetooth: Remove useless l2cap_err_to_reason function
      Bluetooth: Ignore A2MP data on non-BR/EDR links
      Bluetooth: Ignore SMP data on non-LE links
      Bluetooth: Fix updating the right variable in update_scan_rsp_data()
      Bluetooth: Reintroduce socket restrictions for LE sockets
      Bluetooth: Convert auto accept timer to use delayed work
      Bluetooth: Convert idle timer to use delayed work
      Bluetooth: Fix ATT socket backwards compatibility with user space
      Bluetooth: Check for flag instead of features in update_scan_rsp_data()
      Bluetooth: Check for flag instead of features in update_adv_data()
      Bluetooth: Add missing check for BREDR_ENABLED flag in update_class()
      Bluetooth: Refactor set_connectable settings update to separate function
      Bluetooth: Fix updating settings when there are no HCI commands to send
      Bluetooth: Move mgmt_pending_find to avoid forward declarations
      Bluetooth: Fix sending write_scan_enable when BR/EDR is disabled
      Bluetooth: Move HCI_LIMITED_DISCOVERABLE changes to a general place
      Bluetooth: Update Set Discoverable to support LE
      Bluetooth: Fix enabling fast connectable on LE-only controllers

Johannes Berg (8):
      cfg80211: fix scheduled scan pointer access
      mac80211: add missing IEEE80211_HW_SUPPORTS_HT_CCK_RATES docs
      cfg80211: fix docbook references
      iwlwifi: transport config n_no_reclaim_cmds should be unsigned
      iwlwifi: pcie: move warning message into warning
      iwlwifi: mvm: capture the FCS in monitor mode
      iwlwifi: mvm: add missing break in debugfs
      iwlwifi: warn if firmware image doesn't exist

John W. Linville (7):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-next
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth-next
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next into for-davem

Jouni Malinen (1):
      mac80211_hwsim: Fix tracking of beaconing for multi-vif

Luis R. Rodriguez (5):
      cfg80211: fix nl80211.h documentation for DFS enum states
      cfg80211: rename regulatory_hint_11d() to regulatory_hint_country_ie()
      cfg80211: enable regulatory hints for strict custom settings
      cfg80211: simplify strict custom alpha2 regdomain check
      cfg80211: export reg_initiator_name()

Marcel Holtmann (71):
      Bluetooth: Fix minor coding style issue in set_connectable()
      Bluetooth: Use hci_request for discoverable timeout handling
      Bluetooth: Update advertising data based on management commands
      Bluetooth: Introduce flag for limited discoverable mode
      Bluetooth: Make mgmt_discoverable() return void
      Bluetooth: Make mgmt_connectable() return void
      Bluetooth: Make mgmt_write_scan_failed() return void
      Bluetooth: Update class of device after changing discoverable mode
      Bluetooth: Move arming of discoverable timeout to complete handler
      Bluetooth: Simplify the code for re-arming discoverable timeout
      Bluetooth: Add HCI command structure for writing current IAC LAP
      Bluetooth: Add support for entering limited discoverable mode
      Bluetooth: Make mgmt_new_link_key() return void
      Bluetooth: Move eir_append_data() function into mgmt.c
      Bluetooth: Move eir_get_length() function into hci_event.c
      Bluetooth: Update class of device on discoverable timeout
      Bluetooth: Add l2cap_chan_no_resume stub for A2MP
      Bluetooth: Make mgmt_pin_code_request() return void
      Bluetooth: Make mgmt_pin_code_reply_complete() return void
      Bluetooth: Make mgmt_pin_code_neg_reply_complete() return void
      Bluetooth: Make mgmt_auth_failed() return void
      Bluetooth: Make mgmt_auth_enable_complete() return void
      Bluetooth: Make mgmt_ssp_enable_complete() return void
      Bluetooth: Make mgmt_set_class_of_dev_complete() return void
      Bluetooth: Make mgmt_set_local_name_complete() return void
      Bluetooth: Make mgmt_read_local_oob_data_reply_complete() return void
      Bluetooth: Make mgmt_new_ltk() return void
      Bluetooth: Rename create_ad into create_adv_data
      Bluetooth: Store scan response data in HCI device
      Bluetooth: Set the scan response data when needed
      Bluetooth: Store device name in scan response data
      Bluetooth: Rename update_ad into update_adv_data
      Bluetooth: Remove duplicate definitions for advertising event types
      Bluetooth: Remove enable_hs declaration
      Bluetooth: Socket address parameter for CID is in little endian
      Bluetooth: Expose inquiry_cache debugfs only on BR/EDR controllers
      Bluetooth: Expose auto_accept_delay debugfs only when SSP is supported
      Bluetooth: Expose static address value for LE capable controllers
      Bluetooth: Expose current voice setting in debugfs
      Bluetooth: Add address type to device blacklist table
      Bluetooth: Move blacklist debugfs entry creation into hci_core.c
      Bluetooth: Move uuids debugfs entry creation into hci_core.c
      Bluetooth: Use IS_ERR_OR_NULL for checking bt_debugfs
      Bluetooth: Create HCI device debugfs directory in hci_register_dev
      Bluetooth: Create root debugfs directory during module init
      Bluetooth: Move device_add handling into hci_register_dev
      Bluetooth: Include address type in blacklist debugfs data
      Bluetooth: Move idle_timeout and sniff_{min,max}_interval to hci_core.c
      Bluetooth: Use BDADDR_BREDR type for old blacklist ioctl interface
      Bluetooth: Use hcon directly instead of conn->hcon where possible
      Bluetooth: Block ATT connection on LE when device is blocked
      Bluetooth: Move HCI device features into hci_core.c
      Bluetooth: Add workaround for buggy max_page features page value
      Bluetooth: Remove debug entry for connection features
      Bluetooth: Move manufacturer, hci_ver and hci_rev into hci_core.c
      Bluetooth: Store local version information only during setup phase
      Bluetooth: Move export of class of device information into hci_core.c
      Bluetooth: Expose current list of link keys via debugfs
      Bluetooth: Remove bus attribute in favor of hierarchy
      Bluetooth: Expose white list size information in debugfs
      Bluetooth: Expose current list of long term keys via debugfs
      Bluetooth: Select the own address type during initial setup phase
      Bluetooth: Expose debugfs entry read/write own address type
      Bluetooth: Expose setting if debug keys are used or not
      Bluetooth: Add LE features to debugfs if available
      Bluetooth: Remove interval parameter from HCI connection
      Bluetooth: Add support for setting SSP debug mode
      Bluetooth: Expose debugfs settings for LE connection interval
      Bluetooth: Add support for setting DUT mode
      Bluetooth: Fix UUID values in debugfs file
      Bluetooth: Fix minor coding style issue in hci_core.c

Marco Porsch (1):
      mac80211: fixes for mesh powersave logic

Michael Opdenacker (1):
      iwlwifi: remove duplicate includes

Michal Kazior (3):
      cfg80211: fix DFS channel recovery timeout
      cfg80211: update dfs_state_entered upon dfs_state change
      mac80211: fix uninitialized variable

Seth Forshee (1):
      mac80211: Remove check for offchannel state when waking netdev queues

Simon Wunderlich (3):
      nl80211/cfg80211: enable DFS for IBSS mode
      mac80211: enable DFS for IBSS mode
      ath9k: enable DFS for IBSS mode

Sunil Dutt (1):
      cfg80211: pass station supported channel and oper class info

Victor Goldenshtein (1):
      wlcore: print active channel in the driver_state

 Documentation/DocBook/80211.tmpl            |   4 +-
 drivers/bluetooth/btusb.c                   |   1 -
 drivers/net/wireless/ath/ath9k/init.c       |   3 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c    |   9 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h       |   3 +-
 drivers/net/wireless/iwlwifi/iwl-io.c       |   1 -
 drivers/net/wireless/iwlwifi/iwl-trans.h    |   2 +-
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c  |   8 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c  |   1 +
 drivers/net/wireless/iwlwifi/mvm/fw.c       |   8 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c |   8 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c |  14 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h      |   1 -
 drivers/net/wireless/iwlwifi/mvm/ops.c      |   2 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c       |   6 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c      |   9 +-
 drivers/net/wireless/mac80211_hwsim.c       |  27 +-
 drivers/net/wireless/ti/wl12xx/main.c       |  16 +-
 drivers/net/wireless/ti/wl18xx/main.c       |  32 +-
 drivers/net/wireless/ti/wlcore/acx.c        |  10 +-
 drivers/net/wireless/ti/wlcore/cmd.c        |  12 +-
 drivers/net/wireless/ti/wlcore/cmd.h        |   3 +-
 drivers/net/wireless/ti/wlcore/conf.h       |   5 +-
 drivers/net/wireless/ti/wlcore/debugfs.c    |  18 +-
 drivers/net/wireless/ti/wlcore/event.c      |   1 +
 drivers/net/wireless/ti/wlcore/hw_ops.h     |   9 +
 drivers/net/wireless/ti/wlcore/init.c       |   6 +
 drivers/net/wireless/ti/wlcore/io.h         |   4 +-
 drivers/net/wireless/ti/wlcore/main.c       |  74 ++-
 drivers/net/wireless/ti/wlcore/scan.c       |  24 +-
 drivers/net/wireless/ti/wlcore/testmode.c   |   3 +-
 drivers/net/wireless/ti/wlcore/wlcore.h     |   9 +
 drivers/net/wireless/ti/wlcore/wlcore_i.h   |   2 -
 include/linux/ieee80211.h                   |  20 +
 include/net/bluetooth/bluetooth.h           |   1 +
 include/net/bluetooth/hci.h                 |  35 +-
 include/net/bluetooth/hci_core.h            |  89 ++-
 include/net/bluetooth/l2cap.h               |  20 +-
 include/net/cfg80211.h                      |  14 +
 include/net/mac80211.h                      |  18 +
 include/uapi/linux/nl80211.h                |  27 +-
 net/bluetooth/a2mp.c                        |   9 +-
 net/bluetooth/af_bluetooth.c                |   9 +-
 net/bluetooth/hci_conn.c                    |  48 +-
 net/bluetooth/hci_core.c                    | 803 ++++++++++++++++++++++++----
 net/bluetooth/hci_event.c                   |  59 +-
 net/bluetooth/hci_sock.c                    |   4 +-
 net/bluetooth/hci_sysfs.c                   | 373 -------------
 net/bluetooth/l2cap_core.c                  | 227 +++-----
 net/bluetooth/l2cap_sock.c                  | 120 ++++-
 net/bluetooth/mgmt.c                        | 637 +++++++++++++++-------
 net/bluetooth/rfcomm/core.c                 |  14 +-
 net/bluetooth/rfcomm/sock.c                 |  14 +-
 net/bluetooth/sco.c                         |  13 +-
 net/bluetooth/smp.c                         |   4 +-
 net/mac80211/Kconfig                        |  12 +
 net/mac80211/aes_ccm.c                      | 169 ++----
 net/mac80211/aes_ccm.h                      |  14 +-
 net/mac80211/cfg.c                          | 142 ++++-
 net/mac80211/debug.h                        |  10 +
 net/mac80211/debugfs_netdev.c               |  25 +-
 net/mac80211/ht.c                           |  41 +-
 net/mac80211/ibss.c                         | 116 ++--
 net/mac80211/ieee80211_i.h                  |  50 +-
 net/mac80211/iface.c                        |   3 +
 net/mac80211/key.h                          |   2 +-
 net/mac80211/mesh.c                         | 302 ++++++++++-
 net/mac80211/mesh_plink.c                   |   3 +-
 net/mac80211/mesh_ps.c                      |  33 +-
 net/mac80211/mlme.c                         |  32 +-
 net/mac80211/rx.c                           |   5 +-
 net/mac80211/spectmgmt.c                    |  33 +-
 net/mac80211/sta_info.c                     |  72 +++
 net/mac80211/sta_info.h                     |   5 +
 net/mac80211/status.c                       |  31 +-
 net/mac80211/tx.c                           |  45 ++
 net/mac80211/util.c                         | 124 ++++-
 net/mac80211/wpa.c                          |  44 +-
 net/rfkill/Kconfig                          |   2 +-
 net/rfkill/rfkill-gpio.c                    | 211 ++++----
 net/wireless/chan.c                         |   3 +-
 net/wireless/ibss.c                         |  24 +-
 net/wireless/mlme.c                         |   6 +-
 net/wireless/nl80211.c                      |  62 ++-
 net/wireless/reg.c                          |  14 +-
 net/wireless/reg.h                          |   4 +-
 net/wireless/scan.c                         |   4 +-
 net/wireless/sme.c                          |   4 +-
 net/wireless/util.c                         |  14 +-
 89 files changed, 3037 insertions(+), 1517 deletions(-)
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
