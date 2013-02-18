From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2013-02-18
Date: Mon, 18 Feb 2013 14:54:48 -0500
Message-ID: <20130218195448.GC12505@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pf9I7BMVVzbSWLtt"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This probably is the last big pull request for wireless bits
for 3.9.  Of course, I'm sure there will be a few stragglers here
and there...surely a few bug fixes as well... :-) (In fact, I see
that Johannes has already queued-up a few more for me while I was
preparing this...)

Included are a number of pulls...

For mac80211-next, Johannes says:

"The biggest change I have is undoubtedly Marco's mesh powersave
implementation. Beyond that, I have a patch from Emmanuel to modify the
DTIM period API in mac80211, scan improvements and a removal of some
previous workaround code from Stanislaw, dynamic short slot time from
Thomas and 64-bit station byte counters from Vladimir. I also made a
number of changes myself, some related to WoWLAN, some auth/deauth
improvements and most of them BSS list cleanups."

"This time, I have relatively large number of fixes in various areas of
the code (a memory leak in regulatory, an RX race in mac80211, the new
radar checking caused a P2P device problem, some mesh issues with
stations, an older bug in tracing and for kernel-doc) as well as a
number of small new features. The biggest (in the diffstat) is my work
on hidden SSID tracking."

"Please pull to get
 * radar detection work from Simon
 * mesh improvements from Thomas
 * a connection monitoring/powersave fix from Wojciech
 * TDLS-related station management work from Jouni
 * VLAN crypto fixes from Michael Braun
 * CCK support in minstrel_ht from Felix
 * an SMPS (not SMSP, oops) related improvement in mac80211 (Emmanuel)
 * some WoWLAN work from Amitkumar Karwar: pattern match offset and a
   documentation fix
 * some WoWLAN work from myself (TCP connection wakeup feature API)
 * and a lot of VHT (and some HT) work (also from myself)

And a number of more random cleanups/fixes. I merged mac80211/master to
avoid a merge problem there."

And regarding iwlwifi-next, Johannes says:

"We continue work on our new driver, but I also have a WoWLAN and AP mode
improvement for the previous driver and a change to use threaded
interrupts to prepare us for working with non-PCIe devices."

Regarding wl12xx, Luca says:

"A few more patches intended for 3.9.  Mostly some clean-ups I've been
doing to make it easier to support device-tree.  Also including one bug
fix for wl12xx where the rates we advertise were wrong and an update in
the wlconf structure to support newer firmwares."

For the nfc-next bits, Samuel says:

"This is the second NFC pull request for 3.9.

We have:

- A few pn533 fixes on top of Waldemar refactorization of the driver, one of
  them fixes target mode.

- A new driver for Inside Secure microread chipset. It supports two
  physical layers: i2c and MEI. The MEI one depends on a patchset that's
  been sent to Greg Kroah-Hartman for inclusion into the 3.9 kernel [1]. The
  dependency is a KConfig one which means this code is not buildable as long
  as the MEI API is not usptream."

"This 3rd NFC pull request for 3.9 contains a fix for the microread MEI
physical layer support, as the MEI bus API changed.

=46rom the MEI code, we now pass the MEI id back to the driver probe routin=
e,
and we also pass a name and a MEI id table through the mei_bus_driver
structure. A few renames as well like e.g. mei_bus_driver to mei_driver or
mei_bus_client to mei_device in order to be closer to the driver model
practices."

For the ath6kl bits, Kalle says:

"There's not anything special here, most of the patches are just code
cleanup. The only functional changes are using the beacon interval from user
space and fixing a crash which happens when inserting and removing the
module in a loop."

Also, I pulled the wireless tree in order to resolve some pending
merge issues.  On top of that, there is a bunch of work on brcmfmac
that leads up to P2P support.  Also, mwifiex, rtlwifi, and a variety
of other drivers see some basic cleanups and minor enhancements.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 4153577a8d318ae02b3791341e10e78416de402f:

  tg3: Use different macros for pci_chip_rev_id accesses (2013-02-18 12:45:=
53 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 98d5fac2330779e6eea6431a90b44c7476260dcc:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-02-18 13:47:13 -0500)

----------------------------------------------------------------

