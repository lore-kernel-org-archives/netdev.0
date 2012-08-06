From: Marco Castiglione <rebelyouth.hacklab@gmail.com>
Subject: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5 corrupted using NFS
Date: Mon, 6 Aug 2012 13:02:32 -0400
Message-ID: <201208061302.32582.marco.castiglione@yahoo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:53477 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756718Ab2HFRCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 13:02:35 -0400
Received: by ggnl2 with SMTP id l2so2708633ggn.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 10:02:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a problem with :

Ethernet controller: Atheros Communications Inc. AR8121/AR8113/AR8114
Gigabit or Fast Ethernet (rev b0)
        Subsystem: ASUSTeK Computer Inc. Device 831c
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 46
        Region 0: Memory at fbec0000 (64-bit, non-prefetchable) [size=256K]
        Region 2: I/O ports at dc00 [size=128]
        Capabilities: <access denied>
        Kernel driver in use: ATL1E

The driver working fine except for nfs3 and nfs4

If I try to copy a file bigger of 400 mb the file get corrupted, If I try
with multiple files I have a kernel oops

I tried different system and service (Ftp,samba) and they working fine.

I also tried to set nfs to use udp, it kinda fix the problem but only in
part (I get 1 on 3 big file with md5 mismatch).

I notice in almost every kernel from 2.6 to now 3.2.15 the driver is the
same version

Filename:       /lib/modules/3.2.0-2-amd64/
kernel/drivers/net/ethernet/atheros/atl1e/atl1e.ko
version:        1.0.0.7-NAPI
license:        GPL
description:    Atheros 1000M Ethernet Network Driver
author:         Atheros Corporation, <xiong.huang@atheros.com>, Jie Yang <
jie.yang@atheros.com>
srcversion:     6E5949327D7FDF32D5F4A5B
alias:          pci:v00001969d00001066sv*sd*bc*sc*i*
alias:          pci:v00001969d00001026sv*sd*bc*sc*i*
depends:
intree:         Y
vermagic:       3.2.0-2-amd64 SMP mod_unload modversions
parm:           tx_desc_cnt:Transmit description count (array of int)
parm:           rx_mem_size:memory size of rx buffer(KB) (array of int)
parm:           media_type:MediaType Select (array of int)
parm:           int_mod_timer:Interrupt Moderator Timer (array of int)

I found on ubuntu website the last version of the driver is 1.0.1.14 with
this change log :

1.0.1.14
    1. don't define napi_struct in kcompat.h when GRO isn't supported.

1.0.1.13
    1. fix AR8151-A hang when plug in LAN cable by cleaning bit1 of
REG(0x1114).

1.0.1.12
    1. fix tpd, rfd, rrs, configure error for powerpc

1.0.1.11
    1. only save power when WOL enable.

1.0.1.10
    1. add l1d 2.0 support.
    2. fix atl1c_phy_power_saving bug.

1.0.1.9
    1. fix AR8131 reset error TX pending.
    2. add AR8152 description.

1.0.1.8
    1. add L2CB V2.0 support.

1.0.1.7
    1. fix L0s/L1 bug.
    2. update suspend procedure.

1.0.1.6
    1. fix valn error.
    2. use common task instead of reset task and link change task.
    3. reset phy when link down.

1.0.1.5
    1. change rx mod.

1.0.1.4
    1. add l1d support.

1.0.1.3
    1. fix TSO error.

1.0.1.2
    1. fix compile error for kernel >= 2.6.30.

1.0.1.1
    1. add L2cB support.

1.0.0.10
    1. fix memory leak when power suspend.

1.0.0.9
    1. do power saving when bootup with link lost.
    2. remove ATL1C_INTR_CLEAR_ON_READ for power saving

1.0.0.8
    1. remove dump_stack(), which was used for debugging.


So I found out the TSO is corrupt in the current version  and that explain
with the udp setting do the trick.

Now I tried to compile the new version from
AR81Family-linux-v1.0.1.14.tar.gz but was made for the 2.6 so I can't
compile.( <http://goog_56610235>
http://media.cdn.ubuntu-de.org/forum/attachments/2666793/AR81Family-linux-
v1.0.1.14_10.10.tar.gz
)

The Atheros support and web page is gone after Qualcomm acquisition and the
patch I found on Ubuntu forum don't work either (
http://ubuntuforums.org/attachment.php?attachmentid=182141&d=1296221015)

I found out lots of people have the same issue and they using samba at the
moment.

My temp solution is use a usb/eth adapter with ax8112 chipset but it run at
100mbps.

SO my request is this : Is possible for somebody of the kernel team look
the code inside AR81Family-linux-v1.0.1.14.tar.gz  and update the one in
the kernel 3.x?

Thank you for you time and consideration
