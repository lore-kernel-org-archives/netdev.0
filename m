From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: possibly dead CONFIG variables, perhaps fixable for 2.6.23?
Date: Mon, 3 Sep 2007 04:34:26 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0709030425250.13110@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:57499 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbXICIqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 04:46:08 -0400
Received: from [192.168.1.100] (CPE0018396a01fc-CM001225dbafb6.cpe.net.cable.rogers.com [72.143.66.27])
	(authenticated bits=0)
	by rubicon.netdirect.ca (8.13.1/8.13.1) with ESMTP id l838jkvm010137
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 3 Sep 2007 04:45:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


profuse, grovelling apologies in advance:

  normally, i would have waited until after the updates in the merge
window after 2.6.23 since i know cleanups for some of what follows are
in the queue, but there are at least a couple odd-looking variables
here that i thought i'd post the results of my scanning script, just
in case any of these represent actual errors or typoes someone might
want to fix and sneak in before 2.6.23.

  (caveat:  fairly dumb script that generates false positives, such as
when people use hard-coded macro names that begin with "CONFIG_", but
since it's not *obscenely* lengthy, i'll just post it as is.  what
anyone chooses to do with this is entirely their call.  enjoy.)

drivers/net/:


========== 440GR ==========
drivers/net/ibm_emac/ibm_emac_core.c:88:    (defined(CONFIG_405EP) || defined(CONFIG_440EP) || defined(CONFIG_440GR))
drivers/net/ibm_emac/ibm_emac_core.c:101:#else /* CONFIG_440EP || CONFIG_440GR */
drivers/net/ibm_emac/ibm_emac_mal.h:35:    defined(CONFIG_440EP) || defined(CONFIG_440GR) || defined(CONFIG_NP405H)
drivers/net/ibm_emac/ibm_emac.h:29:    !defined(CONFIG_440GR)
drivers/net/Kconfig:1294:	depends on IBM_EMAC && (405EP || 440GX || 440EP || 440GR)
drivers/net/ibm_emac/ibm_emac_core.c:91: * 440EP/440GR has more sane SDR0_MFR register implementation than 440GX, which
========== ARCH_INNOKOM ==========
drivers/net/smc91x.h:194:#elif	defined(CONFIG_ARCH_INNOKOM) || \
arch/arm/tools/mach-types:275:innokom			ARCH_INNOKOM		INNOKOM			258
========== ARCH_PNX010X ==========
drivers/net/cs89x0.c:190:#elif defined(CONFIG_ARCH_PNX010X)
drivers/net/cs89x0.c:377:#elif defined(CONFIG_ARCH_PNX010X)
drivers/net/cs89x0.c:537:#ifdef CONFIG_ARCH_PNX010X
drivers/net/cs89x0.c:805:#if defined(CONFIG_MACH_IXDP2351) || defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_ARCH_PNX010X)
drivers/net/cs89x0.c:1280:#if !defined(CONFIG_SH_HICOSH4) && !defined(CONFIG_ARCH_PNX010X) /* uses irq#1, so this won't work */
drivers/net/cs89x0.c:1311:#if !defined(CONFIG_MACH_IXDP2351) && !defined(CONFIG_ARCH_IXDP2X01) && !defined(CONFIG_ARCH_PNX010X)
drivers/net/cs89x0.c:1396:#ifdef CONFIG_ARCH_PNX010X
drivers/net/Kconfig:1499:	depends on NET_PCI && (ISA || MACH_IXDP2351 || ARCH_IXDP2X01 || ARCH_PNX010X)
========== ARCH_RAMSES ==========
drivers/net/smc91x.h:197:	defined(CONFIG_ARCH_RAMSES)
arch/arm/tools/mach-types:252:mnci			ARCH_RAMSES		RAMSES			235
========== CASSINI_MULTICAST_REG_WRITE ==========
drivers/net/cassini.c:3099:#ifdef CONFIG_CASSINI_MULTICAST_REG_WRITE
drivers/net/cassini.c:3169:#ifndef CONFIG_CASSINI_MULTICAST_REG_WRITE
========== CASSINI_NAPI ==========
drivers/net/cassini.c:107:#if defined(CONFIG_CASSINI_NAPI) && defined(HAVE_NETDEV_POLL)
========== CASSINI_QGE_DEBUG ==========
drivers/net/cassini.h:4362:#ifdef CONFIG_CASSINI_QGE_DEBUG
========== CHELSIO_T1_COUGAR ==========
drivers/net/chelsio/subr.c:188:#ifdef CONFIG_CHELSIO_T1_COUGAR
drivers/net/chelsio/subr.c:283:#if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
drivers/net/chelsio/subr.c:323:#if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
drivers/net/chelsio/subr.c:750:#ifdef CONFIG_CHELSIO_T1_COUGAR
drivers/net/chelsio/subr.c:1002:#ifdef CONFIG_CHELSIO_T1_COUGAR
drivers/net/chelsio/subr.c:1059:#ifdef CONFIG_CHELSIO_T1_COUGAR
drivers/net/chelsio/subr.c:1082:#ifdef CONFIG_CHELSIO_T1_COUGAR
========== DUET ==========
drivers/net/fs_enet/mac-fec.c:252:#ifdef CONFIG_DUET
drivers/net/fs_enet/mac-fec.c:329:#ifdef CONFIG_DUET
drivers/net/fec_8xx/fec_main.c:237:#ifdef CONFIG_DUET
drivers/net/fec_8xx/fec_main.c:363:#ifdef CONFIG_DUET
drivers/net/fec_8xx/fec_main.c:1087:#ifdef CONFIG_DUET
arch/powerpc/platforms/8xx/Kconfig:30:	  Also known as DUET.
arch/ppc/Kconfig:412:	  Also known as DUET.
drivers/net/fs_enet/mac-fec.c:327:	 * adjust to speed (only for DUET & RMII)
drivers/net/fec_8xx/fec_main.c:361:	 * adjust to speed (only for DUET & RMII)
include/asm-mips/pmc-sierra/msp71xx/msp_prom.h:50:#define MACHINE_TYPE_DUET		"DUET"
include/asm-mips/pmc-sierra/msp71xx/msp_prom.h:60:#define MACHINE_TYPE_DUET_FPGA		"DUET-FPGA"
include/asm-mips/pmc-sierra/msp71xx/msp_prom.h:114:#define TDM_DUET		'D'	/* DUET TDMs might exist */
include/asm-mips/pmc-sierra/msp71xx/msp_prom.h:118:#define ZSP_DUET		'D'	/* one DUET zsp engine */
include/asm-ppc/8xx_immap.h:530:	/* The DUET family has a second FEC here */
========== ETRAX_NETWORK_RED_ON_NO_CONNECTION ==========
drivers/net/cris/eth_v10.c:1783:#if defined(CONFIG_ETRAX_NETWORK_RED_ON_NO_CONNECTION)
========== FIXED_MII_DUPLEX ==========
drivers/net/phy/fixed.c:339:#ifdef CONFIG_FIXED_MII_DUPLEX
========== GILBARCONAP ==========
drivers/net/fec.c:100:#elif defined(CONFIG_GILBARCONAP) || defined(CONFIG_SCALES)
========== LMC_IGNORE_HARDWARE_HANDSHAKE ==========
drivers/net/wan/lmc/lmc_media.c:32:#define CONFIG_LMC_IGNORE_HARDWARE_HANDSHAKE 1
drivers/net/wan/lmc/lmc_media.c:742:#ifdef CONFIG_LMC_IGNORE_HARDWARE_HANDSHAKE
========== MACH_LPD79520 ==========
drivers/net/smc91x.h:331:#elif   defined(CONFIG_MACH_LPD79520) \
arch/arm/tools/mach-types:553:lpd79520		MACH_LPD79520		LPD79520		537
arch/arm/mach-lh7a40x/lcd-panel.h:40:#if defined (MACH_LPD79520)\
========== NETWINDER_RX_DMA_PROBLEMS ==========
drivers/net/irda/w83977af_ir.c:66:#define CONFIG_NETWINDER_RX_DMA_PROBLEMS /* Must have this one! */
drivers/net/irda/w83977af_ir.c:741:#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
drivers/net/irda/w83977af_ir.c:766:#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
drivers/net/irda/w83977af_ir.c:789:#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
========== NETWINDER_TX_DMA_PROBLEMS ==========
drivers/net/irda/w83977af_ir.c:65:#undef  CONFIG_NETWINDER_TX_DMA_PROBLEMS /* Not needed */
drivers/net/irda/w83977af_ir.c:593:#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
drivers/net/irda/w83977af_ir.c:609:#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
drivers/net/irda/w83977af_ir.c:625:#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
========== SBMAC_COALESCE ==========
drivers/net/sb1250-mac.c:58:#define CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:97:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:201:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:696:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:787:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:828:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:975:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:1070:#ifndef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:1164:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:1706:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:2898:#ifdef CONFIG_SBMAC_COALESCE
========== SH_HICOSH4 ==========
drivers/net/cs89x0.h:440:#ifdef CONFIG_SH_HICOSH4
drivers/net/cs89x0.c:178:#elif defined(CONFIG_SH_HICOSH4)
drivers/net/cs89x0.c:570:#ifdef CONFIG_SH_HICOSH4
drivers/net/cs89x0.c:641:#ifdef CONFIG_SH_HICOSH4
drivers/net/cs89x0.c:726:#ifdef CONFIG_SH_HICOSH4 /* no EEPROM on HiCO, don't hazzle with it here */
drivers/net/cs89x0.c:1280:#if !defined(CONFIG_SH_HICOSH4) && !defined(CONFIG_ARCH_PNX010X) /* uses irq#1, so this won't work */
========== SIS190_NAPI ==========
drivers/net/sis190.c:50:#ifdef CONFIG_SIS190_NAPI
drivers/net/sis190.c:61:#ifdef CONFIG_SIS190_NAPI
========== USE_INTERNAL_TIMER ==========
drivers/net/irda/w83977af_ir.c:68:#undef  CONFIG_USE_INTERNAL_TIMER  /* Just cannot make that timer work */
drivers/net/irda/w83977af_ir.c:536:#ifdef CONFIG_USE_INTERNAL_TIMER
drivers/net/irda/w83977af_ir.c:563:#ifdef CONFIG_USE_INTERNAL_TIMER
drivers/net/irda/w83977af_ir.c:879:#ifdef CONFIG_USE_INTERNAL_TIMER
========== USE_W977_PNP ==========
drivers/net/irda/w83977af_ir.c:69:#define CONFIG_USE_W977_PNP        /* Currently needed */
drivers/net/irda/w83977af_ir.c:283:#ifdef CONFIG_USE_W977_PNP
drivers/net/irda/w83977af_ir.c:293:#endif /* CONFIG_USE_W977_PNP */
drivers/net/irda/w83977af_ir.c:323:#ifdef CONFIG_USE_W977_PNP
drivers/net/irda/w83977af_ir.c:349:#endif /* CONFIG_USE_W977_PNP */


