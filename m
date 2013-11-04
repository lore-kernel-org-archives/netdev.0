From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-11-04
Date: Mon, 4 Nov 2013 15:22:42 -0500
Message-ID: <20131104202241.GB1989@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TB36FDmn/VVEgNH/"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please accept the following pull request intended for the 3.13 tree...

I had intended to pass most of these to you as much as two weeks ago.
Unfortunately, I failed to account for the effects of bad Internet
connections and my own fatique/laziness while traveling.  On the bright
side, at least these have been baking in linux-next for some time!

For the mac80211 bits, Johannes says:

"This time I have two fixes for P2P (which requires not using CCK rates)
and a workaround for APs with broken WMM information."

For the iwlwifi bits, Johannes says:

"I have a few fixes for warnings/issues: one from Alex, fixing scan
timings, one from Emmanuel fixing a WARN_ON in the DVM driver, one from
Stanislaw removing a trigger-happy WARN_ON in the MVM driver and a
change from myself to try to recover when the device isn't processing
commands quickly."

And:

"For this round, I have a lot of changes:
 * power management improvements
 * BT coexistence improvements/updates
 * new device support
 * VHT support
 * IBSS support (though due to a small bug it requires new firmware)
 * various other fixes/improvements."

For the Bluetooth bits, Gustavo says:

"More patches for 3.12, busy times for Bluetooth. More than a 100 commits s=
ince
the last pull. The bulk of work comes from Johan and Marcel, they are doing
fixes and improvements all over the Bluetooth subsystem, as the diffstat can
show."

For the ath10k and ath6kl bits, Kalle says:

"Bartosz added support to ath10k for our 10.x AP firmware branch, which
gives us AP specific features and fixes. We still support the main
firmware branch as well just like before, ath10k detects runtime what
firmware is used. Unfortunately the firmware interface in 10.x branch is
somewhat different so there was quite a lot of changes in ath10k for
this.

Michal and Sujith did some performance improvements in ath10k. Vladimir
fixed a compiler warning and Fengguang removed an extra semicolon."

For the NFC bits, Samuel says:

"It's a fairly big one, with the following highlights:

- NFC digital layer implementation: Most NFC chipsets implement the NFC
  digital layer in firmware, but others have more basic functionalities
  and expect the host to implement the digital layer. This layer sits
  below the NFC core.

- Sony's port100 support: This is "soft" NFC USB dongle that expects the
  digital layer to be implemented on the host. This is the first user of
  our NFC digital stack implementation.

- Secure element API: We now provide a netlink API for enabling,
  disabling and discovering NFC attached (embedded or UICC ones) secure
  elements. With some userspace help, this allows us to support NFC
  payments.
  Only the pn544 driver currently supports that API.

- NCI SPI fixes and improvements: In order to support NCI devices over
  SPI, we fixed and improved our NCI/SPI implementation. The currently
  most deployed NFC NCI chipset, Broadcom's bcm2079x, supports that mode
  and we're planning to use our NCI/SPI framework to implement a
  driver for it.

- pn533 fragmentation support in target mode: This was the only missing
  feature from our pn533 impementation. We now support fragmentation in
  both Tx and Rx modes, in target mode."

On top of all that, brcmfmac and rt2x00 both get the usual flurry
of updates.  A few other drivers get hit here or there as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit f421436a591d34fa5279b54a96ac07d70250cc8d:

  net/hsr: Add support for the High-availability Seamless Redundancy protoc=
ol (HSRv0) (2013-11-03 23:20:14 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 87bc0728d462ae37841a550542829aa65a97e7c2:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-11-04 14:51:28 -0500)

----------------------------------------------------------------

Alexander Bondar (3):
      iwlwifi: mvm: Adjust some power management constants
      iwlwifi: mvm: Add device wide power command
      iwlwifi: mvm: fix scan request's suspend time parameter

Andre Guedes (4):
      Bluetooth: Rename hci_conn variable in hci_connect_le()
      Bluetooth: Initialize hci_conn fields in hci_connect_le
      Bluetooth: Use HCI request for LE connection
      Bluetooth: Refactor hci_connect_le

Andrei Otcheretianski (3):
      iwlwifi: mvm: Implement BT coex notifications
      mac80211: fix honouring rate flags in low-rate transmit
      mac80211: respect rate mask in TX

Arend van Spriel (12):
      brcmfmac: store address in trace_brcmf_hexdump()
      brcmfmac: add tracepoint for capturing the SDPCM header
      brcmfmac: rename variable max_seg_sz to max_seg_cnt for clarity
      brcmfmac: determine host controller related variables during probe
      brcmfmac: rework scatter-gather code in brcmf_sdio_buffrw()
      brcmfmac: rename brcmf_sdio_buffrw()
      brcmfmac: rework single packet transfers
      brcmfmac: verify result of brcmf_sdio_addrprep() calls
      brcmfmac: remove stale code from brcmf_sdcard_recv_chain()
      brcmfmac: fix brcmf_sdcard_send_pkt() for host without sg support
      brcmfmac: fix brcmf_sdio_txpkt_prep() for host without sg support
      brcmfmac: fix brcmf_sdcard_recv_chain() for host without sg support

