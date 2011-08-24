From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] Complete drivers/net/ move
Date: Wed, 24 Aug 2011 02:02:40 -0700
Message-ID: <1314176570-20298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46584 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756457Ab1HXJCy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 05:02:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series moves the FDDI, PPP, HIPPI, PLIP, SLIP and the cleanup
of the drivers/net/ Kconfig & Makefile's.  This series in addition moves
the 2 remaining drivers in drivers/net/pcmcia/ into their respective
directories (arcnet & tokenring).  The last remaining change is to
make the all the "new" Kconfig options introduced by the Ethernet
drivers move to yes, so that current defconfig's will compile the expected
drivers.
 
v2- remove the changes for FDDI, HIPPI, PPP, etc Kconfig from menuconfig back
to config and used tristate instead of bool.  Apparently some configs load
FDDI and others as a module.
v3- Fix compile issues exposed by the driver move where local headers were
included with the incorrect path.
 
The following are changes since commit 131ea6675c761f655d43b808dd0fe83d15d5cdd3:
  net: add APIs for manipulating skb page fragments.
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Jeff Kirsher (10):
  fddi: Move the FDDI drivers
  skfp: Fix SysKonnect FDDI driver compile issues
  ppp: Move the PPP drivers
  hippi: Move the HIPPI driver
  plip: Move the PLIP driver
  slip: Move the SLIP drivers
  ixbmtr_cs: Move the IBM PCMCIA Token Ring driver
  com20020_cs: Move the PCMCIA Arcnet driver
  drivers/net: Kconfig & Makefile cleanup
  drivers/net/ethernet/*: Enabled vendor Kconfig options

 MAINTAINERS                                  |   11 +-
 drivers/net/Kconfig                          |  640 ++++++--------------------
 drivers/net/Makefile                         |   84 ++--
 drivers/net/arcnet/Kconfig                   |   14 +-
 drivers/net/arcnet/Makefile                  |    1 +
 drivers/net/{pcmcia => arcnet}/com20020_cs.c |    0
 drivers/net/ethernet/3com/Kconfig            |    1 +
 drivers/net/ethernet/8390/Kconfig            |    1 +
 drivers/net/ethernet/adaptec/Kconfig         |    1 +
 drivers/net/ethernet/alteon/Kconfig          |    1 +
 drivers/net/ethernet/amd/Kconfig             |    1 +
 drivers/net/ethernet/apple/Kconfig           |    1 +
 drivers/net/ethernet/atheros/Kconfig         |    1 +
 drivers/net/ethernet/broadcom/Kconfig        |    1 +
 drivers/net/ethernet/brocade/Kconfig         |    1 +
 drivers/net/ethernet/chelsio/Kconfig         |    1 +
 drivers/net/ethernet/cirrus/Kconfig          |    1 +
 drivers/net/ethernet/cisco/Kconfig           |    1 +
 drivers/net/ethernet/dec/Kconfig             |    1 +
 drivers/net/ethernet/dlink/Kconfig           |    1 +
 drivers/net/ethernet/emulex/Kconfig          |    1 +
 drivers/net/ethernet/faraday/Kconfig         |    1 +
 drivers/net/ethernet/freescale/Kconfig       |    1 +
 drivers/net/ethernet/fujitsu/Kconfig         |    1 +
 drivers/net/ethernet/hp/Kconfig              |    1 +
 drivers/net/ethernet/i825xx/Kconfig          |    1 +
 drivers/net/ethernet/ibm/Kconfig             |    1 +
 drivers/net/ethernet/intel/Kconfig           |    1 +
 drivers/net/ethernet/marvell/Kconfig         |    1 +
 drivers/net/ethernet/mellanox/Kconfig        |    1 +
 drivers/net/ethernet/micrel/Kconfig          |    1 +
 drivers/net/ethernet/microchip/Kconfig       |    1 +
 drivers/net/ethernet/myricom/Kconfig         |    1 +
 drivers/net/ethernet/natsemi/Kconfig         |    1 +
 drivers/net/ethernet/neterion/Kconfig        |    1 +
 drivers/net/ethernet/nuvoton/Kconfig         |    1 +
 drivers/net/ethernet/nvidia/Kconfig          |    1 +
 drivers/net/ethernet/oki-semi/Kconfig        |    1 +
 drivers/net/ethernet/pasemi/Kconfig          |    1 +
 drivers/net/ethernet/qlogic/Kconfig          |    1 +
 drivers/net/ethernet/racal/Kconfig           |    1 +
 drivers/net/ethernet/rdc/Kconfig             |    1 +
 drivers/net/ethernet/realtek/Kconfig         |    1 +
 drivers/net/ethernet/seeq/Kconfig            |    1 +
 drivers/net/ethernet/sgi/Kconfig             |    1 +
 drivers/net/ethernet/sis/Kconfig             |    1 +
 drivers/net/ethernet/smsc/Kconfig            |    1 +
 drivers/net/ethernet/stmicro/Kconfig         |    1 +
 drivers/net/ethernet/sun/Kconfig             |    1 +
 drivers/net/ethernet/tehuti/Kconfig          |    1 +
 drivers/net/ethernet/ti/Kconfig              |    1 +
 drivers/net/ethernet/toshiba/Kconfig         |    1 +
 drivers/net/ethernet/tundra/Kconfig          |    1 +
 drivers/net/ethernet/via/Kconfig             |    1 +
 drivers/net/ethernet/xilinx/Kconfig          |    1 +
 drivers/net/ethernet/xircom/Kconfig          |    1 +
 drivers/net/ethernet/xscale/Kconfig          |    1 +
 drivers/net/fddi/Kconfig                     |   77 +++
 drivers/net/fddi/Makefile                    |    6 +
 drivers/net/{ => fddi}/defxx.c               |    0
 drivers/net/{ => fddi}/defxx.h               |    0
 drivers/net/{ => fddi}/skfp/Makefile         |    0
 drivers/net/{ => fddi}/skfp/cfm.c            |    0
 drivers/net/{ => fddi}/skfp/drvfbi.c         |    0
 drivers/net/{ => fddi}/skfp/ecm.c            |    0
 drivers/net/{ => fddi}/skfp/ess.c            |    0
 drivers/net/{ => fddi}/skfp/fplustm.c        |    0
 drivers/net/{ => fddi}/skfp/h/cmtdef.h       |    4 +-
 drivers/net/{ => fddi}/skfp/h/fddi.h         |    0
 drivers/net/{ => fddi}/skfp/h/fddimib.h      |    0
 drivers/net/{ => fddi}/skfp/h/fplustm.h      |    0
 drivers/net/{ => fddi}/skfp/h/hwmtm.h        |    2 +-
 drivers/net/{ => fddi}/skfp/h/mbuf.h         |    0
 drivers/net/{ => fddi}/skfp/h/osdef1st.h     |    0
 drivers/net/{ => fddi}/skfp/h/sba.h          |    4 +-
 drivers/net/{ => fddi}/skfp/h/sba_def.h      |    0
 drivers/net/{ => fddi}/skfp/h/skfbi.h        |    0
 drivers/net/{ => fddi}/skfp/h/skfbiinc.h     |    2 +-
 drivers/net/{ => fddi}/skfp/h/smc.h          |   14 +-
 drivers/net/{ => fddi}/skfp/h/smt.h          |    0
 drivers/net/{ => fddi}/skfp/h/smt_p.h        |    0
 drivers/net/{ => fddi}/skfp/h/smtstate.h     |    0
 drivers/net/{ => fddi}/skfp/h/supern_2.h     |    0
 drivers/net/{ => fddi}/skfp/h/targethw.h     |    6 +-
 drivers/net/{ => fddi}/skfp/h/targetos.h     |    2 +-
 drivers/net/{ => fddi}/skfp/h/types.h        |    0
 drivers/net/{ => fddi}/skfp/hwmtm.c          |    0
 drivers/net/{ => fddi}/skfp/hwt.c            |    0
 drivers/net/{ => fddi}/skfp/pcmplc.c         |    0
 drivers/net/{ => fddi}/skfp/pmf.c            |    0
 drivers/net/{ => fddi}/skfp/queue.c          |    0
 drivers/net/{ => fddi}/skfp/rmt.c            |    0
 drivers/net/{ => fddi}/skfp/skfddi.c         |    0
 drivers/net/{ => fddi}/skfp/smt.c            |    0
 drivers/net/{ => fddi}/skfp/smtdef.c         |    0
 drivers/net/{ => fddi}/skfp/smtinit.c        |    0
 drivers/net/{ => fddi}/skfp/smttimer.c       |    0
 drivers/net/{ => fddi}/skfp/srf.c            |    0
 drivers/net/hippi/Kconfig                    |   39 ++
 drivers/net/hippi/Makefile                   |    5 +
 drivers/net/{ => hippi}/rrunner.c            |    0
 drivers/net/{ => hippi}/rrunner.h            |    0
 drivers/net/pcmcia/Kconfig                   |   45 --
 drivers/net/pcmcia/Makefile                  |    8 -
 drivers/net/phy/Kconfig                      |    2 +-
 drivers/net/plip/Kconfig                     |   38 ++
 drivers/net/plip/Makefile                    |    5 +
 drivers/net/{ => plip}/plip.c                |    0
 drivers/net/ppp/Kconfig                      |  176 +++++++
 drivers/net/ppp/Makefile                     |   13 +
 drivers/net/{ => ppp}/bsd_comp.c             |    0
 drivers/net/{ => ppp}/ppp_async.c            |    0
 drivers/net/{ => ppp}/ppp_deflate.c          |    0
 drivers/net/{ => ppp}/ppp_generic.c          |    0
 drivers/net/{ => ppp}/ppp_mppe.c             |    0
 drivers/net/{ => ppp}/ppp_mppe.h             |    0
 drivers/net/{ => ppp}/ppp_synctty.c          |    0
 drivers/net/{ => ppp}/pppoe.c                |    0
 drivers/net/{ => ppp}/pppox.c                |    0
 drivers/net/{ => ppp}/pptp.c                 |    0
 drivers/net/slip/Kconfig                     |   79 ++++
 drivers/net/slip/Makefile                    |    6 +
 drivers/net/{ => slip}/slhc.c                |    0
 drivers/net/{ => slip}/slip.c                |    0
 drivers/net/{ => slip}/slip.h                |    0
 drivers/net/tokenring/Kconfig                |   15 +-
 drivers/net/tokenring/Makefile               |   21 +-
 drivers/net/{pcmcia => tokenring}/ibmtr_cs.c |    2 +-
 128 files changed, 727 insertions(+), 645 deletions(-)
 rename drivers/net/{pcmcia => arcnet}/com20020_cs.c (100%)
 create mode 100644 drivers/net/fddi/Kconfig
 create mode 100644 drivers/net/fddi/Makefile
 rename drivers/net/{ => fddi}/defxx.c (100%)
 rename drivers/net/{ => fddi}/defxx.h (100%)
 rename drivers/net/{ => fddi}/skfp/Makefile (100%)
 rename drivers/net/{ => fddi}/skfp/cfm.c (100%)
 rename drivers/net/{ => fddi}/skfp/drvfbi.c (100%)
 rename drivers/net/{ => fddi}/skfp/ecm.c (100%)
 rename drivers/net/{ => fddi}/skfp/ess.c (100%)
 rename drivers/net/{ => fddi}/skfp/fplustm.c (100%)
 rename drivers/net/{ => fddi}/skfp/h/cmtdef.h (99%)
 rename drivers/net/{ => fddi}/skfp/h/fddi.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/fddimib.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/fplustm.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/hwmtm.h (99%)
 rename drivers/net/{ => fddi}/skfp/h/mbuf.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/osdef1st.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/sba.h (98%)
 rename drivers/net/{ => fddi}/skfp/h/sba_def.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/skfbi.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/skfbiinc.h (99%)
 rename drivers/net/{ => fddi}/skfp/h/smc.h (98%)
 rename drivers/net/{ => fddi}/skfp/h/smt.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/smt_p.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/smtstate.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/supern_2.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/targethw.h (98%)
 rename drivers/net/{ => fddi}/skfp/h/targetos.h (99%)
 rename drivers/net/{ => fddi}/skfp/h/types.h (100%)
 rename drivers/net/{ => fddi}/skfp/hwmtm.c (100%)
 rename drivers/net/{ => fddi}/skfp/hwt.c (100%)
 rename drivers/net/{ => fddi}/skfp/pcmplc.c (100%)
 rename drivers/net/{ => fddi}/skfp/pmf.c (100%)
 rename drivers/net/{ => fddi}/skfp/queue.c (100%)
 rename drivers/net/{ => fddi}/skfp/rmt.c (100%)
 rename drivers/net/{ => fddi}/skfp/skfddi.c (100%)
 rename drivers/net/{ => fddi}/skfp/smt.c (100%)
 rename drivers/net/{ => fddi}/skfp/smtdef.c (100%)
 rename drivers/net/{ => fddi}/skfp/smtinit.c (100%)
 rename drivers/net/{ => fddi}/skfp/smttimer.c (100%)
 rename drivers/net/{ => fddi}/skfp/srf.c (100%)
 create mode 100644 drivers/net/hippi/Kconfig
 create mode 100644 drivers/net/hippi/Makefile
 rename drivers/net/{ => hippi}/rrunner.c (100%)
 rename drivers/net/{ => hippi}/rrunner.h (100%)
 delete mode 100644 drivers/net/pcmcia/Kconfig
 delete mode 100644 drivers/net/pcmcia/Makefile
 create mode 100644 drivers/net/plip/Kconfig
 create mode 100644 drivers/net/plip/Makefile
 rename drivers/net/{ => plip}/plip.c (100%)
 create mode 100644 drivers/net/ppp/Kconfig
 create mode 100644 drivers/net/ppp/Makefile
 rename drivers/net/{ => ppp}/bsd_comp.c (100%)
 rename drivers/net/{ => ppp}/ppp_async.c (100%)
 rename drivers/net/{ => ppp}/ppp_deflate.c (100%)
 rename drivers/net/{ => ppp}/ppp_generic.c (100%)
 rename drivers/net/{ => ppp}/ppp_mppe.c (100%)
 rename drivers/net/{ => ppp}/ppp_mppe.h (100%)
 rename drivers/net/{ => ppp}/ppp_synctty.c (100%)
 rename drivers/net/{ => ppp}/pppoe.c (100%)
 rename drivers/net/{ => ppp}/pppox.c (100%)
 rename drivers/net/{ => ppp}/pptp.c (100%)
 create mode 100644 drivers/net/slip/Kconfig
 create mode 100644 drivers/net/slip/Makefile
 rename drivers/net/{ => slip}/slhc.c (100%)
 rename drivers/net/{ => slip}/slip.c (100%)
 rename drivers/net/{ => slip}/slip.h (100%)
 rename drivers/net/{pcmcia => tokenring}/ibmtr_cs.c (99%)

-- 
1.7.6