net/:


========== BT_BNEP_DEBUG ==========
net/bluetooth/bnep/netdev.c:48:#ifndef CONFIG_BT_BNEP_DEBUG
net/bluetooth/bnep/sock.c:53:#ifndef CONFIG_BT_BNEP_DEBUG
net/bluetooth/bnep/core.c:59:#ifndef CONFIG_BT_BNEP_DEBUG
========== BT_CMTP_DEBUG ==========
net/bluetooth/cmtp/sock.c:46:#ifndef CONFIG_BT_CMTP_DEBUG
net/bluetooth/cmtp/capi.c:45:#ifndef CONFIG_BT_CMTP_DEBUG
net/bluetooth/cmtp/core.c:47:#ifndef CONFIG_BT_CMTP_DEBUG
========== BT_HCI_CORE_DEBUG ==========
net/bluetooth/hci_event.c:48:#ifndef CONFIG_BT_HCI_CORE_DEBUG
net/bluetooth/hci_conn.c:48:#ifndef CONFIG_BT_HCI_CORE_DEBUG
net/bluetooth/hci_sysfs.c:11:#ifndef CONFIG_BT_HCI_CORE_DEBUG
net/bluetooth/hci_core.c:50:#ifndef CONFIG_BT_HCI_CORE_DEBUG
========== BT_HCI_SOCK_DEBUG ==========
net/bluetooth/hci_sock.c:51:#ifndef CONFIG_BT_HCI_SOCK_DEBUG
========== BT_HIDP_DEBUG ==========
net/bluetooth/hidp/sock.c:42:#ifndef CONFIG_BT_HIDP_DEBUG
net/bluetooth/hidp/core.c:50:#ifndef CONFIG_BT_HIDP_DEBUG
========== BT_L2CAP_DEBUG ==========
net/bluetooth/l2cap.c:53:#ifndef CONFIG_BT_L2CAP_DEBUG
========== BT_RFCOMM_DEBUG ==========
net/bluetooth/rfcomm/tty.c:44:#ifndef CONFIG_BT_RFCOMM_DEBUG
net/bluetooth/rfcomm/sock.c:55:#ifndef CONFIG_BT_RFCOMM_DEBUG
net/bluetooth/rfcomm/core.c:51:#ifndef CONFIG_BT_RFCOMM_DEBUG
========== BT_SCO_DEBUG ==========
net/bluetooth/sco.c:51:#ifndef CONFIG_BT_SCO_DEBUG
========== BT_SOCK_DEBUG ==========
net/bluetooth/af_bluetooth.c:46:#ifndef CONFIG_BT_SOCK_DEBUG
========== IP_FIB_TRIE_STATS ==========
net/ipv4/fib_trie.c:84:#undef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:138:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:160:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:571:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:612:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:878:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:1315:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:1320:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:1349:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:1372:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:1506:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:2157:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:2168:#endif /*  CONFIG_IP_FIB_TRIE_STATS */
========== IP_PIMSM ==========
net/ipv4/ipmr.c:68:#define CONFIG_IP_PIMSM	1
net/ipv4/ipmr.c:176:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:272:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:406:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:462:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:556:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:566:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:953:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:999:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:1016:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:1161:#ifdef CONFIG_IP_PIMSM
========== IP_ROUTE_PERVASIVE ==========
net/ipv4/fib_semantics.c:525:#ifdef CONFIG_IP_ROUTE_PERVASIVE
========== IP_VS_DEBUG ==========
arch/mips/configs/ip22_defconfig:296:# CONFIG_IP_VS_DEBUG is not set
arch/mips/configs/malta_defconfig:330:# CONFIG_IP_VS_DEBUG is not set
arch/mips/configs/atlas_defconfig:335:# CONFIG_IP_VS_DEBUG is not set
arch/mips/defconfig:296:# CONFIG_IP_VS_DEBUG is not set
arch/arm/configs/ixp4xx_defconfig:264:CONFIG_IP_VS_DEBUG=y
arch/arm/configs/pnx4008_defconfig:258:# CONFIG_IP_VS_DEBUG is not set
include/net/ip_vs.h:260:#ifdef CONFIG_IP_VS_DEBUG
include/net/ip_vs.h:303:#ifdef CONFIG_IP_VS_DEBUG
net/ipv4/ipvs/ip_vs_ctl.c:85:#ifdef CONFIG_IP_VS_DEBUG
net/ipv4/ipvs/ip_vs_ctl.c:1408:#ifdef CONFIG_IP_VS_DEBUG
net/ipv4/ipvs/ip_vs_core.c:58:#ifdef CONFIG_IP_VS_DEBUG
net/ipv4/ipvs/Kconfig:27:config	IP_VS_DEBUG
========== IP_VS_DH_TAB_BITS ==========
net/ipv4/ipvs/ip_vs_dh.c:58:#ifndef CONFIG_IP_VS_DH_TAB_BITS
net/ipv4/ipvs/ip_vs_dh.c:59:#define CONFIG_IP_VS_DH_TAB_BITS        8
net/ipv4/ipvs/ip_vs_dh.c:61:#define IP_VS_DH_TAB_BITS               CONFIG_IP_VS_DH_TAB_BITS
net/ipv4/ipvs/ip_vs_dh.c:61:#define IP_VS_DH_TAB_BITS               CONFIG_IP_VS_DH_TAB_BITS
net/ipv4/ipvs/ip_vs_dh.c:62:#define IP_VS_DH_TAB_SIZE               (1 << IP_VS_DH_TAB_BITS)
========== IP_VS_LBLCR_DEBUG ==========
net/ipv4/ipvs/ip_vs_lblcr.c:550:#ifdef CONFIG_IP_VS_LBLCR_DEBUG
net/ipv4/ipvs/ip_vs_lblcr.c:652:#ifdef CONFIG_IP_VS_LBLCR_DEBUG
net/ipv4/ipvs/ip_vs_lblcr.c:845:#ifdef CONFIG_IP_VS_LBLCR_DEBUG
net/ipv4/ipvs/ip_vs_lblcr.c:854:#ifdef CONFIG_IP_VS_LBLCR_DEBUG
========== IP_VS_LBLCR_TAB_BITS ==========
net/ipv4/ipvs/ip_vs_lblcr.c:77:#ifndef CONFIG_IP_VS_LBLCR_TAB_BITS
net/ipv4/ipvs/ip_vs_lblcr.c:78:#define CONFIG_IP_VS_LBLCR_TAB_BITS      10
net/ipv4/ipvs/ip_vs_lblcr.c:80:#define IP_VS_LBLCR_TAB_BITS     CONFIG_IP_VS_LBLCR_TAB_BITS
net/ipv4/ipvs/ip_vs_lblcr.c:80:#define IP_VS_LBLCR_TAB_BITS     CONFIG_IP_VS_LBLCR_TAB_BITS
net/ipv4/ipvs/ip_vs_lblcr.c:81:#define IP_VS_LBLCR_TAB_SIZE     (1 << IP_VS_LBLCR_TAB_BITS)
========== IP_VS_LBLC_TAB_BITS ==========
net/ipv4/ipvs/ip_vs_lblc.c:77:#ifndef CONFIG_IP_VS_LBLC_TAB_BITS
net/ipv4/ipvs/ip_vs_lblc.c:78:#define CONFIG_IP_VS_LBLC_TAB_BITS      10
net/ipv4/ipvs/ip_vs_lblc.c:80:#define IP_VS_LBLC_TAB_BITS     CONFIG_IP_VS_LBLC_TAB_BITS
net/ipv4/ipvs/ip_vs_lblc.c:80:#define IP_VS_LBLC_TAB_BITS     CONFIG_IP_VS_LBLC_TAB_BITS
net/ipv4/ipvs/ip_vs_lblc.c:81:#define IP_VS_LBLC_TAB_SIZE     (1 << IP_VS_LBLC_TAB_BITS)
========== IP_VS_PROTO_AH ==========
arch/mips/configs/ip22_defconfig:305:CONFIG_IP_VS_PROTO_AH=y
arch/mips/configs/malta_defconfig:339:CONFIG_IP_VS_PROTO_AH=y
arch/mips/configs/atlas_defconfig:344:CONFIG_IP_VS_PROTO_AH=y
arch/mips/defconfig:305:CONFIG_IP_VS_PROTO_AH=y
arch/arm/configs/ixp4xx_defconfig:273:# CONFIG_IP_VS_PROTO_AH is not set
arch/arm/configs/pnx4008_defconfig:267:CONFIG_IP_VS_PROTO_AH=y
net/ipv4/ipvs/ip_vs_proto.c:213:#ifdef CONFIG_IP_VS_PROTO_AH
net/ipv4/ipvs/Makefile:10:ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_AH) += ip_vs_proto_ah.o
net/ipv4/ipvs/Kconfig:80:config	IP_VS_PROTO_AH
========== IP_VS_PROTO_ESP ==========
arch/mips/configs/ip22_defconfig:304:CONFIG_IP_VS_PROTO_ESP=y
arch/mips/configs/malta_defconfig:338:CONFIG_IP_VS_PROTO_ESP=y
arch/mips/configs/atlas_defconfig:343:CONFIG_IP_VS_PROTO_ESP=y
arch/mips/defconfig:304:CONFIG_IP_VS_PROTO_ESP=y
arch/arm/configs/ixp4xx_defconfig:272:# CONFIG_IP_VS_PROTO_ESP is not set
arch/arm/configs/pnx4008_defconfig:266:CONFIG_IP_VS_PROTO_ESP=y
net/ipv4/ipvs/ip_vs_proto.c:216:#ifdef CONFIG_IP_VS_PROTO_ESP
net/ipv4/ipvs/Makefile:9:ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_ESP) += ip_vs_proto_esp.o
net/ipv4/ipvs/Kconfig:74:config	IP_VS_PROTO_ESP
========== IP_VS_PROTO_TCP ==========
arch/mips/configs/ip22_defconfig:302:CONFIG_IP_VS_PROTO_TCP=y
arch/mips/configs/malta_defconfig:336:CONFIG_IP_VS_PROTO_TCP=y
arch/mips/configs/atlas_defconfig:341:CONFIG_IP_VS_PROTO_TCP=y
arch/mips/defconfig:302:CONFIG_IP_VS_PROTO_TCP=y
arch/arm/configs/ixp4xx_defconfig:270:# CONFIG_IP_VS_PROTO_TCP is not set
arch/arm/configs/pnx4008_defconfig:264:CONFIG_IP_VS_PROTO_TCP=y
net/ipv4/ipvs/ip_vs_ctl.c:1881:#ifdef CONFIG_IP_VS_PROTO_TCP
net/ipv4/ipvs/ip_vs_ctl.c:2161:#ifdef CONFIG_IP_VS_PROTO_TCP
net/ipv4/ipvs/ip_vs_core.c:54:#ifdef CONFIG_IP_VS_PROTO_TCP
net/ipv4/ipvs/ip_vs_proto.c:207:#ifdef CONFIG_IP_VS_PROTO_TCP
net/ipv4/ipvs/Makefile:7:ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_TCP) += ip_vs_proto_tcp.o
net/ipv4/ipvs/Kconfig:62:config	IP_VS_PROTO_TCP
net/ipv4/ipvs/Kconfig:212:        depends on IP_VS_PROTO_TCP
========== IP_VS_PROTO_UDP ==========
arch/mips/configs/ip22_defconfig:303:CONFIG_IP_VS_PROTO_UDP=y
arch/mips/configs/malta_defconfig:337:CONFIG_IP_VS_PROTO_UDP=y
arch/mips/configs/atlas_defconfig:342:CONFIG_IP_VS_PROTO_UDP=y
arch/mips/defconfig:303:CONFIG_IP_VS_PROTO_UDP=y
arch/arm/configs/ixp4xx_defconfig:271:# CONFIG_IP_VS_PROTO_UDP is not set
arch/arm/configs/pnx4008_defconfig:265:CONFIG_IP_VS_PROTO_UDP=y
net/ipv4/ipvs/ip_vs_ctl.c:1893:#ifdef CONFIG_IP_VS_PROTO_UDP
net/ipv4/ipvs/ip_vs_ctl.c:2167:#ifdef CONFIG_IP_VS_PROTO_UDP
net/ipv4/ipvs/ip_vs_proto.c:210:#ifdef CONFIG_IP_VS_PROTO_UDP
net/ipv4/ipvs/Makefile:8:ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_UDP) += ip_vs_proto_udp.o
net/ipv4/ipvs/Kconfig:68:config	IP_VS_PROTO_UDP
========== IP_VS_SH_TAB_BITS ==========
net/ipv4/ipvs/ip_vs_sh.c:55:#ifndef CONFIG_IP_VS_SH_TAB_BITS
net/ipv4/ipvs/ip_vs_sh.c:56:#define CONFIG_IP_VS_SH_TAB_BITS        8
net/ipv4/ipvs/ip_vs_sh.c:58:#define IP_VS_SH_TAB_BITS               CONFIG_IP_VS_SH_TAB_BITS
net/ipv4/ipvs/ip_vs_sh.c:58:#define IP_VS_SH_TAB_BITS               CONFIG_IP_VS_SH_TAB_BITS
net/ipv4/ipvs/ip_vs_sh.c:59:#define IP_VS_SH_TAB_SIZE               (1 << IP_VS_SH_TAB_BITS)
========== IRDA_DYNAMIC_WINDOW ==========
include/net/irda/irlap.h:41:#define CONFIG_IRDA_DYNAMIC_WINDOW 1
include/net/irda/irlap.h:181:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
include/net/irda/irlap.h:184:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap.c:1026:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap.c:1035:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap.c:1158:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap.c:1162:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/qos.c:99:#ifndef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/qos.c:385:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/qos.c:409:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/qos.c:730:#ifndef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap_frame.c:832:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap_frame.c:842:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_frame.c:924:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap_frame.c:927:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_event.c:994:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap_event.c:1056:#else	/* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_event.c:1060:#endif	/* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_event.c:1101:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap_event.c:1104:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_event.c:1745:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap_event.c:1793:#else	/* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_event.c:1797:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
========== IRLAN_SEND_GRATUITOUS_ARP ==========
net/irda/irlan/irlan_common.c:62:#undef CONFIG_IRLAN_SEND_GRATUITOUS_ARP
net/irda/irlan/irlan_common.c:398:#ifdef CONFIG_IRLAN_SEND_GRATUITOUS_ARP
========== WANPIPE_MULTPPP ==========
net/wanrouter/wanmain.c:568:#ifdef CONFIG_WANPIPE_MULTPPP
net/wanrouter/wanmain.c:589:#ifdef CONFIG_WANPIPE_MULTPPP
net/wanrouter/wanmain.c:662:#ifdef CONFIG_WANPIPE_MULTPPP

rday

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