Arron Wang (3):
      NFC: pn544: Add SE discover operation
      NFC: Export nfc_find_se()
      NFC: pn544: Add SE enable/disable operation

Bartosz Markowski (18):
      ath10k: introduce dynamic WMI structures
      ath10k: add wmi_10x_<cmd/event> definitions
      ath10k: warn if give WMI command is not supported
      ath10k: implement WMI events handling frame for both firmwares
      ath10k: split ath10k_wmi_service_ready_event_rx
      ath10k: drop the fw versioning sanity check
      ath10k: implement host memory chunks
      ath10k: bring back the WMI path for mgmt frames
      ath10k: split wmi_cmd_init path
      ath10k: add TARGET values for 10.x firmware
      ath10k: introduce dynamic vdev parameters
      ath10k: introduce dynamic pdev parameters
      ath10k: handle FW API differences for scan structures
      ath10k: enable 10.x firmware branch support
      ath10k: extend the max_scan time
      ath10k: do not warn about unsupported vdev param
      ath10k: rename WMI_CMD_UNDEFINED
      ath10k: return better errno for unsupported pdev params

Dan Williams (1):
      libertas: move firmware lifetime handling to firmware.c

David Spinadel (4):
      iwlwifi: mvm: implement NoA testing using testmode cmd
      iwlwifi: mvm: add no_basic_ssid option
      iwlwifi: mvm: support sched scan if supported by the fw
      iwlwifi: mvm: fix operator precedence

Djalal Harouni (1):
      iwlwifi: mvm: make debugfs write() operations write up to count bytes

Emmanuel Grumbach (21):
      iwlwifi: mvm: use CTS to Self if firmware allows it
      iwlwifi: pcie: clean RFKILL interrupt in AMPG
      iwlwifi: mvm: don't sleep while allocating in atomic context
      iwlwifi: mvm: new BT Coex API
      iwlwifi: mvm: BT Coex - no need to send envelopes
      iwlwifi: mvm: BT Coex - use data from firmware
      iwlwifi: mvm: don't use reduced Tx power when not applicable
      iwlwifi: mvm: BT Coex - adapt debugfs to new API
      iwlwifi: mvm: BT Coex - Correctly enable and treat rssi events
      iwlwifi: pcie: dump_stack upon timeout of SYNC cmd
      iwlwifi: mvm: BT Coex - don't limit agg size in loose scheme
      iwlwifi: mvm: BT Coex - set the proper LUT for single ant devices
      iwlwifi: pcie: restart the driver when a command times out
      iwlwifi: mvm: BT Coex - track bandwidth changes in HT
      iwlwifi: mvm: BT Coex - tune SMPS parameters
      iwlwifi: mvm: BT Coex - start AMPDU even when BT is active
      iwlwifi: mvm: BT Coex - remove duplicate code in rate control
      iwlwifi: mvm: BT Coex - update integration with rate control
      iwlwifi: mvm: BT Coex - always set mandatory fields
      iwlwifi: mvm: BT Coex - enable Tx power based on BT status
      iwlwifi: dvm: don't override mac80211's queue setting

Eran Harary (2):
      iwlwifi: Support 7265 devices
      iwlwifi: support Signed firmware image and Dual CPUs

Eric Lapuyade (8):
      NFC: NCI: Fix wrong allocation size in nci_spi_allocate_device()
      NFC: NCI: Rename spi ndev -> nsdev and nci_dev -> ndev for consistency
      NFC: Move struct nfc_phy_ops out of HCI up to nfc core level
      NFC: NCI: Simplify NCI SPI to become a simple framing/checking layer
      NFC: NCI: Store the spi device pointer from the spi instance
      NFC: NCI: zero struct spi_transfer variables before usage
      NFC: NCI: nci_spi_recv_frame() now returns (not forward) the read fra=
me
      NFC: NCI: Modify NCI SPI to implement CS/INT handshake per the spec

Eyal Shapira (5):
      iwlwifi: mvm: remove rs FSM actions relevant only for 3 antennas
      iwlwifi: mvm: fix switch from shared antenna in case of BT load
      iwlwifi: mvm: update expected tpt tables for VHT
      iwlwifi: mvm: support VHT in rs
      iwlwifi: mvm: remove GF support in rs

Eytan Lifshitz (3):
      iwlwifi: mvm: change the name of init_ucode_run flag
      iwlwifi: mvm: prevent the NIC to be powered at driver load time.
      iwlwifi: mvm: add support for NICs which have only 16 Tx queues.

Felipe Pena (2):
      drivers: net: wireless: b43: Fix possible NULL ptr dereference
      drivers: net: wireless: Fix wrong check for reassociation request ret=
ry counter

