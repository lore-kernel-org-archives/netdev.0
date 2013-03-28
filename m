From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Thu, 28 Mar 2013 04:29:34 +0100
Message-ID: <20130328032934.GD2176@order.stressinduktion.org>
References: <20130327220248.GD23223@order.stressinduktion.org> <157393863283F442885425D2C45428564F1FDF82@nasanexd02f.na.qualcomm.com> <20130327223433.GE23223@order.stressinduktion.org> <157393863283F442885425D2C45428564F1FFFCE@nasanexd02f.na.qualcomm.com> <20130328004024.GA2176@order.stressinduktion.org> <157393863283F442885425D2C45428564F200FE9@nasanexd02f.na.qualcomm.com> <20130328011602.GB2176@order.stressinduktion.org> <157393863283F442885425D2C45428564F200FFD@nasanexd02f.na.qualcomm.com> <20130328031932.GC2176@order.stressinduktion.org> <157393863283F442885425D2C45428564F201026@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35450 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753649Ab3C1D3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 23:29:36 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C45428564F201026@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 03:25:29AM +0000, Huang, Xiong wrote:
> Please don't revise following code:
> 
> 			rx_page->read_offset +=
> 				(((u32)((prrs->word1 >> RRS_PKT_SIZE_SHIFT) &
> 				RRS_PKT_SIZE_MASK) +
> 				sizeof(struct atl1e_recv_ret_status) + 31) &
> 						0xFFFFFFE0);
> 
> Here 32bytes alignment is no matter with Page alignment.

If I revert this change I get sequence errors:

[  781.449864] ATL1E 0000:04:00.0: irq 45 for MSI/MSI-X
[  781.454634] IPv6: ADDRCONF(NETDEV_UP): p33p1: link is not ready
[  782.893744] ATL1E 0000:04:00.0 p33p1: NIC Link is Up <100 Mbps Full Duplex>
[  782.893797] IPv6: ADDRCONF(NETDEV_CHANGE): p33p1: link becomes ready
[  783.194443] ATL1E 0000:04:00.0 p33p1: rx sequence number error (rx=0) (expect=1)
[  783.204497] ATL1E 0000:04:00.0 p33p1: NIC Link is Up <100 Mbps Full Duplex>
[  783.225336] ATL1E 0000:04:00.0 p33p1: rx sequence number error (rx=0) (expect=1)
[  783.236636] ATL1E 0000:04:00.0 p33p1: NIC Link is Up <100 Mbps Full Duplex>
[  783.462652] ATL1E 0000:04:00.0 p33p1: rx sequence number error (rx=0) (expect=1)
[  783.472530] ATL1E 0000:04:00.0 p33p1: NIC Link is Up <100 Mbps Full Duplex>
[  784.038976] ATL1E 0000:04:00.0 p33p1: rx sequence number error (rx=0) (expect=1)
[  784.047354] ATL1E 0000:04:00.0 p33p1: NIC Link is Up <100 Mbps Full Duplex>
...
