From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'libertas-upstream' branch of wireless-2.6
Date: Mon, 6 Aug 2007 16:30:05 -0400
Message-ID: <20070806203005.GL6442@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Got a big patch bomb from the libertas guys.  I tried to cherry-pick
some of the fixes for 2.6.23, but they either were fixes to problems
in new code or all the code cleanups made them difficult for me to
intelligently backport.

So, this is intended for 2.6.24...

---

The following changes since commit d4ac2477fad0f2680e84ec12e387ce67682c5c13:
  Linus Torvalds (1):
        Linux 2.6.23-rc2

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git libertas-upstream

Dan Williams (27):
      libertas: kill ieeetypes_capinfo bitfield, use ieee80211.h types
      libertas: rename WLAN_802_11_KEY to enc_key and clean up usage
      libertas: clean up indentation in libertas_association_worker
      libertas: clean up 802.11 IE post-scan handling
      libertas: remove if_bootcmd.c
      libertas: fix mixed-case abuse in cmd_ds_802_11_scan
      libertas: fix mixed-case abuse in cmd_ds_802_11_ad_hoc_result
      libertas: fix mixed-case abuse in cmd_ds_802_11_ad_hoc_start
      libertas: re-uppercase command defines and other constants
      libertas: fix debug build breakage due to field rename
      libertas: remove thread.h and make kthread usage clearer
      libertas: new mesh control knobs
      libertas: bump version to 322.p1
      libertas: fix more mixed-case abuse
      libertas: move generic firmware reset command to common code
      libertas: wlan_ -> libertas_ function prefix renames for main.c
      libertas: simplify and clean up data rate handling
      libertas: fix WEXT quality reporting
      libertas: send association events on adhoc reassociation
      libertas: push mesh beacon bit to userspace in scan results
      libertas: fix assignment of WEP key type
      libertas: push WEXT scan requests to a work queue
      libertas: fix misspelling in debug message
      libertas: ignore spurious mesh autostart events
      libertas: better descriptions for association errors
      libertas: fix sparse-reported problems
      libertas: bump driver version

Eugene Teo (1):
      drivers/net/wireless/libertas/cmd.c: fix adapter->driver_lock dereference

Holger Schurig (33):
      libertas: remove fw.c
      libertas: fix one more sparse warning
      libertas: make more functions static & remove unused functions
      libertas: uppercase some #defines
      libertas: access mesh_dev more carefully
      libertas: tune hardware info output
      libertas: remove debugmode
      libertas: make the hex dumper nicer
      libertas: remove a hundred CMD_RET_xxx definitions
      libertas: use LBS_DEB_HOST for host-to-card communications
      libertas: use LBS_DEB_HOST for host-to-card communications
      add support for Marvell 8385 CF cards
      libertas: remove unused adapter->prev_XXXX variables
      libertas: remove adapter->{rx,tx}antenna
      libertas: remove adapter->prescan
      libertas: remove adapter->scanprobes
      libertas: remove adapter->pkttxctrl
      libertas: remove adapter->txrate
      libertas: remove adapter->rxpd_rate
      libertas: remove adapter->{data,bcn}_avg_factor
      libertas: remove adapter->nullpktinterval
      libertas: remove adapter->locallisteninterval
      libertas: remove adapter->multipledtim
      libertas: remove adapter->atimwindow
      libertas: remove adapter->regiontableindex
      libertas: remove adapter->listeninterval
      libertas: remove adapter->adhoc_grate_enabled
      libertas: remove adapter->beaconperiod
      libertas: remove adapter->scanmode
      libertas: remove adapter->scantype
      libertas: remove bss_descriptior->networktsf
      libertas: remove bss_descriptor->timestamp
      libertas: fix two debug statements in cmdresp.c

Jean Tourrilhes (1):
      libertas: fix a few wext abuses...

Luis Carlos Cobo (7):
      libertas: specific mesh scan for mshX interface
      Support for mesh autostart deactivation through sysfs
      libertas: Avoid MESH_AUTOSTARTED spam on console
      libertas: revert CAPINFO_MASK to its original value
      libertas: keep mesh autostart enabled while asleep
      libertas: monitor mode support for OLPC firmware
      libertas: pass boot2 version to firmware

 drivers/net/wireless/Kconfig               |    7 +
 drivers/net/wireless/Makefile              |    2 +-
 drivers/net/wireless/libertas/11d.c        |  124 ++---
 drivers/net/wireless/libertas/11d.h        |    4 -
 drivers/net/wireless/libertas/Makefile     |    5 +-
 drivers/net/wireless/libertas/assoc.c      |   99 ++--
 drivers/net/wireless/libertas/assoc.h      |    2 +-
 drivers/net/wireless/libertas/cmd.c        |  664 +++++++++---------
 drivers/net/wireless/libertas/cmdresp.c    |  368 +++++------
 drivers/net/wireless/libertas/debugfs.c    |  137 ++--
 drivers/net/wireless/libertas/decl.h       |   18 +-
 drivers/net/wireless/libertas/defs.h       |  157 +++---
 drivers/net/wireless/libertas/dev.h        |   77 +--
 drivers/net/wireless/libertas/ethtool.c    |    8 +-
 drivers/net/wireless/libertas/fw.c         |  349 ----------
 drivers/net/wireless/libertas/host.h       |  445 ++++++-------
 drivers/net/wireless/libertas/hostcmd.h    |   81 +--
 drivers/net/wireless/libertas/if_bootcmd.c |   40 --
 drivers/net/wireless/libertas/if_cs.c      | 1005 ++++++++++++++++++++++++++++
 drivers/net/wireless/libertas/if_usb.c     |  209 +++++--
 drivers/net/wireless/libertas/if_usb.h     |    4 -
 drivers/net/wireless/libertas/join.c       |  474 +++++++------
 drivers/net/wireless/libertas/join.h       |   35 +-
 drivers/net/wireless/libertas/main.c       |  752 ++++++++++++++++++----
 drivers/net/wireless/libertas/rx.c         |   85 +--
 drivers/net/wireless/libertas/scan.c       |  585 +++++++----------
 drivers/net/wireless/libertas/scan.h       |   36 +-
 drivers/net/wireless/libertas/thread.h     |   52 --
 drivers/net/wireless/libertas/tx.c         |   41 +-
 drivers/net/wireless/libertas/types.h      |   67 +--
 drivers/net/wireless/libertas/wext.c       |  391 ++++--------
 drivers/net/wireless/libertas/wext.h       |    9 +-
 32 files changed, 3512 insertions(+), 2820 deletions(-)
 delete mode 100644 drivers/net/wireless/libertas/fw.c
 delete mode 100644 drivers/net/wireless/libertas/if_bootcmd.c
 create mode 100644 drivers/net/wireless/libertas/if_cs.c
 delete mode 100644 drivers/net/wireless/libertas/thread.h
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