Felix Fietkau (1):
      ath5k: fix regression in tx status processing

Fengguang Wu (2):
      NFC: digital: digital_tg_send_sensf_res() can be static
      ath10k: remove unneded semicolon from ath10k_core_fetch_firmware_api_=
n()

Gabor Juhos (24):
      rt2x00: rt2800lib: use {tx,rx}_chain_num to avoid superfluous EEPROM =
access
      rt2x00: rt2800lib: use switch statement for RF specific setup
      rt2x00: rt2800lib: autodetect 5GHz band support
      rt2x00: create a new module for rt2800 MMIO code
      rt2x00: rt2800pci: use rt2800mmio prefix for TX descriptor functions
      rt2x00: rt2800pci: move TX descriptor functions to the rt2800mmio mod=
ule
      rt2x00: rt2800pci: use rt2800mmio prefix for RX control handler funct=
ions
      rt2x00: rt2800pci: move RX control handler functions to the rt2800mmi=
o module
      rt2x00: rt2800pci: use rt2800mmio prefix for interrupt functions
      rt2x00: rt2800pci: move interrupt functions to the rt2800mmio module
      rt2x00: rt2800pci: use rt2800mmio prefix for queue functions
      rt2x00: rt2800pci: move queue functions to the rt2800mmio module
      rt2x00: rt2800pci: use rt2800mmio prefix for initialization functions
      rt2x00: rt2800pci: move initialization functions to the rt2800mmio mo=
dule
      rt2x00: rt2800pci: use separate ops for the SoC driver
      rt2x00: rt2800pci: use separate read_eeprom callback for SoC devices
      rt2x00: rt2800pci: use separate firmware callbacks for SoC devices
      rt2x00: rt2800pci: use separate set_state callback for SoC devices
      rt2x00: rt2800pci: rename rt2800pci_disable_radio function
      rt2x00: rt2800pci: split rt2800pci_enable_radio function
      rt2x00: rt2800pci: move rt2800mmio_enable_radio function to another m=
odule
      rt2x00: rt2800pci: use separate hwcrypt_disabled callback for SoC dev=
ices
      rt2x00: rt2800pci: move SoC specific code into a separate module
      rt2x00: rt2800pci: use module_pci_driver macro

Idan Kahlon (1):
      iwlwifi: mvm: NVM - increase max section size

Janusz Dziedzic (4):
      ath9k: dfs kill ath9k specyfic code
      ath9k: dfs move ath_dfs_pool_stats
      ath9k: dfs use CFG80211_CERTIFICATION_ONUS flag
      ath9k/ath: move dfs pattern detector to ath

Jingoo Han (1):
      wireless: iwlwifi: remove unnecessary pci_set_drvdata()

Joe Perches (3):
      NFC: Replace nfc_dev_dbg with dev_dbg
      NFC: Convert nfc_dev_info and nfc_dev_err to nfc_<level>
      NFC: Standardize logging style

Johan Hedberg (17):
      Bluetooth: Rename HCI_LE_PERIPHERAL to HCI_ADVERTISING
      Bluetooth: Add public mgmt function to send New Settings event
      Bluetooth: Fix re-enabling advertising after a connection
      Bluetooth: Fix changing advertising setting while LE is connected
      Bluetooth: Fix potential double-frees of L2CAP skbs
      Bluetooth: Fix checking for HCI_SETUP flag when receiving mgmt comman=
ds
      Bluetooth: Reorganize set_connectable HCI command sending
      Bluetooth: Move more logic into set_connectable complete callback
      Bluetooth: Add missing error handling for Set Connectable
      Bluetooth: Move static advertising functions to avoid forward declara=
tions
      Bluetooth: Fix updating advertising data needlessly
      Bluetooth: Make Set Connectable also update the LE advertising type
      Bluetooth: Move set_bredr_scan() to avoid forward declaration
      Bluetooth: Fix updating scan mode in set_bredr()
      Bluetooth: Convert Set Discoverable to use an asynchronous request
      Bluetooth: Reject invalid bdaddr types for sockets
      Bluetooth: Check that bind() bdaddr type matches connect()

Johannes Berg (11):
      iwlwifi: mvm: implement beacon filtering testmode command
      iwlwifi: mvm: query firmware for non-QoS seqno
      iwlwifi: mvm: give client MACs time to synchronise during restart
      iwlwifi: mvm: fix locking in iwl_mvm_bt_rssi_event()
      iwlwifi: mvm: implement new IPv6 offload API
      Bluetooth: Fix variable shadow warnings
      Merge remote-tracking branch 'wireless-next/master' into HEAD
      iwlwifi: mvm: keep connection to AP after WoWLAN
      iwlwifi: pcie: poke device when commands don't complete quickly
      iwlwifi: mvm: add IBSS support
      mac80211: disable WMM with invalid parameters

