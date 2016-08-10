From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] drivers: net: cpsw: fix kmemleak false-positive reports
 for sk buffers
Date: Wed, 10 Aug 2016 22:25:26 +0530
Message-ID: <c558bd0a-edaa-79b2-2d64-38f7115a54c9@ti.com>
References: <20160809120944.23185-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160809120944.23185-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 09 August 2016 05:39 PM, Grygorii Strashko wrote:
> Kmemleak reports following false positive memory leaks for each sk
> buffers allocated by CPSW (__netdev_alloc_skb_ip_align()) in
> cpsw_ndo_open() and cpsw_rx_handler():
> 
> unreferenced object 0xea915000 (size 2048):
>   comm "systemd-network", pid 713, jiffies 4294938323 (age 102.180s)
>   hex dump (first 32 bytes):
>     00 58 91 ea ff ff ff ff ff ff ff ff ff ff ff ff  .X..............
>     ff ff ff ff ff ff fd 0f 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<c0108680>] __kmalloc_track_caller+0x1a4/0x230
>     [<c0529eb4>] __alloc_skb+0x68/0x16c
>     [<c052c884>] __netdev_alloc_skb+0x40/0x104
>     [<bf1ad29c>] cpsw_ndo_open+0x374/0x670 [ti_cpsw]
>     [<c053c3d4>] __dev_open+0xb0/0x114
>     [<c053c690>] __dev_change_flags+0x9c/0x14c
>     [<c053c760>] dev_change_flags+0x20/0x50
>     [<c054bdcc>] do_setlink+0x2cc/0x78c
>     [<c054c358>] rtnl_setlink+0xcc/0x100
>     [<c054b34c>] rtnetlink_rcv_msg+0x184/0x224
>     [<c056467c>] netlink_rcv_skb+0xa8/0xc4
>     [<c054b1c0>] rtnetlink_rcv+0x2c/0x34
>     [<c0564018>] netlink_unicast+0x16c/0x1f8
>     [<c0564498>] netlink_sendmsg+0x334/0x348
>     [<c052015c>] sock_sendmsg+0x1c/0x2c
>     [<c05213e0>] SyS_sendto+0xc0/0xe8
> 
> unreferenced object 0xec861780 (size 192):
>   comm "softirq", pid 0, jiffies 4294938759 (age 109.540s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>     00 00 00 00 00 b0 5a ed 00 00 00 00 00 00 00 00  ......Z.........
>   backtrace:
>     [<c0107830>] kmem_cache_alloc+0x190/0x208
>     [<c052c768>] __build_skb+0x30/0x98
>     [<c052c8fc>] __netdev_alloc_skb+0xb8/0x104
>     [<bf1abc54>] cpsw_rx_handler+0x68/0x1e4 [ti_cpsw]
>     [<bf11aa30>] __cpdma_chan_free+0xa8/0xc4 [davinci_cpdma]
>     [<bf11ab98>] __cpdma_chan_process+0x14c/0x16c [davinci_cpdma]
>     [<bf11abfc>] cpdma_chan_process+0x44/0x5c [davinci_cpdma]
>     [<bf1adc78>] cpsw_rx_poll+0x1c/0x9c [ti_cpsw]
>     [<c0539180>] net_rx_action+0x1f0/0x2ec
>     [<c003881c>] __do_softirq+0x134/0x258
>     [<c0038a00>] do_softirq+0x68/0x70
>     [<c0038adc>] __local_bh_enable_ip+0xd4/0xe8
>     [<c0640994>] _raw_spin_unlock_bh+0x30/0x34
>     [<c05f4e9c>] igmp6_group_added+0x4c/0x1bc
>     [<c05f6600>] ipv6_dev_mc_inc+0x398/0x434
>     [<c05dba74>] addrconf_dad_work+0x224/0x39c
> 
> This happens because CPSW allocates SK buffers and then passes
> pointers on them in CPDMA where they stored in internal CPPI RAM
> (SRAM) which belongs to DEV MMIO space. Kmemleak does not scan IO
> memory and so reports memory leaks.
> 
> Hence, mark allocated sk buffers as false positive explicitly.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
