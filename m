From: Willy Tarreau <w@1wt.eu>
Subject: Re: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xfe/0x17e() with tg3 network
Date: Mon, 24 Nov 2008 14:27:44 +0100
Message-ID: <20081124132744.GB24851@1wt.eu>
References: <491954E1.2050002@gmail.com> <1226403067.7685.1598.camel@twins> <491E49AA.60407@gmail.com> <20081118065006.GC24654@1wt.eu> <20081120031101.GD26448@xw6200.broadcom.net> <20081120053746.GB15168@1wt.eu> <20081120184310.GB27712@xw6200.broadcom.net> <20081120212637.GB23844@1wt.eu> <20081120215318.GB27907@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roger Heflin <rogerheflin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1370 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892AbYKXN1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 08:27:54 -0500
Content-Disposition: inline
In-Reply-To: <20081120215318.GB27907@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matt,

On Thu, Nov 20, 2008 at 01:53:18PM -0800, Matt Carlson wrote:
> > Today, with the notebook connected to a gig switch, I could not reproduce
> > the problem, even after one hour of approximately the same workload. I'll
> > retry with the original 100 Mbps switch on monday.

fairly easier now with the same switch. I just have to transfer 100k objects
over HTTP via this switch to see the problem happen :

tg3: eth0: The system may be re-ordering memory-mapped I/O cycles to the network device, attempting to recover. Please report the problem to the driver maintainer and include system chipset information.
tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
tg3: eth0: Link is down.
tg3: eth0: Link is up at 100 Mbps, full duplex.
tg3: eth0: Flow control is on for TX and on for RX.

The switch is an el-cheapo D-Link 10/100. Note that this time I did not see
any warning. Maybe I did not wait long enough though. Here are some stats
and information I could collect :

root@wtap:/# ethtool -i eth0
driver: tg3
version: 3.94
firmware-version: 5705-v3.14
bus-info: 0000:02:0e.0

root@wtap:/# ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x000000ff (255)
        Link detected: yes

root@wtap:/# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off

root@wtap:/# ethtool -a eth0
Pause parameters for eth0:
Autonegotiate:  on
RX:             on
TX:             on

root@wtap:/# netstat -ni
Kernel Interface table
Iface   MTU Met   RX-OK RX-ERR RX-DRP RX-OVR   TX-OK TX-ERR TX-DRP TX-OVR Flg
eth0   1500   0   61665      0      0      0   65133      0      0      0 BMRU
lo    16436   0  945938      0      0      0  945938      0      0      0 LRU

root@wtap:/# ethtool -S eth0
NIC statistics:
     rx_octets: 52461785
     rx_fragments: 0
     rx_ucast_packets: 61018
     rx_mcast_packets: 0
     rx_bcast_packets: 476
     rx_fcs_errors: 0
     rx_align_errors: 0
     rx_xon_pause_rcvd: 0
     rx_xoff_pause_rcvd: 0
     rx_mac_ctrl_rcvd: 0
     rx_xoff_entered: 0
     rx_frame_too_long_errors: 0
     rx_jabbers: 0
     rx_undersize_packets: 0
     rx_in_length_errors: 0
     rx_out_length_errors: 0
     rx_64_or_less_octet_packets: 0
     rx_65_to_127_octet_packets: 0
     rx_128_to_255_octet_packets: 0
     rx_256_to_511_octet_packets: 0
     rx_512_to_1023_octet_packets: 0
     rx_1024_to_1522_octet_packets: 0
     rx_1523_to_2047_octet_packets: 0
     rx_2048_to_4095_octet_packets: 0
     rx_4096_to_8191_octet_packets: 0
     rx_8192_to_9022_octet_packets: 0
     tx_octets: 54658258
     tx_collisions: 0
     tx_xon_sent: 0
     tx_xoff_sent: 0
     tx_flow_control: 0
     tx_mac_errors: 0
     tx_single_collisions: 0
     tx_mult_collisions: 0
     tx_deferred: 0
     tx_excessive_collisions: 0
     tx_late_collisions: 0
     tx_collide_2times: 0
     tx_collide_3times: 0
     tx_collide_4times: 0
     tx_collide_5times: 0
     tx_collide_6times: 0
     tx_collide_7times: 0
     tx_collide_8times: 0
     tx_collide_9times: 0
     tx_collide_10times: 0
     tx_collide_11times: 0
     tx_collide_12times: 0
     tx_collide_13times: 0
     tx_collide_14times: 0
     tx_collide_15times: 0
     tx_ucast_packets: 65033
     tx_mcast_packets: 0
     tx_bcast_packets: 0
     tx_carrier_sense_errors: 0
     tx_discards: 0
     tx_errors: 0
     dma_writeq_full: 0
     dma_write_prioq_full: 0
     rxbds_empty: 0
     rx_discards: 0
     rx_errors: 0
     rx_threshold_hit: 0
     dma_readq_full: 0
     dma_read_prioq_full: 0
     tx_comp_queue_full: 0
     ring_set_send_prod_index: 0
     ring_status_update: 0
     nic_irqs: 0
     nic_avoided_irqs: 0
     nic_tx_threshold_hit: 0

I will try to go back to older kernels then bisect tg3 changes. I
cannot do this right now since I'm using my laptop for work ;-)

Regards,
Willy