John W. Linville (8):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge tag 'nfc-next-3.13-1' of git://git.kernel.org/.../sameo/nfc-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Kalle Valo (6):
      ath10k: rename board_data in struct ath10k
      ath10k: store separate pointers for firmware data
      ath10k: implement firmware IE container support
      ath10k: fix ath10k_debug_start() locking
      ath10k: fix ath10k_bss_assoc() to not sleep in atomic context
      ath10k: add might_sleep() to ath10k_wmi_cmd_send()

Lorenzo Bianconi (2):
      ath9k: add noise floor parameter to ath9k_hw_getchan_noise
      ath9k: add HT40 spectral scan capability

Luciano Coelho (1):
      iwlwifi: mvm: fix fw_rx_stats debugfs entry

Luis R. Rodriguez (6):
      cfg80211: export reg_initiator_name()
      ath: move common dynamic regulatory domain setting to a helper
      ath: split user and driver reguluatory hint parsing
      ath: add support for proper dynamic regulatory hints
      ath9k: check for NULL rate when using ieee80211_get_rts_cts_rate()
      ath9k: add TX99 support

Marcel Holtmann (117):
      Bluetooth: Fix controller list for AMP discover response
      Bluetooth: Remove useless external function to count controllers
      Bluetooth: Add constants for AMP controller type
      Bluetooth: Separate AMP controller type from HCI device type
      Bluetooth: Use explicit AMP controller id value for BR/EDR
      Bluetooth: Rename AMP status constants and use them
      Bluetooth: Remove pointless inline function
      Bluetooth: Remove check for number of AMP controller
      Bluetooth: Move hci_amp_capable() function into L2CAP core
      Bluetooth: Simplify check if L2CAP connection is AMP capable
      Bluetooth: Check for non BR/EDR controller in AMP discover response
      Bluetooth: Reject enabling controllers without valid addresses
      Bluetooth: Use explicit check for BR/EDR device type
      Bluetooth: Simplify device type check for AMP discover response
      Bluetooth: Use random address if public address is not available
      Bluetooth: Add HCI structure for LE advertising parameters command
      Bluetooth: Make it clear that disabling LE disables advertising
      Bluetooth: Use helper functions for enabling/disabling advertising
      Bluetooth: Add constants for LE advertising types
      Bluetooth: Set LE advertising parameters before enabling it
      Bluetooth: Use helper function for re-enabling advertising
      Bluetooth: Remove no longer needed mgmt_new_settings() function
      Bluetooth: Remove mgmt_valid_hdev() helper function
      Bluetooth: Send new settings only when pairable changes
      Bluetooth: Make mgmt_index_added() and mgmt_index_removed() return vo=
id
      Bluetooth: Make mgmt_set_powered_failed() return void
      Bluetooth: Make mgmt_disconnect_failed() return void
      Bluetooth: Make mgmt_connect_failed() return void
      Bluetooth: Make mgmt_device_connected() return void
      Bluetooth: Make mgmt_device_disconnected() return void
      Bluetooth: Make mgmt_device_found() return void
      Bluetooth: Make mgmt_remote_name() return void
      Bluetooth: Make mgmt_discovering() return void
      Bluetooth: Power off AMP controllers after setup phase
      Bluetooth: Make mgmt power down notification for BR/EDR explicit
      Bluetooth: List powered down AMP controllers correctly
      Bluetooth: Read supported features and commands on AMP controllers
      Bluetooth: Read location data on AMP controller init
      Bluetooth: Read flow control mode on AMP controller init
      Bluetooth: Remove unneeded val variable when setting SSP
      Bluetooth: Restrict high speed support to SSP enabled controllers
      Bluetooth: Fix too long line with set_advertising() function
      Bluetooth: Use hci_conn_num() for checking number of LE connections
      Bluetooth: Use hci_conn_num() instead of direct connection hash access
      Bluetooth: AMP contollers do not support the legacy ioctls
      Bluetooth: Remove unused bfusb_ioctl() callback
      Bluetooth: Remove unused bluecard_hci_ioctl() callback
      Bluetooth: Remove unused bt3c_hci_ioctl() callback
      Bluetooth: Remove unused btuart_hci_ioctl() callback
      Bluetooth: Remove unused dtl1_hci_ioctl() callback
      Bluetooth: Remove unused btmrvl_ioctl() callback
      Bluetooth: Remove hdev->ioctl driver callback
      Bluetooth: Move amp.h header file into net/bluetooth/
      Bluetooth: Move a2mp.h header file into net/bluetooth/
      Bluetooth: Move smp.h header file into net/bluetooth/
      Bluetooth: Move skb->dev assignment for hdev->send into central place
      Bluetooth: Remove pointless check of hci_send_frame parameter
      Bluetooth: Remove return value from hci_send_frame() function
      Bluetooth: Remove unused h4_check_data_len() function
      Bluetooth: Provide hdev parameter to hci_recv_frame() driver callback
      Bluetooth: Add hdev parameter to hdev->send driver callback
      Bluetooth: Remove pointless parameter check in bfusb_send_frame()
      Bluetooth: Remove pointless parameter check in bluecard_hci_send_fram=
