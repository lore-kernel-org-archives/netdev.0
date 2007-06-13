From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 12 Jun 2007 23:06:20 -0400
Message-ID: <20070613030620.GA32762@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:49258 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753443AbXFMDGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 23:06:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is a resend of the submission from June 9th, along with added stuff:
* big update to new (in 2.6.22) wireless driver libertas
* revert e100 's-bit' change; see commit message for more info
* more myri, NetXen fixes

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/e100.c                         |   72 ++-
 drivers/net/ehea/ehea.h                    |    2 +-
 drivers/net/ehea/ehea_main.c               |   12 +-
 drivers/net/ibmveth.c                      |   80 +-
 drivers/net/myri10ge/myri10ge.c            |   29 +-
 drivers/net/netxen/netxen_nic.h            |   48 +-
 drivers/net/netxen/netxen_nic_ethtool.c    |    8 +-
 drivers/net/netxen/netxen_nic_hw.c         |   12 +-
 drivers/net/netxen/netxen_nic_init.c       |   44 +-
 drivers/net/netxen/netxen_nic_isr.c        |   24 +
 drivers/net/netxen/netxen_nic_main.c       |    7 +
 drivers/net/netxen/netxen_nic_niu.c        |    8 +-
 drivers/net/phy/marvell.c                  |   62 +-
 drivers/net/usb/Kconfig                    |    4 +-
 drivers/net/via-velocity.c                 |    2 +-
 drivers/net/wireless/Kconfig               |   19 +-
 drivers/net/wireless/libertas/11d.c        |  152 ++--
 drivers/net/wireless/libertas/11d.h        |    6 +-
 drivers/net/wireless/libertas/Makefile     |    4 +-
 drivers/net/wireless/libertas/README       |   52 +-
 drivers/net/wireless/libertas/assoc.c      |  358 +++++---
 drivers/net/wireless/libertas/assoc.h      |   10 +-
 drivers/net/wireless/libertas/cmd.c        |  559 +++++------
 drivers/net/wireless/libertas/cmdresp.c    |  376 ++++----
 drivers/net/wireless/libertas/debugfs.c    |  432 ++++----
 drivers/net/wireless/libertas/decl.h       |   20 +-
 drivers/net/wireless/libertas/defs.h       |  101 ++-
 drivers/net/wireless/libertas/dev.h        |   99 +-
 drivers/net/wireless/libertas/ethtool.c    |   55 +-
 drivers/net/wireless/libertas/fw.c         |  111 +--
 drivers/net/wireless/libertas/fw.h         |   13 -
 drivers/net/wireless/libertas/host.h       |   17 +-
 drivers/net/wireless/libertas/hostcmd.h    |  392 ++++----
 drivers/net/wireless/libertas/if_bootcmd.c |    6 +-
 drivers/net/wireless/libertas/if_usb.c     |  448 +++++----
 drivers/net/wireless/libertas/if_usb.h     |   32 +-
 drivers/net/wireless/libertas/ioctl.c      |  286 ++++--
 drivers/net/wireless/libertas/join.c       |  464 ++++-----
 drivers/net/wireless/libertas/join.h       |   13 +-
 drivers/net/wireless/libertas/main.c       |  690 ++++++-------
 drivers/net/wireless/libertas/rx.c         |   64 +-
 drivers/net/wireless/libertas/sbi.h        |   40 -
 drivers/net/wireless/libertas/scan.c       | 1529 +++++++++++++---------------
 drivers/net/wireless/libertas/scan.h       |   81 +-
 drivers/net/wireless/libertas/thread.h     |    8 +-
 drivers/net/wireless/libertas/tx.c         |   74 +-
 drivers/net/wireless/libertas/types.h      |   63 +-
 drivers/net/wireless/libertas/wext.c       |  778 ++++++++-------
 drivers/net/wireless/libertas/wext.h       |   13 +-
 49 files changed, 4001 insertions(+), 3778 deletions(-)
 delete mode 100644 drivers/net/wireless/libertas/fw.h
 delete mode 100644 drivers/net/wireless/libertas/sbi.h

Brian King (2):
      ibmveth: Fix h_free_logical_lan error on pool resize
      ibmveth: Automatically enable larger rx buffer pools for larger mtu

Brice Goglin (3):
      myri10ge: limit the number of recoveries
      myri10ge: report when the link partner is running in Myrinet mode
      myri10ge: update driver version

Chris Ball (1):
      libertas: wakeup both mesh and normal wakeup when getting out of scan