Alexander Bondar (1):
      mac80211: add vif debugfs driver callbacks

Amitkumar Karwar (2):
      nl80211: minor correction in sample wowlan mask calculation
      nl80211: add packet offset information for wowlan pattern

Arend van Spriel (9):
      brcmfmac: add chip information to the bus interface
      brcmfmac: add function to retrieve chip information
      brcmfmac: fix problem connecting to AP without security
      brcmfmac: add peer-to-peer group discovery support
      brcmfmac: add support for creating P2P client/GO interface
      brcmfmac: fix compiler warning on printf format
      brcmfmac: fix generation of the p2p related mac addresses
      brcmfmac: implement support for deleting virtual interfaces
      brcmfmac: change function signatures

Avinash Patil (5):
      mwifiex: store card specific data in PCI device table entry
      mwifiex: separate ring initialization and ring creation routines
      mwifiex: define generic data type for PCIe ring buffers
      mwifiex: add PCIe8897 support
      mwifiex: device specific sleep cookie handling for PCIe

Beni Lev (1):
      iwlwifi: mvm: fix TKIP key updating

Catalin Iacob (1):
      rtlwifi: Initialize rate_init member of struct rate_control_ops

Christian Lamparter (1):
      mac80211: protect rx-path with spinlock

Cong Ding (1):
      net: wireless/rtlwifi: fix uninitialized variable issue

Dan Carpenter (2):
      NFC: llcp: integer underflow in nfc_llcp_set_remote_gb()
      brcmsmac: fix brcms_c_country_valid()

Emanuel Taube (1):
      mac80211: Add the DS Params for mesh to every band

Emmanuel Grumbach (7):
      mac80211: inform the driver about update of dtim_period
      iwlwifi: don't ack the card state notification
      iwlwifi: mvm: fix the keyidx assignment
      iwlwifi: mvm: fix locking in iwl_mvm_ipv6_addr_change
      mac80211: allow driver to be stateless wrt. SMSP requests
      iwlwifi: mvm: use atomic interface iteration to avoid deadlock
      iwlwifi: mvm: beautify code in rx_handlers

Eric Lapuyade (1):
      NFC: Initial support for Inside Secure microread

Felix Fietkau (3):
      mac80211/minstrel_ht: show the number of retries for each rate in deb=
ugfs
      mac80211/minstrel_ht: remove the sampling bypass check for the lowest=
 rate
      mac80211/minstrel_ht: add support for using CCK rates

Hante Meuleman (32):
      brcmfmac: Remove drvr_up from bus interface.
      brcmfmac: Remove copy mac address from drvr at netdev up.
      brcmfmac: Use struct brcmf_if in brcmf_configure_opensecurity.
      brcmfmac: Track pending 8021x frames per ifp.
      brcmfmac: Add logging for FIL int set/get cmds.
      brcmfmac: Track statistics per ifp.
      brcmfmac: Update tracelogging for multiple netdevs.
      brcmfmac: Cleanup function brcmf_notifiy_connect_status_ap.
      brcmfmac: Use single function for channel to chanspec.
      brcmfmac: use brcmf_if::bssidx as index in interface list
      brcmfmac: Check null pointer on brcmf_dev_reset.
      brcmfmac: add support for P2P listen mode.
      brcmfmac: update escan for multiple bss and simplify.
      brcmfmac: update p2p add and delete vif routines.
      brcmfmac: add p2p change vif routines.
      brcmfmac: Fix bug mgmt_rx_register
      brcmfmac: Update connect setup/handling routines for multiple bss.
      brcmfmac: Update AP mode for GO creation.
      brcmfmac: Add handling of receiving P2P action frames.
      brcmfmac: P2P action frame tx.
      brcmfmac: Use real cookie value for p2p remain on channel.
      brcmfmac: Create p2p0 netdev via module variable.
      brcmfmac: Use role from wdev on AP commands and fix stop_ap.
      brcmfmac: Put printing action frames code under debug flag.
      brcmfmac: Ignore E_ADD_IF for ifidx 0.
      brcmfmac: Reject change vif for p2p if.
      brcmfmac: Update netdev configuration in wiphy for p2p.
      brcmfmac: Remove sleep on del_station.
      brcmfmac: Fix rtnl_lock lockup when registering netdev.
      brcmfmac: Cleanup of unused defines.
      brcmfmac: Create netdev before returning from add_virtual_intf.
      brcmfmac: Add tx p2p off-channel support.

