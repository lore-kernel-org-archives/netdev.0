From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: getting warn once around skb_try_coalesce
Date: Tue, 10 Jul 2012 12:54:26 +0300
Message-ID: <4FFBFBD2.6030004@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shlomo Pongratz <shlomop@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:33705 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751608Ab2GJJ4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 05:56:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Eric,

Another trace that I see here with net-next is this one-time warning. I 
get it always
on the passive side of TCP, something that seems related to GRO, it 
happens only with
IPoIB, not with mlx4_en and igb (when igb get to work on net-next...)

The latest commit in this area is bad43ca8325f493dcaa0896c2f036276af059c7e
"net: introduce skb_try_coalesce()" from Eric.

Or.

-----------[ cut here ]------------
WARNING: at net/core/skbuff.c:3413 skb_try_coalesce+0x1f8/0x31d()
Hardware name: X7DWU
Modules linked in: drbd lru_cache cn autofs4 sunrpc 8021q ib_ipoib 
rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa 
dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath uinput 
mlx4_ib ib_mad ib_core mlx4_en mlx4_core igb sg joydev kvm microcode 
pcspkr rng_core ioatdma dm_mod dca floppy shpchp button sr_mod ext3 jbd 
usb_storage sd_mod ata_piix libata scsi_mod ehci_hcd uhci_hcd [last 
unloaded: scsi_wait_scan]
Pid: 0, comm: swapper/1 Tainted: G          I 
3.5.0-rc1-00107-gf5bae8a-dirty #57
Call Trace:
  <IRQ>  [<ffffffff8102ab65>] warn_slowpath_common+0x80/0x98
  [<ffffffff8102ab92>] warn_slowpath_null+0x15/0x17
  [<ffffffff812c5a73>] skb_try_coalesce+0x1f8/0x31d
  [<ffffffff8130a6ad>] tcp_try_coalesce+0x4c/0xa0
  [<ffffffff8130a759>] tcp_queue_rcv+0x58/0xe1
  [<ffffffff8130d4ca>] tcp_data_queue+0x1bd/0xa8d
  [<ffffffff8130ecba>] tcp_rcv_established+0x646/0x6fc
  [<ffffffff81314fd7>] ? tcp_v4_rcv+0x427/0xa1b
  [<ffffffff81314892>] tcp_v4_do_rcv+0xd8/0x3f6
  [<ffffffff8136aefb>] ? _raw_spin_lock_nested+0x41/0x48
  [<ffffffff813151a5>] tcp_v4_rcv+0x5f5/0xa1b
  [<ffffffff812f8626>] ip_local_deliver_finish+0x1a1/0x2b2
  [<ffffffff812f84ba>] ? ip_local_deliver_finish+0x35/0x2b2
  [<ffffffff812f87a9>] ip_local_deliver+0x72/0x79
  [<ffffffff812f820d>] ip_rcv_finish+0x399/0x3b1
  [<ffffffff812f845f>] ip_rcv+0x23a/0x260
  [<ffffffff812cd086>] __netif_receive_skb+0x3b2/0x41b
  [<ffffffff812cce0e>] ? __netif_receive_skb+0x13a/0x41b
  [<ffffffff812ce93c>] netif_receive_skb+0xee/0xf7
  [<ffffffff81322512>] ? inet_compat_ioctl+0x1e/0x1e
  [<ffffffff812ceb90>] napi_gro_complete+0x133/0x140
  [<ffffffff812ceaab>] ? napi_gro_complete+0x4e/0x140
  [<ffffffff812ced3d>] dev_gro_receive+0x1a0/0x2fb
  [<ffffffff812cec19>] ? dev_gro_receive+0x7c/0x2fb
  [<ffffffff812cf1c5>] napi_gro_receive+0x105/0x11e
  [<ffffffffa02ed6d4>] ipoib_ib_handle_rx_wc+0x243/0x277 [ib_ipoib]
  [<ffffffffa02ee84e>] ipoib_poll+0xa9/0x12d [ib_ipoib]
  [<ffffffff812cf355>] net_rx_action+0xc1/0x1ee
  [<ffffffff81031e4a>] __do_softirq+0xff/0x1de
  [<ffffffff813735cc>] call_softirq+0x1c/0x30
  [<ffffffff81003174>] do_softirq+0x38/0x80
  [<ffffffff81031b23>] irq_exit+0x4e/0x83
  [<ffffffff810029dd>] do_IRQ+0x98/0xaf
  [<ffffffff8136b92c>] common_interrupt+0x6c/0x6c
  <EOI>  [<ffffffff8100850c>] ? mwait_idle+0x13c/0x208
  [<ffffffff81008503>] ? mwait_idle+0x133/0x208
  [<ffffffff810089f1>] cpu_idle+0x6e/0xab
  [<ffffffff81363763>] start_secondary+0x1b9/0x1bd
---[ end trace fdf1b0e917b37732 ]---
