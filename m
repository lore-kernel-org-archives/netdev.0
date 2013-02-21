From: Daniel J Blueman <daniel@numascale-asia.com>
Subject: BCM5709 hang and state dump...
Date: Thu, 21 Feb 2013 13:26:54 +0800
Message-ID: <5125B01E.4090405@numascale-asia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steffen Persvold <sp@numascale.com>, netdev@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:52084 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912Ab3BUF07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 00:26:59 -0500
Received: by mail-pb0-f51.google.com with SMTP id un15so3298777pbc.24
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2013 21:26:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael/Eilon,

On a large system with 552 cores, 1.5TB memory and linux 3.7, under some 
particular workloads, we've seem the Broadcom 5709 network controller 
hang [1]. It's running boot code 6.2.0 and NCSI code 2.0.11.

We suspect completion timeouts may be occurring due to possible starvation.

Is there anything significant/indicative from the state dumped?

Many thanks,
   Daniel

--- [1]

bnx2: Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.2.3 (June 
27, 2012)
bnx2 0000:01:00.0 eth0: Broadcom NetXtreme II BCM5709 1000Base-T (C0) 
PCI Express found at mem fc000000, IRQ 44, node addr e4:1f:13:80:70:03
bnx2 0000:01:00.1: enabling device (0140 -> 0142)
bnx2 0000:01:00.0: irq 72 for MSI/MSI-X
bnx2 0000:01:00.0: irq 73 for MSI/MSI-X
bnx2 0000:01:00.0: irq 74 for MSI/MSI-X
bnx2 0000:01:00.0: irq 75 for MSI/MSI-X
bnx2 0000:01:00.0: irq 76 for MSI/MSI-X
bnx2 0000:01:00.0: irq 77 for MSI/MSI-X
bnx2 0000:01:00.0: irq 78 for MSI/MSI-X
bnx2 0000:01:00.0: irq 79 for MSI/MSI-X
bnx2 0000:01:00.0 eth0: using MSIX
bnx2 0000:01:00.0 eth0: NIC Copper Link is Up, 1000 Mbps full duplex

<an hour later>

