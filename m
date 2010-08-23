From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 23 Aug 2010 15:44:25 -0700 (PDT)
Message-ID: <20100823.154425.212395433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42978
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753407Ab0HWWoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 18:44:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) We changes lots of things to use "__packed" instead of "__attribute__((packed))"
   but this doesn't work out so well in user exported headers since the __packed
   define comes from compiler.h

   The easiest way to fix this regression is to revert this transformation in
   user visible headers.  Fix from Changli Gao.

2) RDS leaks kernel memory, also transmit and statistic gathering race fixes
   in irda, qlnic, and netxen.  All from Eric Dumazet.

3) Fix lockdep spew in netxen, from Amit Kumar Salecha.

4) CONFIG_COMPAT accidently got broken by 2.6.35 changes, regression fix from
   Florian Westphal.

5) Wireless log message regression fix from Joe Perches.

6) Fix iwlwifi 3945 filter flag regression and really fix netlink
   compat layer handling.  Both from Johannes Berg.

7) 82573 e1000e chips need ASPM L1 disabled, also don't check for ALT mac addresses
   on chips that lack support for it.  Both fixes from Bruce Alan.

8) ll_temac ->poll_controller() passes wrong pointer to interrupt handler, fix from
   Michal Simek.

9) When VLAN comes up it should have carrier state matching underlying device,
   from Phil Oester.

10) Some ISDN driver missing PCMCIA dependency breaking the build, from Randy Dunlap.

11) New driver for PXA168 ethernet chips.  From Sachin Sanap.

12) OOPS fix on ibmveth mtu change, from Robert Jennings.

13) iwlwifi resets too aggressively on chips that share ASIC logic with
    a bluetooth implementation, use a longer monitor timer for such chips.
    Fix from Wey-Yi Guy.

14) PHY locking fix in bxn2x from Yaniv Rosner.

Please pull, thanks a lot!

The following changes since commit 3b89f56783a4ef796190ef1192c25e72e0b986b6:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6 (2010-08-17 18:37:03 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Amit Kumar Salecha (2):
      netxen: fix inconsistent lock state
      netxen: update version 4.0.74

Andre Detsch (1):
      ehea: Fix synchronization between HW and SW send queue

Bruce Allan (2):
      e1000e: disable ASPM L1 on 82573
      e1000e: don't check for alternate MAC addr on parts that don't support it

Changli Gao (1):
      header: fix broken headers for user space

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Eric Dumazet (4):
      rds: fix a leak of kernel memory
      irda: fix a race in irlan_eth_xmit()
      qlnic: fix a race in qlcnic_get_stats()
      netxen: fix a race in netxen_nic_get_stats()

Florian Westphal (1):
      netfilter: fix CONFIG_COMPAT support

Joe Perches (1):
      drivers/net/wireless: Restore upper case words in wiphy_<level> messages

Johannes Berg (2):
      iwlwifi: fix 3945 filter flags
      netlink: fix compat recvmsg

John W. Linville (1):
      ipw2100: don't sync status queue entries

Kuninori Morimoto (1):
      net: sh_eth: remove unused variable

Michal Simek (1):
      ll_temac: Fix poll implementation

Phil Oester (1):
      vlan: Match underlying dev carrier on vlan add

Randy Dunlap (1):
      isdn/avm: fix build when PCMCIA is not enabled

Robert Jennings (1):
      ibmveth: Fix opps during MTU change on an active device

Sachin Sanap (1):
      net: add Fast Ethernet driver for PXA168.

Sam Ravnborg (1):
      netfilter: fix userspace header warning

Wey-Yi Guy (3):
      iwlwifi: long monitor timer
      iwlwifi: use long monitor timer to avoid un-necessary reload
      iwlwifi: use long monitor timer for 5300 series

Yaniv Rosner (2):
      bnx2x: Fix PHY locking problem
      bnx2x: Update bnx2x version to 1.52.53-4

 drivers/isdn/hardware/avm/Kconfig              |    3 +-
 drivers/net/Kconfig                            |   10 +
 drivers/net/Makefile                           |    1 +
 drivers/net/bnx2x/bnx2x.h                      |    4 +-
 drivers/net/bnx2x/bnx2x_main.c                 |    9 +-
 drivers/net/e1000e/82571.c                     |   31 +-
 drivers/net/e1000e/defines.h                   |    4 +
 drivers/net/e1000e/lib.c                       |   10 +
 drivers/net/ehea/ehea.h                        |    3 +-
 drivers/net/ehea/ehea_main.c                   |   60 +-
 drivers/net/ibmveth.c                          |   32 +-
 drivers/net/ll_temac_main.c                    |    4 +-
 drivers/net/netxen/netxen_nic.h                |    4 +-
 drivers/net/netxen/netxen_nic_init.c           |    4 -
 drivers/net/netxen/netxen_nic_main.c           |    2 -
 drivers/net/pxa168_eth.c                       | 1666 ++++++++++++++++++++++++
 drivers/net/qlcnic/qlcnic_main.c               |    2 -
 drivers/net/sh_eth.c                           |    2 +-
 drivers/net/wireless/adm8211.c                 |    8 +-
 drivers/net/wireless/at76c50x-usb.c            |   22 +-
 drivers/net/wireless/ath/ar9170/main.c         |    4 +-
 drivers/net/wireless/ipw2x00/ipw2100.c         |    8 -
 drivers/net/wireless/iwlwifi/iwl-1000.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c        |   14 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c        |   32 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c         |   45 +-
 drivers/net/wireless/iwlwifi/iwl-core.c        |   45 -
 drivers/net/wireless/iwlwifi/iwl-core.h        |    3 -
 drivers/net/wireless/iwlwifi/iwl-dev.h         |    3 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c    |   51 +-
 drivers/net/wireless/mac80211_hwsim.c          |    2 +-
 drivers/net/wireless/mwl8k.c                   |   34 +-
 drivers/net/wireless/p54/eeprom.c              |    6 +-
 drivers/net/wireless/p54/fwio.c                |    2 +-
 drivers/net/wireless/p54/led.c                 |    4 +-
 drivers/net/wireless/p54/p54pci.c              |    2 +-
 drivers/net/wireless/p54/txrx.c                |    2 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c     |    6 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c     |    4 +-
 drivers/net/wireless/rtl818x/rtl8187_rtl8225.c |    4 +-
 include/linux/if_ether.h                       |    2 +-
 include/linux/if_fddi.h                        |    8 +-
 include/linux/if_hippi.h                       |    8 +-
 include/linux/if_pppox.h                       |   10 +-
 include/linux/ipv6.h                           |    4 +-
 include/linux/nbd.h                            |    2 +-
 include/linux/ncp.h                            |   10 +-
 include/linux/netfilter/xt_IDLETIMER.h         |    2 +-
 include/linux/netfilter/xt_ipvs.h              |    2 +
 include/linux/phonet.h                         |    4 +-
 include/linux/pxa168_eth.h                     |   30 +
 include/linux/rfkill.h                         |    2 +-
 net/8021q/vlan_dev.c                           |    3 +-
 net/ipv4/netfilter/arp_tables.c                |    3 +
 net/ipv4/netfilter/ip_tables.c                 |    3 +
 net/ipv6/netfilter/ip6_tables.c                |    3 +
 net/irda/irlan/irlan_eth.c                     |    4 +-
 net/netlink/af_netlink.c                       |   46 +-
 net/rds/recv.c                                 |    2 +-
 61 files changed, 2064 insertions(+), 246 deletions(-)
 create mode 100644 drivers/net/pxa168_eth.c
 create mode 100644 include/linux/pxa168_eth.h
