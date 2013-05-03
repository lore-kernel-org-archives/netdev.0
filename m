From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: ixgbe: RTNL assertion failed
Date: Fri, 3 May 2013 23:17:39 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF222866464C28E112@ORSMSX110.amr.corp.intel.com>
References: <20130503120907.4f13d41b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15600 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755512Ab3ECXRl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 19:17:41 -0400
In-Reply-To: <20130503120907.4f13d41b@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Stephen Hemminger
> Sent: Friday, May 03, 2013 12:09 PM
> To: Kirsher, Jeffrey T
> Cc: netdev@vger.kernel.org
> Subject: ixgbe: RTNL assertion failed
> 
> Running 3.9 kernel, ixgbe is splatting on resume from suspend.
> 
> [26430.213254] ixgbe 0000:01:00.0: setting latency timer to 64 [26430.213257]
> RTNL: assertion failed at /build/buildd-linux_3.2.41-2-amd64-Wvc92F/linux-
> 3.2.41/net/core/dev.c (1758) [26430.213259] Pid: 7839, comm: kworker/u:1
> Not tainted 3.2.0-4-amd64 #1 Debian 3.2.41-2 [26430.213261] Call Trace:
> [26430.213266]  [<ffffffff8128b89e>] ?
> netif_set_real_num_tx_queues+0x5c/0x15e
> [26430.213286]  [<ffffffffa0051749>] ? ixgbe_set_num_queues+0x208/0x221
> [ixgbe] [26430.213287] sd 0:0:0:0: [sda] Starting disk [26430.213292]
> [<ffffffffa0054949>] ? ixgbe_init_interrupt_scheme+0x16/0x790 [ixgbe]
> [26430.213299]  [<ffffffffa0055aae>] ? ixgbe_resume+0x7a/0xe3 [ixgbe]
> [26430.213303]  [<ffffffff81255b7c>] ? pm_op+0xa1/0x141 [26430.213305]
> [<ffffffff81255f40>] ? device_resume+0xa2/0xfc [26430.213307]
> [<ffffffff81255fae>] ? async_resume+0x14/0x38 [26430.213311]
> [<ffffffff810648c4>] ? async_run_entry_fn+0x96/0x142 [26430.213313]
> [<ffffffff8105b225>] ? process_one_work+0x161/0x264 [26430.213316]
> [<ffffffff8105c1e6>] ? worker_thread+0xc2/0x145 [26430.213318]
> [<ffffffff8105c124>] ? manage_workers.isra.25+0x15b/0x15b
> [26430.213320]  [<ffffffff8105f321>] ? kthread+0x76/0x7e [26430.213323]
> [<ffffffff81354ab4>] ? kernel_thread_helper+0x4/0x10 [26430.213325]
> [<ffffffff8105f2ab>] ? kthread_worker_fn+0x139/0x139 [26430.213327]
> [<ffffffff81354ab0>] ? gs_change+0x13/0x13
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

Hey Stephen,

I'm having a little problem finding a path were we call netif_set_real_num_tx_queues without holding RTNL in net-next.  While looking over the stack dump one of our engineers noticed the text "Not tainted 3.2.0-4-amd64 #1 Debian 3.2.41-2 ".  Could this mean I'm looking over the wrong source?  It would make me feel better as I'm not seeing anything as is. :)

Thanks,
-Don Skidmore <donald.c.skidmore@intel.com>