Dan Williams (26):
      libertas: call SET_NETDEV_DEV from common code
      libertas: replace 'macaddress' with 'bssid'
      libertas: correctly unregister mesh netdev on error
      libertas: don't tear down netdev in libertas_activate_card
      libertas: make scan result handling more flexible
      libertas: fix 'keep previous scan' behavior
      libertas: move channel changing into association framework
      libertas: make association paths consistent
      libertas: use MAC_FMT and MAC_ARG where appropriate
      libertas: use compare_ether_addr() rather than memcmp() where appropriate
      libertas: fix debug enter/leave prints for libertas_execute_next_command
      libertas: correctly balance locking in libertas_process_rx_command
      libertas: correct error report paths for wlan_fwt_list_ioctl
      libertas: fix deadlock SIOCGIWSCAN handler
      libertas: fix default adhoc channel
      libertas: honor specific channel requests during association
      libertas: send SIOCGIWSCAN event after partial scans too
      libertas: debug print spacing fixes in assoc.c
      libertas: add more verbose debugging to libertas_cmd_80211_authenticate
      libertas: Make WPA work through supplicant handshake
      libertas: sparse fixes
      libertas: tweak association debug output
      libertas: remove structure WLAN_802_11_SSID and libertas_escape_essid
      libertas: remove WPA_SUPPLICANT structure
      libertas: reduce SSID and BSSID mixed-case abuse
      libertas: actually send mesh frames to mesh netdev

Dave Jones (1):
      typo in via-velocity.c

David Woodhouse (6):
      libertas: fix character set in README
      libertas: first pass at fixing up endianness issues
      libertas: More endianness fixes.
      libertas: more endianness fixes, in tx.c this time
      libertas: don't byte-swap firmware version number. It's a byte array.
      libertas: fix big-endian associate command.

Holger Schurig (23):
      libertas: rename wlan_association_worker
      libertas: a debug output was missing a newline
      libertas: fix removal of all debugfs files
      libertas: remove __FILE__ from debug output
      libertas: remove unused/superfluous definitions of DEV_NAME_LEN
      libertas: move vendor & product id's into if_usb.c
      libertas: make libertas_wlan_data_rates static
      libertas: exclude non-used code when PROC_DEBUG is not set
      libertas: make debug configurable
      libertas: tune debug code
      libertas: single out mesh code
      libertas: change debug output of libertas_interrupt()
      libertas: get rid of libertas_sbi_get_priv()
      libertas: fix SSID output
      libertas: changed some occurences of kmalloc() + memset(&a,0,sz) to kzalloc()
      libertas: move reset_device() code main.c to if_usb.c
      libertas: split wlan_add_card()
      libertas: indirect all hardware access via hw_XXXX functions
      libertas: move contents of fw.h to decl.h
      libertas: split module into two (libertas.ko and usb8xxx.ko)
      libertas: fix RESET logic at unload time
      libertas: let DRV_NAME be overridable
      libertas: remove unused variables in wlan_dev_t

Javier Cardona (2):
      libertas: fixed transmission flow control on the mesh interface
      libertas: added transmission failures to mesh statistics

Jeff Garzik (1):
      Revert "[netdrvr e100] experiment with doing RX in a similar manner to eepro100"

Kim Phillips (1):
      phylib: add RGMII-ID mode to the Marvell m88e1111 PHY to fix broken ucc_geth

Luis Carlos (1):
      libertas: convert libertas_mpp into anycast_mask

Luis Carlos Cobo (4):
      libertas: fixed incorrect assigment of fcs errors to frag errors
      libertas: add URB debug info
      libertas: fixed kernel oops on module/card removal
      libertas: updated mesh commands for 5.220.9.p11

Luis Carlos Cobo Rus (8):
      libertas: version bump (321p0) and cmds update for new fw (5.220.10.p0)
      libertas: cleanup of fwt_list_route processing
      libertas: updated readme file
      libertas: make mac address configuration work with mesh interface too
      libertas: split wext for eth and msh
      libertas: support for mesh autostart on firmware 5.220.11
      libertas: pull current channel from firmware on mesh autostart
      libertas: deauthenticate from AP in channel switch

Marcelo Tosatti (5):
      libertas: scan two channels per scan command
      libertas: remove deprecated pm_register and associated code
      libertas: fix scanning from associate path
      libertas: fix error handling of card initialization
      libertas: fix oops on rmmod

Mithlesh Thukral (3):
      NetXen: Fix ping issue after reboot on Blades with 3.4.19 firmware
      NetXen: Fix compile failure seen on PPC architecture
      NetXen: Fix link status messages

Sam Ravnborg (1):
      net: fix typo in drivers/net/usb/Kconfig

Thomas Klein (1):
      ehea: Fixed possible kernel panic on VLAN packet recv

[patch snipped, as it's too big for the ml; see git for changes]