Ilan Peer (3):
      iwlwifi: mvm: Update quota settings for all bindings
      iwlwifi: mvm: Change the Time Event type used for ROC
      cfg80211: fix radar check for P2P_DEVICE

Jiri Slaby (1):
      NET: ath5k, check ath5k_eeprom_mode_from_channel retval

Joe Perches (3):
      mwl8k: Remove unnecessary alloc/OOM messages
      brcmsmac: Downgrade d11hdrs_mac80211 error messages to warnings.
      brcmsmac: Remove unnecessary memset casts

Johannes Berg (74):
      Merge remote-tracking branch 'wireless-next/master' into HEAD
      cfg80211: add SME state to warning in __cfg80211_mlme_disassoc
      cfg80211/mac80211: support reporting wakeup reason
      mac80211: remove assoc data "sent_assoc"
      mac80211: remove last_probe_resp from bss
      mac80211: remove unused mesh data from bss
      cfg80211: remove free_priv BSS API
      mac80211: start auth/assoc timeout on frame status
      mac80211: send deauth when connection is lost
      mac80211: always allow calling ieee80211_connection_loss()
      cfg80211: refactor hidden SSID finding
      cfg80211: fix BSS list hidden SSID lookup
      cfg80211: simplify mesh BSS comparison
      cfg80211: remove unused cfg80211_get_mesh
      mac80211: remove unused SSID from BSS
      cfg80211: fix BSS IE allocation comment
      cfg80211: move locking into cfg80211_bss_age
      mac80211: allow transmitting deauth with tainted key
      mac80211: send deauth if connection was lost during suspend
      cfg80211: use lockdep to assert lock is held
      cfg80211: remove a local variable
      cfg80211: wrap BSS kref
      iwlwifi: use threaded interrupt handler
      Merge remote-tracking branch 'wireless-next/master' into HEAD
      cfg80211: pass wiphy to cfg80211_ref_bss/put_bss
      wireless: fix kernel-doc
      mac80211: fix AP beacon loss messages
      mac80211: fix chandef tracing bug
      mac80211: explicitly copy channels to VLANs where needed
      cfg80211: track hidden SSID networks properly
      cfg80211: remove scan ies NULL check
      cfg80211: move TSF into IEs
      mac80211: introduce beacon-only timing data
      mac80211: remove dynamic PS driver interface
      mac80211: remove IEEE80211_HW_SCAN_WHILE_IDLE
      mac80211: simplify idle handling
      mac80211: remove unused code to mark AP station authenticated
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next
      iwlwifi: dvm: query and report WoWLAN wakeup reason
      iwlwifi: mvm: report wakeup reasons
      iwlwifi: dvm: apply beacon changes immediately
      iwlwifi: mvm: don't delay the association until after beacon
      iwlwifi: mvm: don't wait for session protection to start
      iwlwifi: mvm: update station when marked associated
      cfg80211: configuration for WoWLAN over TCP
      mac80211: fix auth/assoc timeout handling
      mac80211: don't call bss_info_changed on p2p-device/monitor
      mac80211: always unblock CSA queue stop when disconnecting
      mac80211: don't pick up WPA vendor IE
      mac80211: use spin_lock_bh() for tim_lock
      mac80211: use spin_lock_bh() for TKIP lock
      Merge remote-tracking branch 'mac80211/master' into HEAD
      mac80211: pass station to ieee80211_vht_cap_ie_to_sta_vht_cap
      mac80211: stop toggling IEEE80211_HT_CAP_SUP_WIDTH_20_40
      wireless: define operating mode action frame
      mac80211: track number of spatial streams
      mac80211: handle VHT operating mode notification
      mac80211: init HT TX data before rate control
      mac80211: fix HT/VHT disable flags
      mac80211: fix ieee80211_change_chandef name
      mac80211: handle operating mode notif in beacon/assoc response
      mac80211: disable HT/VHT if AP has no HT/VHT capability
      mac80211: clean up channel use in ieee80211_config_ht_tx
      mac80211: add ieee80211_vif_change_bandwidth
      mac80211: move ieee80211_determine_chantype function
      mac80211: properly track HT/VHT operation changes
      cfg80211: allow drivers to selectively disable 80/160 MHz
      nl80211: advertise HT/VHT channel limitations
      mac80211: constify IE parsing
      mac80211: stop modifying HT SMPS capability
      cfg80211: advertise extended capabilities to userspace
      mac80211: advertise operating mode notification capability
      nl80211: renumber NL80211_FEATURE_FULL_AP_CLIENT_STATE
      mac80211: prevent spurious HT/VHT downgrade message

