From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 31 Jul 2008 22:11:06 -0700 (PDT)
Message-ID: <20080731.221106.184794151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56002
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752407AbYHAFLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 01:11:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Highlights:

1) Fix lockdep warnings on multiqueue configurations.

2) Two tcp MD5 bug fixes from Adam Langley

3) Integrate a batch of networking patches Andrew dumped
   on my the other day.

4) Wired device driver fixes and updates via Jeff Garzik.

5) Build fix from Ingo.

6) Netfilter bug fixes from Pavel Emelyanov and Patrick McHardy.

Please pull, thanks a lot!

The following changes since commit 031cf19e6f63941506c9baf76ac7adac06edcf08:
  Robert P. J. Day (1):
        net: Make "networking" one-click deselectable.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adam Langley (2):
      tcp: MD5: Fix MD5 signatures on certain ACK packets
      tcp: MD5: Fix IPv6 signatures

Alan Cox (1):
      [netdrvr] wd: fix build breakage with new NS8390p API

Ayaz Abdulla (1):
      forcedeth bug fix: realtek phy 8211c errata

Breno Leitao (1):
      S2io: fix statistics flush after a MTU change

Bryan Wu (1):
      Blackfin EMAC Driver: enable TXDWA new feature for new silicon (rev > 0.2)

David Brownell (1):
      enc28j60: don't specify (wrong) IRQ type

David Howells (3):
      atm: fix const assignment/discard warnings in the ATM networking driver
      atm: fix direct casts of pointers to u32 in the InterPhase driver
      hysdn: remove the packed attribute from PofTimStamp_tag

David S. Miller (2):
      Merge branch 'upstream-davem' of master.kernel.org:/.../jgarzik/netdev-2.6
      netdev: Fix lockdep warnings in multiqueue configurations.

Harvey Harrison (3):
      net: use the common ascii hex helpers
      isdn: use the common ascii hex helpers
      irda: replace __FUNCTION__ with __func__

Ingo Molnar (1):
      net/ipv4/route.c: fix build error

Jeff Garzik (1):
      Merge branch 'for-2.6.27' of git://git.marvell.com/mv643xx_eth into upstream-fixes

Julia Lawall (1):
      drivers/net/ehea/ehea_main.c: Release mutex in error handling code

Julius Volz (1):
      ipvs: Move userspace definitions to include/linux/ip_vs.h

Lennert Buytenhek (12):
      mv643xx_eth: fix TX hang erratum workaround
      mv643xx_eth: prevent breakage when link goes down during transmit
      mv643xx_eth: fix transmit-reclaim-in-napi-poll
      mv643xx_eth: don't fiddle with maximum receive packet size setting
      mv643xx_eth: also check TX_IN_PROGRESS when disabling transmit path
      mv643xx_eth: use longer DMA bursts
      mv643xx_eth: use symbolic MII register addresses and values
      mv643xx_eth: print driver version on init
      mv643xx_eth: use auto phy polling for configuring (R)(G)MII interface
      mv643xx_eth: print message on link status change
      mv643xx_eth: enable hardware TX checksumming with vlan tags
      mv643xx_eth: bump version to 1.2

Matthew Garrett (1):
      nsc-ircc: default to dongle type 9 on IBM hardware

Michael Frey (1):
      bluetooth: add quirks for a few hci_usb devices

Michael Hennerich (1):
      Blackfin EMAC Driver: Functional power management support

Mikael Pettersson (1):
      fix NE2000 linkage error

Mike Frysinger (1):
      Blackfin EMAC Driver: add proper __devinit/__devexit markings

Nobuhiro Iwamatsu (1):
      sh_eth: Add support of SH7763 to sh_eth

Patrick McHardy (1):
      netfilter: nf_conntrack_tcp: decrease timeouts while data in unacknowledged

Pavel Emelyanov (2):
      netfilter: ipt_recent: fix race between recent_mt_destroy and proc manipulations
      netfilter: xt_hashlimit: fix race between htable_destroy and htable_gc

Peter Korsgaard (1):
      dm9601: don't do usb transfers of data on stack

Rafael J. Wysocki (1):
      tg3: adapt tg3 to use reworked PCI PM code

Randy Dunlap (1):
      skbuff: add missing kernel-doc for do_not_encrypt

Simon Wunderlich (1):
      bridge: send correct MTU value in PMTU (revised)

Stephen Hemminger (2):
      blackfin_mac: unneeded assignment
      random32: seeding improvement

Steve Wise (1):
      cxgb3: Allow 64KB firmware images.

