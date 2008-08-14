From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Thu, 14 Aug 2008 22:27:49 +0400
Message-ID: <48A47925.3000409@vlnb.net>
References: <20080812.150246.42068558.davem@davemloft.net>	<200808121521.10101.divy@chelsio.com>	<48A32976.7060504@vlnb.net> <20080813.132319.175666454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040202000802050103050507"
Cc: open-iscsi@googlegroups.com, rdreier@cisco.com, rick.jones2@hp.com,
	jgarzik@pobox.com, swise@opengridcomputing.com, kxie@chelsio.com,
	netdev@vger.kernel.org, michaelc@cs.wisc.edu, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, dm@chelsio.com,
	leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080813.132319.175666454.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040202000802050103050507
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Vladislav Bolkhovitin <vst@vlnb.net>
> Date: Wed, 13 Aug 2008 22:35:34 +0400
> 
>> This is because the target sends data in a zero-copy manner, so its
>> CPU is capable to deal with the load, but on the initiator there are
>> additional data copies from skb's to page cache and from page cache
>> to application.
> 
> If you've actually been reading at all what I've been saying in this
> thread you'll see that I've described a method to do this copy
> avoidance in a completely stateless manner.
> 
> You don't need to implement a TCP stack in the card in order to do
> data placement optimizations.  They can be done completely stateless.

Sure, I read what you wrote before writing (although, frankly, didn't 
get the idea). But I don't think that overall it would be as efficient 
as full hardware offload. See my reply to Jeff Garzik about that.

> Also, large portions of the cpu overhead are transactional costs,
> which are significantly reduced by existing technologies such as
> LRO.

The test used Myricom Myri-10G cards (myri10ge driver), which support 
LRO. And from ethtool -S output I conclude it was enabled. Just in case, 
I attached it, so you can recheck me.

Thus, apparently, LRO doesn't make a fundamental difference. Maybe this 
particular implementation isn't too efficient, I don't know. I don't 
have enough information for that.

Vlad


--------------040202000802050103050507
Content-Type: text/plain;
 name="ethtool_initiator.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ethtool_initiator.txt"

NIC statistics:
     rx_packets: 471090527
     tx_packets: 175404246
     rx_bytes: 683684492944
     tx_bytes: 636200696592
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     rx_skbs: 0
     alloc_order: 0
     builtin_fw: 0
     napi: 1
     tx_boundary: 4096
     WC: 2
     irq: 1268
     MSI: 1
     MSIX: 0
     read_dma_bw_MBs: 1575
     write_dma_bw_MBs: 1375
     read_write_dma_bw_MBs: 2406
     serial_number: 320283
     watchdog_resets: 0
     link_changes: 2
     link_up: 1
     dropped_link_overflow: 0
     dropped_link_error_or_filtered: 0
     dropped_pause: 0
     dropped_bad_phy: 0
     dropped_bad_crc32: 0
     dropped_unicast_filtered: 0
     dropped_multicast_filtered: 0
     dropped_runt: 0
     dropped_overrun: 0
     dropped_no_small_buffer: 0
     dropped_no_big_buffer: 479
     ----------- slice ---------: 0
     tx_pkt_start: 176354843
     tx_pkt_done: 176354843
     tx_req: 474673372
     tx_done: 474673372
     rx_small_cnt: 19592127
     rx_big_cnt: 462319631
     wake_queue: 0
     stop_queue: 0
     tx_linearized: 0
     LRO aggregated: 481899984
     LRO flushed: 43071334
     LRO avg aggr: 11
     LRO no_desc: 0

--------------040202000802050103050507--