John W. Linville (10):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge tag 'nfc-next-3.9-2' of git://git.kernel.org/.../sameo/nfc-next
      Merge tag 'nfc-next-3.9-3' of git://git.kernel.org/.../sameo/nfc-next
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-linville' of git://github.com/kvalo/ath6kl
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jonas Gorski (1):
      mwl8k: add single band 88W8366 PCI device IDs

Jouni Malinen (2):
      cfg80211: Pass station (extended) capability info to kernel
      cfg80211: Pass TDLS peer's QoS/HT/VHT information during set_station

Julia Lawall (1):
      drivers/net/wireless/ath/ath6kl/hif.c: drop if around WARN_ON

Karl Beldan (1):
      mac80211_hwsim: ask mac80211 to reserve space for chanctx.drv_priv

Larry Finger (4):
      rtlwifi: rtl8192cu: Fix NULL dereference BUG when using new_id
      rtlwifi: rtl8192cu: Add new USB ID
      cfg80211: Fix memory leak
      rtlwifi: Rework Kconfig

Luciano Coelho (10):
      wlcore: use single-role version when verifying the PLT firmware
      wlcore: remove unused set_power method
      wlcore: remove if_ops from platform_data
      wlcore: use wl12xx_platform_data pointer from wlcore_pdev_data
      wlcore: use PLATFORM_DEVID_AUTO for plat dev creation to avoid confli=
cts
      wlcore: move wl12xx_platform_data up and make it truly optional
      wlcore: don't hide real error code when booting fails
      wlcore: fix wrong remote rates when starting STA role
      wlcore: remove newly introduced alloc/OOM messages
      cfg80211: check vendor IE length to avoid overrun

Marco Porsch (1):
      mac80211: mesh power save basics

Michael Braun (2):
      mac80211: free ps->bc_buf skbs on vlan device stop
      mac80211: fix WPA with VLAN on AP side with ps-sta

Mohammed Shafi Shajakhan (9):
      ath6kl: Fix a mismatch in power management debug message
      ath6kl: Remove erroneous flag clearing
      ath6kl: Use standard way to assign the boolean variable
      ath6kl: remove unnecessary check for NULL skb
      ath6kl: Fix kernel panic on continuous driver load/unload
      ath6kl: trivial cleanup on interface type selection
      ath6kl: Parse beacon interval from userspace
      ath6kl: Move and rename ath6kl_cleanup_vif function
      ath6kl: minor optimization using if, else if

Piotr Haber (3):
      brcmfmac: fix mmc host locking issue
      brcmfmac: turn clocks on when reading shared info
      brcmfmac: remove unnecessary locking in trap info processing

Samuel Ortiz (3):
      NFC: microread: Add i2c physical layer
      NFC: microread: Add MEI physical layer
      NFC: microread: Fix mei physical layer

Seth Forshee (2):
      mac80211: Fix tx queue handling during scans
      mac80211: Add flushes before going off-channel

Simon Wunderlich (2):
      nl80211/cfg80211: add radar detection command/event
      mac80211: add radar detection command/event

Stanislaw Gruszka (4):
      mac80211: remove IEEE80211_HW_TEARDOWN_AGGR_ON_BAR_FAIL
      mac80211: improve latency and throughput while software scanning
      rt2x00: check for dma mappings errors
      iwlegacy: more checks for dma mapping errors

Sujith Manoharan (2):
      ath9k: Fix ATH9K_HW_CAP_HT usage
      ath9k: Fix IBSS joiner mode