Wei Yongjun (1):
      ipv6: Fix ip6_xmit to send fragments if ipfragok is true

 arch/arm/mach-kirkwood/rd88f6281-setup.c     |    3 +
 arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c |    3 +
 arch/arm/mach-orion5x/rd88f5181l-ge-setup.c  |    3 +
 arch/arm/mach-orion5x/wnr854t-setup.c        |    3 +
 arch/arm/mach-orion5x/wrt350n-v2-setup.c     |    3 +
 drivers/atm/iphase.c                         |   40 ++--
 drivers/bluetooth/hci_usb.c                  |    7 +
 drivers/isdn/gigaset/isocdata.c              |    5 +-
 drivers/isdn/hysdn/hysdn_pof.h               |    2 +-
 drivers/net/Kconfig                          |    4 +-
 drivers/net/bfin_mac.c                       |  111 +++++--
 drivers/net/cxgb3/t3_hw.c                    |    2 +-
 drivers/net/ehea/ehea_main.c                 |    4 +-
 drivers/net/enc28j60.c                       |    6 +-
 drivers/net/forcedeth.c                      |   64 ++++-
 drivers/net/ifb.c                            |   12 +-
 drivers/net/irda/act200l-sir.c               |   10 +-
 drivers/net/irda/actisys-sir.c               |    2 +-
 drivers/net/irda/ali-ircc.c                  |  246 ++++++++--------
 drivers/net/irda/donauboe.c                  |   68 ++--
 drivers/net/irda/girbil-sir.c                |   12 +-
 drivers/net/irda/irda-usb.c                  |   92 +++---
 drivers/net/irda/irtty-sir.c                 |   10 +-
 drivers/net/irda/kingsun-sir.c               |    2 +-
 drivers/net/irda/litelink-sir.c              |    8 +-
 drivers/net/irda/ma600-sir.c                 |   16 +-
 drivers/net/irda/mcp2120-sir.c               |   12 +-
 drivers/net/irda/nsc-ircc.c                  |  119 ++++----
 drivers/net/irda/nsc-ircc.h                  |    3 +
 drivers/net/irda/old_belkin-sir.c            |    8 +-
 drivers/net/irda/sir_dev.c                   |   63 ++--
 drivers/net/irda/sir_dongle.c                |    2 +-
 drivers/net/irda/smsc-ircc2.c                |  120 ++++----
 drivers/net/irda/tekram-sir.c                |   10 +-
 drivers/net/irda/toim3232-sir.c              |   10 +-
 drivers/net/irda/via-ircc.c                  |   80 +++---
 drivers/net/irda/vlsi_ir.c                   |   92 +++---
 drivers/net/irda/vlsi_ir.h                   |    2 +-
 drivers/net/irda/w83977af_ir.c               |   62 ++--
 drivers/net/mv643xx_eth.c                    |  358 ++++++++++++++--------
 drivers/net/ne.c                             |    6 +-
 drivers/net/s2io.c                           |   29 ++-
 drivers/net/sh_eth.c                         |  202 ++++++++++---
 drivers/net/sh_eth.h                         |  426 +++++++++++++++++++-------
 drivers/net/skfp/smt.c                       |   13 +-
 drivers/net/tg3.c                            |   67 ++---
 drivers/net/usb/dm9601.c                     |   52 +++-
 drivers/net/wd.c                             |    2 +-
 include/linux/Kbuild                         |    1 +
 include/linux/ip_vs.h                        |  245 +++++++++++++++
 include/linux/netdevice.h                    |   86 ++++--
 include/linux/netfilter/nf_conntrack_tcp.h   |    3 +
 include/linux/skbuff.h                       |    1 +
 include/net/ip_vs.h                          |  253 +---------------
 lib/random32.c                               |   48 ++--
 net/atm/mpc.c                                |   22 +-
 net/bridge/br_device.c                       |    9 +-
 net/bridge/br_if.c                           |    3 +
 net/bridge/br_netfilter.c                    |   65 +++--
 net/bridge/br_private.h                      |    6 +
 net/core/dev.c                               |    1 +
 net/core/netpoll.c                           |    1 +
 net/core/pktgen.c                            |    7 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c           |    5 +-
 net/ipv4/netfilter/ipt_recent.c              |    2 +-
 net/ipv4/route.c                             |    2 +
 net/ipv4/tcp_ipv4.c                          |    4 +-
 net/ipv6/ip6_output.c                        |    4 +
 net/ipv6/tcp_ipv6.c                          |    6 +-
 net/netfilter/nf_conntrack_proto_tcp.c       |   29 ++-
 net/netfilter/xt_hashlimit.c                 |    4 +-
 net/sched/sch_generic.c                      |    6 +-
 net/sched/sch_teql.c                         |    9 +-
 73 files changed, 2007 insertions(+), 1291 deletions(-)
 create mode 100644 include/linux/ip_vs.h