e()
      Bluetooth: Remove pointless parameter check in bt3c_hci_send_frame()
      Bluetooth: Remove pointless parameter check in btmrvl_send_frame()
      Bluetooth: Remove pointless parameter check in btuart_hci_send_frame()
      Bluetooth: Remove pointless parameter check in dtl1_hci_send_frame()
      Bluetooth: Remove pointless parameter check in hci_uart_send_frame()
      Bluetooth: Remove pointless parameter check in vhci_send_frame()
      Bluetooth: Declare btusb_table[] and blacklist_table[] as const
      Bluetooth: Declare bfusb_table[] as const
      Bluetooth: Declare bpa10x_table[] as const
      Bluetooth: Declare ath3k_table[] and ath3k_blist_tbl[] as const
      Bluetooth: Make LE scan interval and window a controller option
      Bluetooth: Add management command for setting LE scan parameters
      Bluetooth: Fix endless loop with HCI_QUIRK_RESET_ON_CLOSE
      Bluetooth: Don't advertise high speed support without SSP
      Bluetooth: Add MGMT_OP_SET_SCAN_PARAMS to supported commands list
      Bluetooth: Fix HCI init for 1st generation BlueFRITZ! devices
      Bluetooth: Fix PSM value for L2CAP connectionless data packets
      Bluetooth: Limit security mode 4 level 0 to connection oriented chann=
els
      Bluetooth: Allow 3D profile to use security mode 4 level 0
      Bluetooth: The L2CAP fixed channel connectionless data is supported
      Bluetooth: Unicast connectionless data reception is supported
      Bluetooth: Remove l2cap_conn->dst usage from AMP manager
      Bluetooth: Remove l2cap_conn->src and l2cap_conn->dst usage from SMP
      Bluetooth: Remove l2cap_conn->src and l2cap_conn->dst usage from L2CAP
      Bluetooth: Remove l2cap_conn->src and l2cap_conn->dst pointers
      Bluetooth: Remove pointless bdaddr_to_le() helper function
      Bluetooth: Store the source address type of LE connections
      Bluetooth: Store source address of HCI connections
      Bluetooth: Update source address and type for incoming LE connections
      Bluetooth: Use hci_conn->src address for SMP functions
      Bluetooth: Use hci_conn->src address for L2CAP functions
      Bluetooth: Fix input address type for SMP C1 function
      Bluetooth: Fix coding style violations in SMP handling
      Bluetooth: Update L2CAP socket source address from HCI connection
      Bluetooth: Store address information in L2CAP channel structure
      Bluetooth: Return the correct address type for L2CAP sockets
      Bluetooth: Access RFCOMM session addresses through L2CAP channel
      Bluetooth: Access CMTP session addresses through L2CAP channel
      Bluetooth: Access HIDP session addresses through L2CAP channel
      Bluetooth: Access BNEP session addresses through L2CAP channel
      Bluetooth: Use SCO addresses from HCI connection directly
      Bluetooth: Store SCO address information in its own socket structure
      Bluetooth: Store RFCOMM address information in its own socket structu=
re
      Bluetooth: Remove src and dst fields from bt_sock structure
      Bluetooth: Use l2cap_pi(sk) directly where possible
      Bluetooth: Add support for per socket msg_name callback
      Bluetooth: Provide msg_name callback for L2CAP connectionless channels
      Bluetooth: Increase minor version of core module
      Bluetooth: Adjust header for proc socket information
      Bluetooth: Introduce L2CAP channel flag for defer setup
      Bluetooth: Introduce L2CAP channel callback for resuming
      Bluetooth: Check that scan window is smaller or equal than scan inter=
val
      Bluetooth: Read number of supported IAC on controller setup
      Bluetooth: Read current IAC LAP on controller setup

Marek Puzyniak (1):
      ath10k: make monitor vdev down before stoping it

Max Stepanov (1):
      iwlwifi: mvm: split ADD_STA and ADD_STA_KEY in firmware API

Michal Kazior (12):
      ath10k: split tid calculation from tx function
      ath10k: split vdev_id calculation from tx function
      ath10k: remove ce_sendlist_send
      ath10k: remove num_sends_allowed
      ath10k: fix printf format string
      ath10k: fix possible memory leak in new FW loading
      ath10k: fix RX performance when using AP 10.X FW
      ath10k: use workqueue to set WEP TX key
      ath10k: fix add_interface failure handling
      ath10k: track vif list internally
      ath10k: fix scheduling while atomic config bug
      ath10k: remove unnecessary checks

Olivier Guiter (3):
      NFC: pn533: Add MI/TG bits only when in Initiator mode
      NFC: pn533: Add support for incoming fragmented frame in target mode
      NFC: pn533: Target mode Tx fragmentation support

Oren Givon (1):
      iwlwifi: mvm: debugfs: add an option to set antennas for scan command