Thierry Escande (1):
      NFC: pn533: Fix target polling mode

Thomas Pedersen (6):
      mac80211: dynamic short slot time for MBSSs
      mac80211: stop plink timer only on mesh interfaces
      mac80211: fix mesh sta teardown
      mac80211: consolidate MBSS change notification
      mac80211: cache mesh beacon
      mac80211: generate mesh probe responses

Tim Gardner (2):
      brcmsmac: fix u16 overflow warning
      brcmsmac: avoid 512 byte stack variable

Tomasz Guszkowski (1):
      p54usb: corrected USB ID for T-Com Sinus 154 data II

Victor Goldenshtein (1):
      wl18xx: add new phy configuration parameters for telec support

Vladimir Kondratiev (2):
      cfg80211: expand per-station byte counters to 64bit
      ath6kl: provide 64-bit per-station byte counters

Waldemar Rymarkiewicz (2):
      nfc: pn533: Use static poll_mod and std_frame_ops
      nfc: pn533: Remove unreachable code

Wojciech Dubowik (1):
      mac80211: fix ieee80211_sta_tx_notify for nullfunc

Xose Vazquez Perez (2):
      wireless: rt2x00: rt2800usb add Sweex ids
      wireless: rt2x00: rt2800usb add "unknown" devices

 arch/arm/mach-omap2/board-omap3evm.c               |   10 +-
 drivers/net/wireless/ath/ath5k/phy.c               |    4 +
 drivers/net/wireless/ath/ath5k/reset.c             |    2 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  117 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.h         |    2 -
 drivers/net/wireless/ath/ath6kl/core.h             |    2 +-
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |   26 +-
 drivers/net/wireless/ath/ath6kl/init.c             |   36 +-
 drivers/net/wireless/ath/ath6kl/usb.c              |    6 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |   30 +-
 drivers/net/wireless/ath/ath6kl/wmi.h              |    6 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |    1 +
 drivers/net/wireless/ath/ath9k/beacon.c            |  113 +-
 drivers/net/wireless/ath/ath9k/main.c              |   13 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    5 +-
 drivers/net/wireless/ath/carl9170/main.c           |    2 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |    2 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   57 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   19 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |    8 +
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  311 +--
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   25 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |   11 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |    7 +-
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |   66 +
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      | 2277 ++++++++++++++++=
++++
 drivers/net/wireless/brcm80211/brcmfmac/p2p.h      |  183 ++
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   11 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 1375 ++++++++----
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |  113 +-
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  |    3 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   65 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |   51 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |   38 +-
 drivers/net/wireless/iwlegacy/4965-rs.c            |    3 +-
 drivers/net/wireless/iwlegacy/common.c             |   32 +-
 drivers/net/wireless/iwlwifi/dvm/agn.h             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/commands.h        |   18 +
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |  166 +-
 drivers/net/wireless/iwlwifi/dvm/rs.c              |   12 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c              |    2 +-
 drivers/net/wireless/iwlwifi/dvm/rxon.c            |    5 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |   40 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |   26 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |   10 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   29 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |  174 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |    3 +
 drivers/net/wireless/iwlwifi/mvm/fw.c              |    4 -
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |    6 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   20 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   41 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |    2 +-
 drivers/net/wireless/iwlwifi/mvm/quota.c           |   29 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   30 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |    2 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   40 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |    6 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |  232 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   12 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    3 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |   40 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   11 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |    8 +-
 drivers/net/wireless/libertas/cfg.c                |    8 +-
 drivers/net/wireless/mac80211_hwsim.c              |    1 +
 drivers/net/wireless/mwifiex/Kconfig               |    4 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |    2 +-
 drivers/net/wireless/mwifiex/pcie.c                |  769 ++++---
 drivers/net/wireless/mwifiex/pcie.h                |  215 +-
 drivers/net/wireless/mwifiex/scan.c                |    2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   11 +-
 drivers/net/wireless/mwl8k.c                       |    2 +
 drivers/net/wireless/orinoco/scan.c                |    4 +-
 drivers/net/wireless/p54/p54usb.c                  |    2 +-
 drivers/net/wireless/rndis_wlan.c                  |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   12 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |    7 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   21 +
 drivers/net/wireless/rt2x00/rt2x00.h               |    4 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   31 +-
 drivers/net/wireless/rtlwifi/Kconfig               |   50 +-
 drivers/net/wireless/rtlwifi/base.c                |    7 +-
 drivers/net/wireless/rtlwifi/rc.c                  |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    9 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    3 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |    3 +-
 drivers/net/wireless/rtlwifi/usb.c                 |    5 +-
 drivers/net/wireless/rtlwifi/usb.h                 |    3 +-
 drivers/net/wireless/ti/Kconfig                    |    9 +
 drivers/net/wireless/ti/Makefile                   |    4 +-
 ...12xx_platform_data.c =3D> wilink_platform_data.c} |    0
 drivers/net/wireless/ti/wl1251/event.c             |    6 +-
 drivers/net/wireless/ti/wl1251/main.c              |   24 +-
 drivers/net/wireless/ti/wl12xx/main.c              |    3 +-
 drivers/net/wireless/ti/wl18xx/conf.h              |    7 +-
 drivers/net/wireless/ti/wl18xx/main.c              |    7 +-
 drivers/net/wireless/ti/wlcore/Kconfig             |    5 -
 drivers/net/wireless/ti/wlcore/Makefile            |    3 -
 drivers/net/wireless/ti/wlcore/boot.c              |    4 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |    8 +-
 drivers/net/wireless/ti/wlcore/main.c              |   18 +-
 drivers/net/wireless/ti/wlcore/sdio.c              |   35 +-
 drivers/net/wireless/ti/wlcore/spi.c               |   40 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |    1 -
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |    5 +
 drivers/nfc/Kconfig                                |    1 +
 drivers/nfc/Makefile                               |    1 +
 drivers/nfc/microread/Kconfig                      |   35 +
 drivers/nfc/microread/Makefile                     |   10 +
 drivers/nfc/microread/i2c.c                        |  340 +++
 drivers/nfc/microread/mei.c                        |  246 +++
 drivers/nfc/microread/microread.c                  |  728 +++++++
 drivers/nfc/microread/microread.h                  |   33 +
 drivers/nfc/pn533.c                                |    8 +-
 drivers/staging/wlan-ng/cfg80211.c                 |    2 +-
 include/linux/ieee80211.h                          |   50 +-
 include/linux/platform_data/microread.h            |   35 +
 include/linux/wl12xx.h                             |   16 +-
 include/net/cfg80211.h                             |  226 +-
 include/net/mac80211.h                             |  170 +-
 include/uapi/linux/nl80211.h                       |  274 ++-
 net/mac80211/Kconfig                               |   11 +
 net/mac80211/Makefile                              |    3 +-
 net/mac80211/cfg.c                                 |   95 +-
 net/mac80211/chan.c                                |  155 +-
 net/mac80211/debug.h                               |   10 +
 net/mac80211/debugfs.c                             |    6 +-
 net/mac80211/debugfs_netdev.c                      |    5 +
 net/mac80211/debugfs_sta.c                         |    5 +-
 net/mac80211/driver-ops.h                          |   54 +-
 net/mac80211/ht.c                                  |  110 +-
 net/mac80211/ibss.c                                |   53 +-
 net/mac80211/ieee80211_i.h                         |  196 +-
 net/mac80211/iface.c                               |  132 +-
 net/mac80211/main.c                                |   42 +-
 net/mac80211/mesh.c                                |  284 ++-
 net/mac80211/mesh.h                                |   40 +-
 net/mac80211/mesh_hwmp.c                           |   49 +-
 net/mac80211/mesh_pathtbl.c                        |   12 +-
 net/mac80211/mesh_plink.c                          |  120 +-
 net/mac80211/mesh_ps.c                             |  598 +++++
 net/mac80211/mlme.c                                | 1081 ++++++----
 net/mac80211/offchannel.c                          |   35 +-
 net/mac80211/pm.c                                  |   12 +
 net/mac80211/rate.h                                |    2 +
 net/mac80211/rc80211_minstrel.c                    |   29 +
 net/mac80211/rc80211_minstrel.h                    |    2 +
 net/mac80211/rc80211_minstrel_ht.c                 |  181 +-
 net/mac80211/rc80211_minstrel_ht.h                 |    5 +-
 net/mac80211/rc80211_minstrel_ht_debugfs.c         |  112 +-
 net/mac80211/rx.c                                  |  161 +-
 net/mac80211/scan.c                                |   66 +-
 net/mac80211/sta_info.c                            |   38 +-
 net/mac80211/sta_info.h                            |   20 +-
 net/mac80211/status.c                              |   25 +-
 net/mac80211/tkip.c                                |   10 +-
 net/mac80211/trace.h                               |   23 +-
 net/mac80211/tx.c                                  |  109 +-
 net/mac80211/util.c                                |   82 +-
 net/mac80211/vht.c                                 |  172 +-
 net/mac80211/wme.c                                 |   13 +-
 net/mac80211/wpa.c                                 |    5 +-
 net/nfc/llcp/llcp.c                                |    5 +-
 net/wireless/chan.c                                |  142 +-
 net/wireless/core.c                                |    8 +-
 net/wireless/core.h                                |   35 +-
 net/wireless/ibss.c                                |    4 +-
 net/wireless/mlme.c                                |  136 +-
 net/wireless/nl80211.c                             |  783 ++++++-
 net/wireless/nl80211.h                             |    7 +
 net/wireless/reg.c                                 |   20 +-
 net/wireless/scan.c                                |  630 +++---
 net/wireless/sme.c                                 |   16 +-
 net/wireless/sysfs.c                               |    2 -
 net/wireless/trace.h                               |   80 +
 net/wireless/util.c                                |    2 +-
 189 files changed, 12387 insertions(+), 3236 deletions(-)
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/fwil_types.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/p2p.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/p2p.h
 rename drivers/net/wireless/ti/{wlcore/wl12xx_platform_data.c =3D> wilink_=
platform_data.c} (100%)
 create mode 100644 drivers/nfc/microread/Kconfig
 create mode 100644 drivers/nfc/microread/Makefile
 create mode 100644 drivers/nfc/microread/i2c.c
 create mode 100644 drivers/nfc/microread/mei.c
 create mode 100644 drivers/nfc/microread/microread.c
 create mode 100644 drivers/nfc/microread/microread.h
 create mode 100644 include/linux/platform_data/microread.h
 create mode 100644 net/mac80211/mesh_ps.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--pf9I7BMVVzbSWLtt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRIocHAAoJEJctW/TcYTgG/YsP/26OmFOqWWl5w6dKFjCkA+hj
