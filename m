From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Thu, 28 Mar 2013 01:40:24 +0100
Message-ID: <20130328004024.GA2176@order.stressinduktion.org>
References: <20130324052300.GA12968@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7D1E@nasanexd02f.na.qualcomm.com> <20130326042700.GC29705@order.stressinduktion.org> <157393863283F442885425D2C4542856489E821B@nasanexd02f.na.qualcomm.com> <20130326044025.GD29705@order.stressinduktion.org> <157393863283F442885425D2C4542856489E8232@nasanexd02f.na.qualcomm.com> <20130327220248.GD23223@order.stressinduktion.org> <157393863283F442885425D2C45428564F1FDF82@nasanexd02f.na.qualcomm.com> <20130327223433.GE23223@order.stressinduktion.org> <157393863283F442885425D2C45428564F1FFFCE@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35267 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab3C1Ak0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 20:40:26 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C45428564F1FFFCE@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 12:10:57AM +0000, Huang, Xiong wrote:
> There is no much difference on those registers :(
> But you could try to replace :
> 
> static void atl1e_cal_ring_size(struct atl1e_adapter *adapter, u32 *ring_size)
> {
> 	*ring_size = ((u32)(adapter->tx_ring.count *
> 		     sizeof(struct atl1e_tpd_desc) + 7
> 			/* tx ring, qword align */
> 		     + adapter->rx_ring.real_page_size * AT_PAGE_NUM_PER_QUEUE *
> 			adapter->num_rx_queues + 31
> 			/* rx ring,  32 bytes align */
> 		     + (1 + AT_PAGE_NUM_PER_QUEUE * adapter->num_rx_queues) *
> 			16 + 15));
> 			/* tx, rx cmd, dword align   */
> }
> 
> 
> static int atl1e_setup_ring_resources(struct atl1e_adapter *adapter)
> {
> .....
> 	/* Init CMB dma address */
> 	offset = roundup(offset, 16);
> 	tx_ring->cmb_dma = adapter->ring_dma + offset;
> 	tx_ring->cmb = adapter->ring_vir_addr + offset;
> 	offset += sizeof(u32);
> 	offset = roundup(offset, 16);
> 
> 	for (i = 0; i < adapter->num_rx_queues; i++) {
> 		for (j = 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {
> 			rx_page_desc[i].rx_page[j].write_offset_dma =
> 				adapter->ring_dma + offset;
> 			rx_page_desc[i].rx_page[j].write_offset_addr =
> 				adapter->ring_vir_addr + offset;
> 			offset += sizeof(u32);
> 			offset = roundup(offset, 16);
> 		}
> 	}
> .....
> 
> 
> 
> Just guess, no confidence on it ....

No, problem still persists. :(

Btw, in the meantime I extracted another mmiotrace (this time with a dhcp
exchange) and resolved the symbols:

https://gist.github.com/hannes/5259468/raw/4c22dff854254c46534c1b87e477eff7d3ca2c5d/mmiotrace.txt

Perhaps it helps.

Thanks,

  Hannes