bnx2 0000:01:00.0 eth0: <--- start FTQ dump --->
bnx2 0000:01:00.0 eth0: RV2P_PFTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: RV2P_TFTQ_CTL 00020000
bnx2 0000:01:00.0 eth0: RV2P_MFTQ_CTL 00004000
bnx2 0000:01:00.0 eth0: TBDR_FTQ_CTL 00004000
bnx2 0000:01:00.0 eth0: TDMA_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TXP_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TXP_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TPAT_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: RXP_CFTQ_CTL 00008000
bnx2 0000:01:00.0 eth0: RXP_FTQ_CTL 00100000
bnx2 0000:01:00.0 eth0: COM_COMXQ_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: COM_COMTQ_FTQ_CTL 00020000
bnx2 0000:01:00.0 eth0: COM_COMQ_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: CP_CPQ_FTQ_CTL 00004000
bnx2 0000:01:00.0 eth0: CPU states:
bnx2 0000:01:00.0 eth0: 045000 mode b84c state 80001000 evt_mask 500 pc 
8001284 pc 8001284 instr 8e260000
bnx2 0000:01:00.0 eth0: 085000 mode b84c state 80005000 evt_mask 500 pc 
8000a4c pc 8000a5c instr 38420001
bnx2 0000:01:00.0 eth0: 0c5000 mode b84c state 80001000 evt_mask 500 pc 
8004c20 pc 8004c10 instr 32050003
bnx2 0000:01:00.0 eth0: 105000 mode b8cc state 80008000 evt_mask 500 pc 
8000aa0 pc 8000aa0 instr 8c420020
bnx2 0000:01:00.0 eth0: 145000 mode b880 state 80000000 evt_mask 500 pc 
800d978 pc 8009c18 instr afbf001c
bnx2 0000:01:00.0 eth0: 185000 mode b8cc state 80000000 evt_mask 500 pc 
8000cb0 pc 8000c58 instr 8ce800e8
bnx2 0000:01:00.0 eth0: <--- end FTQ dump --->
bnx2 0000:01:00.0 eth0: <--- start TBDC dump --->
bnx2 0000:01:00.0 eth0: TBDC free cnt: 32
bnx2 0000:01:00.0 eth0: LINE   CID BIDX  CMD VALIDS
bnx2 0000:01:00.0 eth0: 00  001180 0f40  00  [0]
bnx2 0000:01:00.0 eth0: 01  001180 0f48  00  [0]
bnx2 0000:01:00.0 eth0: 02  1db680 af58  f6  [0]
bnx2 0000:01:00.0 eth0: 03  0ddd00 fb58  fd  [0]
bnx2 0000:01:00.0 eth0: 04  1fff80 ffc8  ef  [0]
bnx2 0000:01:00.0 eth0: 05  1e9f80 9fa8  cf  [0]
bnx2 0000:01:00.0 eth0: 06  1d7380 77e8  ff  [0]
bnx2 0000:01:00.0 eth0: 07  1ddf00 7bb0  fb  [0]
bnx2 0000:01:00.0 eth0: 08  1edb80 ff78  6f  [0]
bnx2 0000:01:00.0 eth0: 09  1e9e80 ee58  9e  [0]
bnx2 0000:01:00.0 eth0: 0a  17f780 fff8  74  [0]
bnx2 0000:01:00.0 eth0: 0b  1d7e00 6db8  fd  [0]
bnx2 0000:01:00.0 eth0: 0c  1f7780 bff0  cf  [0]
bnx2 0000:01:00.0 eth0: 0d  1bff80 bff8  ff  [0]
bnx2 0000:01:00.0 eth0: 0e  17ff80 3de0  fe  [0]
bnx2 0000:01:00.0 eth0: 0f  1ff780 98f0  ff  [0]
bnx2 0000:01:00.0 eth0: 10  1f7f80 ffd8  ee  [0]
bnx2 0000:01:00.0 eth0: 11  0e7780 eaa8  7f  [0]
bnx2 0000:01:00.0 eth0: 12  1f9980 fde8  f7  [0]
bnx2 0000:01:00.0 eth0: 13  07ef80 ffc8  77  [0]
bnx2 0000:01:00.0 eth0: 14  1fbf80 57e8  bf  [0]
bnx2 0000:01:00.0 eth0: 15  0fae80 df68  5b  [0]
bnx2 0000:01:00.0 eth0: 16  0fff80 7ff8  be  [0]
bnx2 0000:01:00.0 eth0: 17  1f7680 fed8  c6  [0]
bnx2 0000:01:00.0 eth0: 18  03e380 fe70  7b  [0]
bnx2 0000:01:00.0 eth0: 19  0bcd80 7db8  7f  [0]
bnx2 0000:01:00.0 eth0: 1a  0cb580 bbf0  ef  [0]
bnx2 0000:01:00.0 eth0: 1b  0dfd80 dbf8  fb  [0]
bnx2 0000:01:00.0 eth0: 1c  0bff80 7ff8  f3  [0]
bnx2 0000:01:00.0 eth0: 1d  0dfb80 f9f8  ec  [0]
bnx2 0000:01:00.0 eth0: 1e  1e6e80 9be8  f7  [0]
bnx2 0000:01:00.0 eth0: 1f  1faf80 db78  52  [0]
bnx2 0000:01:00.0 eth0: <--- end TBDC dump --->
bnx2 0000:01:00.0 eth0: DEBUG: intr_sem[0] PCI_CMD[00100546]
bnx2 0000:01:00.0 eth0: DEBUG: PCI_PM[19002008] PCI_MISC_CFG[92000088]
bnx2 0000:01:00.0 eth0: DEBUG: EMAC_TX_STATUS[00000008] 
EMAC_RX_STATUS[00000000]
bnx2 0000:01:00.0 eth0: DEBUG: RPM_MGMT_PKT_CTRL[40000088]
bnx2 0000:01:00.0 eth0: DEBUG: HC_STATS_INTERRUPT_STATUS[010600f9]
bnx2 0000:01:00.0 eth0: DEBUG: PBA[00000000]
bnx2 0000:01:00.0 eth0: <--- start MCP states dump --->
bnx2 0000:01:00.0 eth0: DEBUG: MCP_STATE_P0[0003610e] MCP_STATE_P1[0003610e]
bnx2 0000:01:00.0 eth0: DEBUG: MCP mode[0000b880] state[80000000] 
evt_mask[00000500]
bnx2 0000:01:00.0 eth0: DEBUG: pc[0800d31c] pc[0800b46c] instr[a023f35c]
bnx2 0000:01:00.0 eth0: DEBUG: shmem states:
bnx2 0000:01:00.0 eth0: DEBUG: drv_mb[01030003] fw_mb[00000003] 
link_status[8000006f]
bnx2 0000:01:00.0 eth0: DEBUG: dev_info_signature[44564903] 
reset_type[01005254]
bnx2 0000:01:00.0 eth0: DEBUG: 000001c0: 01005254 42530083 0003610e 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 000003cc: 44444444 44444444 44444444 00000a14
bnx2 0000:01:00.0 eth0: DEBUG: 000003dc: 0004ffff 00000000 00000000 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 000003ec: 00000000 00000000 00000000 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 0x3fc[0000ffff]
bnx2 0000:01:00.0 eth0: <--- end MCP states dump --->
bnx2 0000:01:00.0 eth0: NIC Copper Link is Down
-- 
Daniel J Blueman
Principal Software Engineer, Numascale Asia