9KxXJt1uc9mDjD6LTQCwW/DYWwZF+O/rO0vwCBEQ/eowZj5Dkqlfufudd4QpMRNO
yBjTNCJotWKuBQMBQn8/kNPwG357aMOaYYGptsVxcOHfUdwE3L9G8X9fcLvVGqWF
MvKIDfkFAAARzI8mXmngIwEB23QFk1tJHzEwej3ud4FEDmP6XQTV6DYZJ+UKXQOE
T43FTwgqVm2wLxRPLQjJB4pR9ddkBJay/qRu6FlNfctyq4UdY4duqM63DnIg+5LS
Eu4Gs5rcwvo5f+BeZfNtPSwqCN76jmjEf7WTv1Ys60EpmAtyxHLu8nl24DxIHyUR
lNi+3olLRxTiiTAnphhKxG4QBZcT43qSLdT1qUZNuA2OLeB0zHS29igwQZLDa95l
Zd64y0PAJArruOzvDqnwRnaAHyqXOPkH33XAzH83TmQYautBIdE6sh/BUtLqvMXv
4AxVkRI85/mcBj5iYPinKUHweAqgIYjWbS4B2BaYim2PV71e50apwu/tN7v2vf4a
DgVGlPQDdCgOiExwr/UzxhBM2y4f8jGDta1y+ACUQLYQkC5/U2y7L430M7lWSUG7
R+JgVXb8ydhPpLOItTwvxEoLoS1WPqPZVmk9myli1ozx1T1M7P5vIDgvIusc7Mgp
AAFRJEbCwa+2PnULWo1e
=mhGP
-----END PGP SIGNATURE-----

--pf9I7BMVVzbSWLtt--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
