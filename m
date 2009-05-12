From: Subrata Modak <subrata@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/7] can: CAN network device driver interface and drivers
Date: Tue, 12 May 2009 15:16:31 +0530
Message-ID: <20090512094631.26592.81609.sendpatchset@subratamodak.linux.ibm.com>
Cc: Subrata Modak <subrata@linux.vnet.ibm.com>,
	ltp-list <ltp-list@lists.sf.net>,
	<socketcan-users@lists.berlios.de>, <netdev@vger.kernel.org>
To: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:44460 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834AbZELJqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2009 05:46:34 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4C9mmE0013887
	for <netdev@vger.kernel.org>; Tue, 12 May 2009 05:48:48 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4C9kYoG150242
	for <netdev@vger.kernel.org>; Tue, 12 May 2009 05:46:34 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4C9kYaB019151
	for <netdev@vger.kernel.org>; Tue, 12 May 2009 05:46:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver/Wolfgang,

> Hello,
> 
> here comes v2 of the patch series posted some time ago. See
> 
>  http://marc.info/?l=linux-netdev&m=123507025810612&w=4.
> 
> Changes since v1:
> 
> - The SysFS interface has been replaced by the Netlink interface as
>  suggested by Patrick. For further information have a look to
>  chapter 6.5 of "Documentation/networking/can.txt" and the header
>  file "include/linux/can/netdev.h". The patch for the "ip" program of
>  the iproute2 utility suite will be provided separately.
> 
> - The restart function is now properly protected by "dev->tx_lock"
>  using the "netif_tx_[lock|unlock]" functions.
> 
> - For the  restart, the device driver must now handle CAN_MODE_STOP as
>  well, apart from CAN_MODE_START to avoid race conditions.
> 
> - The "irq_lock" member of "struct can_priv" has been removed. The CAN
>  controller driver may should provide its own synchronization if
>  necessary.
> 
> - The restart function is now protected by "dev->tx_lock" using the
>  "netif_tx_lock/unlock" functions.
> 
> - Cleanup timer usage for the restart function.
> 
> - The unused do_set/get_ctrlmode member of "struct can_priv" have been
>  removed.
> 
> - "const" has been added to "struct net_device" for some functions not
>  allowed to touch that structure.
> 
> - The library functions "can_set_bittiming" and "can_close_cleanup" have
>  been renamed to the more general names "open_candev" and
>  "close_candev", respectively.
> 
> - Use "del_timer_sync" instead of "del_timer" for the  re-start timer.
> 
> - The macro "ND2D()" has been replaced by "dev->dev.parent" as it does
>  not make the code more readable.
> 
> - Fix improper BTR setting for triple-sampling for the SJA1000 as
>  pointed out by Oliver.
> 
> - Dont use __u8 but __u32 as before for some members of "struct
>  can_bittiming[_const]" to avoid alignment trouble.
> 
> - Definitions shared with user-space applications have been moved to
>  "include/linux/can/netlink.h".
> 
> - Various other minor correction suggested on the netdev ML.
> 
> - The MSCAN driver for the MPC5200 has been removed. It needs to be
>  presented on the Linuxppc-dev and Devicetree-discuss ML as well,
>  which will be done by a sub-sequent patch.
> 
> - Add more source code documentation, especially for the structures
>  and functions related to bit-timing.
> 
> The PF_CAN protocol family for the Controller Area Network is available
> in the kernel since version 2.6.25 but drivers for real CAN devices are
> still missing. This patch series adds a generic CAN network device
> driver interface and, as a start, a few drivers. It is the result of the
> on-going discussion and development of the Socket-CAN project hosted at
> the BerliOS web-server (http://developer.berlios.de/projects/socketcan).
> The patch series consists of the following patches:
> 
>  1/8) can: Documentation for the CAN device driver interface
>  2/8) can: Update MAINTAINERS and CREDITS file
>  3/8) can: CAN Network device driver and Netlink interface
>  4/8) can: Driver for the SJA1000 CAN controller
>  5/8) can: SJA1000 generic platform bus driver
>  6/8) can: SJA1000 driver for EMS PCI cards
>  7/8) can: SJA1000 driver for Kvaser PCI cards

Would you also like to send a patch to update the testcases for CAN in LTP
(http://ltp.cvs.sourceforge.net/viewvc/ltp/ltp/testcases/network/can/filter-tests/) ?
These tests were originally picked up from:
http://svn.berlios.de/wsvn/socketcan/trunk/test/?rev=877&amp;sc=1

Regards--
Subrata

> 
> Please consider these patches for inclusion.
> 
> Thanks,
> 
> Wolfgang.
> 
> 