Sachin Kamat (2):
      NFC: nfcwilink: Remove redundant dev_set_drvdata
      NFC: pn533: Staticize local symbols

Samuel Ortiz (9):
      NFC: Set active target upon DEP up event reception
      NFC: pn533: Send ATR_REQ directly for active device detection
      NFC: pn533: Start listen timer from start_poll
      NFC: digital: Remove PR_ERR and PR_DBG macros
      NFC: digital: Add newline to pr_* calls
      NFC: Document NFC targets sens_res field
      NFC: Define secure element IO API and commands
      NFC: netlink: SE API implementation
      NFC: Fix SE API related sparse warning

Stanislaw Gruszka (4):
      iwlwifi: don't WARN on bad firmware state
      rt2400pci: fix RSSI read
      rt2x00: check if device is still available on rt2x00mac_flush()
      rt2800usb: slow down TX status polling

Sujith Manoharan (1):
      ath10k: Fix bug in max. VHT A-MPDU size

Thierry Escande (12):
      NFC: Digital Protocol stack implementation
      NFC Digital: Implement driver commands mechanism
      NFC Digital: Add NFC-A technology support
      NFC Digital: Add NFC-F technology support
      NFC Digital: Add initiator NFC-DEP support
      NFC Digital: Add target NFC-DEP support
      NFC: rawsock: Fix a memory leak
      NFC: digital: Fix sens_res endiannes handling
      NFC: Sony Port-100 Series driver
      NFC: port100: Commands mechanism implementation
      NFC: port100: Add initiator mode support
      NFC: port100: Add target mode support

Vladimir Murzin (1):
      ath6kl: fix compilation warning in ath6kl_htc_pipe_conn_service

 drivers/bluetooth/ath3k.c                          |    4 +-
 drivers/bluetooth/bfusb.c                          |   31 +-
 drivers/bluetooth/bluecard_cs.c                    |   30 +-
 drivers/bluetooth/bpa10x.c                         |   11 +-
 drivers/bluetooth/bt3c_cs.c                        |   30 +-
 drivers/bluetooth/btmrvl_main.c                    |   26 +-
 drivers/bluetooth/btmrvl_sdio.c                    |    8 +-
 drivers/bluetooth/btsdio.c                         |    6 +-
 drivers/bluetooth/btuart_cs.c                      |   30 +-
 drivers/bluetooth/btusb.c                          |   21 +-
 drivers/bluetooth/btwilink.c                       |    9 +-
 drivers/bluetooth/dtl1_cs.c                        |   30 +-
 drivers/bluetooth/hci_bcsp.c                       |    5 +-
 drivers/bluetooth/hci_h4.c                         |   24 -
 drivers/bluetooth/hci_h5.c                         |    2 +-
 drivers/bluetooth/hci_ldisc.c                      |   12 +-
 drivers/bluetooth/hci_ll.c                         |   14 +-
 drivers/bluetooth/hci_vhci.c                       |   15 +-
 drivers/net/wireless/ath/Kconfig                   |   17 +
 drivers/net/wireless/ath/Makefile                  |    4 +-
 drivers/net/wireless/ath/ath10k/ce.c               |   35 +-
 drivers/net/wireless/ath/ath10k/ce.h               |   16 +-
 drivers/net/wireless/ath/ath10k/core.c             |  285 +++-
 drivers/net/wireless/ath/ath10k/core.h             |   47 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   15 +-
 drivers/net/wireless/ath/ath10k/debug.h            |    5 +
 drivers/net/wireless/ath/ath10k/htt_tx.c           |    4 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   56 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  512 ++++---
 drivers/net/wireless/ath/ath10k/mac.h              |    2 +
 drivers/net/wireless/ath/ath10k/pci.c              |   25 +-
 drivers/net/wireless/ath/ath10k/pci.h              |    3 -
 drivers/net/wireless/ath/ath10k/wmi.c              | 1087 +++++++++++++-
 drivers/net/wireless/ath/ath10k/wmi.h              |  968 ++++++++++++-
 drivers/net/wireless/ath/ath5k/base.c              |    6 +-
 drivers/net/wireless/ath/ath6kl/htc.h              |    2 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |   20 +
 drivers/net/wireless/ath/ath9k/Makefile            |    4 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |   22 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   95 ++
 drivers/net/wireless/ath/ath9k/ath9k.h             |   39 +
 drivers/net/wireless/ath/ath9k/calib.c             |   10 +-
 drivers/net/wireless/ath/ath9k/calib.h             |    3 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  118 ++
 drivers/net/wireless/ath/ath9k/dfs.h               |    2 +-
 drivers/net/wireless/ath/ath9k/dfs_debug.c         |    9 +-
 drivers/net/wireless/ath/ath9k/dfs_debug.h         |   16 -
 drivers/net/wireless/ath/ath9k/hw-ops.h            |   16 +
 drivers/net/wireless/ath/ath9k/hw.c                |    2 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    4 +
 drivers/net/wireless/ath/ath9k/init.c              |   30 +-
 drivers/net/wireless/ath/ath9k/link.c              |   15 +-
 drivers/net/wireless/ath/ath9k/main.c              |  160 +-
 drivers/net/wireless/ath/ath9k/recv.c              |  149 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   56 +-
 .../ath/{ath9k =3D> }/dfs_pattern_detector.c         |   23 +-
 .../ath/{ath9k =3D> }/dfs_pattern_detector.h         |   28 +-
 .../wireless/ath/{ath9k =3D> }/dfs_pri_detector.c    |    8 +-
 .../wireless/ath/{ath9k =3D> }/dfs_pri_detector.h    |    2 +
 drivers/net/wireless/ath/regd.c                    |  140 +-
 drivers/net/wireless/atmel.c                       |    2 +-
 drivers/net/wireless/b43/phy_n.c                   |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |  186 ++-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |   17 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  111 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |    6 +-
 .../net/wireless/brcm80211/brcmfmac/tracepoint.h   |   21 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |   14 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   14 +
 drivers/net/wireless/iwlwifi/iwl-config.h          |    1 +
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   32 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   37 +
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |    4 +
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   26 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    2 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   22 +-
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c         |  632 +++++---
 drivers/net/wireless/iwlwifi/mvm/constants.h       |    4 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |  515 ++++++-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  206 ++-
 drivers/net/wireless/iwlwifi/mvm/fw-api-bt-coex.h  |  149 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |   69 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-mac.h      |   11 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |   29 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-rs.h       |   21 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |   34 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h      |   55 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   16 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   23 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   75 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  242 +++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   88 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |  101 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   60 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |   70 +-
 drivers/net/wireless/iwlwifi/mvm/quota.c           |   42 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  793 +++++-----
 drivers/net/wireless/iwlwifi/mvm/rs.h              |  154 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   21 +
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  462 +++++-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |  206 ++-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |    4 -
 drivers/net/wireless/iwlwifi/mvm/testmode.h        |   95 ++
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |    5 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.h      |    4 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   49 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |    2 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |    8 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  127 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   34 +-
 drivers/net/wireless/libertas/firmware.c           |    5 +
 drivers/net/wireless/libertas/if_cs.c              |    8 +-
 drivers/net/wireless/libertas/if_sdio.c            |    8 +-
 drivers/net/wireless/libertas/if_spi.c             |    4 -
 drivers/net/wireless/libertas/if_usb.c             |   17 +-
 drivers/net/wireless/rt2x00/Kconfig                |   27 +-
 drivers/net/wireless/rt2x00/Makefile               |    2 +
 drivers/net/wireless/rt2x00/rt2400pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |   73 +-
 drivers/net/wireless/rt2x00/rt2800mmio.c           |  873 +++++++++++
 drivers/net/wireless/rt2x00/rt2800mmio.h           |  165 +++
 drivers/net/wireless/rt2x00/rt2800pci.c            |  951 +-----------
 drivers/net/wireless/rt2x00/rt2800pci.h            |   97 --
 drivers/net/wireless/rt2x00/rt2800soc.c            |  263 ++++
 drivers/net/wireless/rt2x00/rt2800usb.c            |   12 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    3 +
 drivers/nfc/Kconfig                                |   10 +
 drivers/nfc/Makefile                               |    1 +
 drivers/nfc/mei_phy.c                              |    6 +-
 drivers/nfc/microread/i2c.c                        |   32 +-
 drivers/nfc/microread/mei.c                        |    4 +-
 drivers/nfc/microread/microread.c                  |    7 +-
 drivers/nfc/nfcsim.c                               |   38 +-
 drivers/nfc/nfcwilink.c                            |   97 +-
 drivers/nfc/pn533.c                                |  604 +++++---
 drivers/nfc/pn544/i2c.c                            |   42 +-
 drivers/nfc/pn544/pn544.c                          |  129 +-
 drivers/nfc/port100.c                              | 1529 ++++++++++++++++=
++++
 include/net/bluetooth/bluetooth.h                  |    5 +-
 include/net/bluetooth/hci.h                        |   49 +-
 include/net/bluetooth/hci_core.h                   |   79 +-
 include/net/bluetooth/l2cap.h                      |   14 +-
 include/net/bluetooth/mgmt.h                       |    7 +
 include/net/bluetooth/rfcomm.h                     |    2 +
 include/net/bluetooth/sco.h                        |    5 +-
 include/net/cfg80211.h                             |    9 +
 include/net/nfc/digital.h                          |  227 +++
 include/net/nfc/hci.h                              |    6 -
 include/net/nfc/nci.h                              |    4 +
 include/net/nfc/nci_core.h                         |   46 +-
 include/net/nfc/nfc.h                              |   25 +-
 include/uapi/linux/nfc.h                           |    4 +
 net/bluetooth/a2mp.c                               |   63 +-
 {include/net =3D> net}/bluetooth/a2mp.h              |    0
 net/bluetooth/af_bluetooth.c                       |   23 +-
 net/bluetooth/amp.c                                |   10 +-
 {include/net =3D> net}/bluetooth/amp.h               |    0
 net/bluetooth/bnep/core.c                          |   18 +-
 net/bluetooth/cmtp/core.c                          |    6 +-
 net/bluetooth/hci_conn.c                           |  156 +-
 net/bluetooth/hci_core.c                           |  156 +-
 net/bluetooth/hci_event.c                          |  103 +-
 net/bluetooth/hci_sock.c                           |   10 +-
 net/bluetooth/hidp/core.c                          |   18 +-
 net/bluetooth/l2cap_core.c                         |  221 +--
 net/bluetooth/l2cap_sock.c                         |   86 +-
 net/bluetooth/mgmt.c                               |  550 ++++---
 net/bluetooth/rfcomm/core.c                        |   19 +-
 net/bluetooth/rfcomm/sock.c                        |   28 +-
 net/bluetooth/sco.c                                |   44 +-
 net/bluetooth/smp.c                                |   81 +-
 {include/net =3D> net}/bluetooth/smp.h               |    0
 net/mac80211/ieee80211_i.h                         |    1 +
 net/mac80211/mlme.c                                |   95 +-
 net/mac80211/rate.c                                |   15 +-
 net/nfc/Kconfig                                    |   14 +
 net/nfc/Makefile                                   |    2 +
 net/nfc/core.c                                     |   22 +-
 net/nfc/digital.h                                  |  170 +++
 net/nfc/digital_core.c                             |  737 ++++++++++
 net/nfc/digital_dep.c                              |  729 ++++++++++
 net/nfc/digital_technology.c                       |  770 ++++++++++
 net/nfc/nci/spi.c                                  |  239 ++-
 net/nfc/netlink.c                                  |   91 ++
 net/nfc/rawsock.c                                  |    7 +-
 net/wireless/reg.c                                 |   27 +-
 186 files changed, 15085 insertions(+), 4189 deletions(-)
 rename drivers/net/wireless/ath/{ath9k =3D> }/dfs_pattern_detector.c (95%)
 rename drivers/net/wireless/ath/{ath9k =3D> }/dfs_pattern_detector.h (87%)
 rename drivers/net/wireless/ath/{ath9k =3D> }/dfs_pri_detector.c (98%)
 rename drivers/net/wireless/ath/{ath9k =3D> }/dfs_pri_detector.h (97%)
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/testmode.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2800mmio.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2800mmio.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2800soc.c
 create mode 100644 drivers/nfc/port100.c
 create mode 100644 include/net/nfc/digital.h
 rename {include/net =3D> net}/bluetooth/a2mp.h (100%)
 rename {include/net =3D> net}/bluetooth/amp.h (100%)
 rename {include/net =3D> net}/bluetooth/smp.h (100%)
 create mode 100644 net/nfc/digital.h
 create mode 100644 net/nfc/digital_core.c
 create mode 100644 net/nfc/digital_dep.c
 create mode 100644 net/nfc/digital_technology.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--TB36FDmn/VVEgNH/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSeAIRAAoJEJctW/TcYTgGzSkP/2mnJPjOOmEzQK9H+C0s414H
N93lQpisLbEaYoCu3mtDRxy9OtoUyLN3CgVTYFJQuNPtT5u4Kh8CAIKC/i8vH501
cGQvn4LjmIyWST849O4eoGK/F0wh4yfO8xHdQgJvyZriLC8AJJ6r6dQsE4m4aCa6
nEVbewIIt7lYj1fyrzmBmBFCsLZjHomRQ5sG2BF/PzwXqyvQ1z3an91ZECg+k0Rm
4ITAwfKer2JnfBMm2jd55N+6XSFZxBxll5AnL0cV1/0YUBH45i7FDrfwwJjRdHXl
fLvmVKcfdepghjjGPDuQSLNk5spGBFLluFUKcsAKQoH0tKUKLgA/wWwrn0bmRFep
I4FMg4FblOevfYNpPq1rJD/bd872XX9dpEVNNcezisSdvuz4yTMu0dISmdUjq2r6
gaGxiN6lKbtC/NyKX2uP1L6/TTNj05RA54th/QLRYEPhM+vxGi1XRf49x2ocrVrE
/hb/JrtJuYmzQZ5bXbwojlBFwUCyNnga3hc3WplQbOFlGExxzXv4UYwlfs4c5Bni
yLIy6v5OVjBSLz1uoa7woxuNyAC1ls9G4+0skXTD7UtOmqfTVnx6tb0Tx9ULvANP
lI1oixfsqri+2+ZfdoYhRdoliGAIuUY2s7Z7B5zfxloyd/JpO6KepljNxUcaEfiw
nW2g8cuPlcgCbLviFVdA
=op4p
-----END PGP SIGNATURE-----

--TB36FDmn/VVEgNH/--
