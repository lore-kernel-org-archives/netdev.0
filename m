From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG net-next-2.6] vlan, bonding, bnx2 problems
Date: Mon, 19 Jul 2010 11:14:51 -0700
Message-ID: <1279563291.20559.10.camel@HP1>
References: <a372414c0d74e9ab599d095627353d94@dondevamos.com>
 <1278015554.2782.11.camel@edumazet-laptop>
 <957a5becb6e742b6dc3255b68bef3ba8@dondevamos.com>
 <20100718.153910.67919508.davem@davemloft.net>
 <1279545854.2553.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"pedro.netdev@dondevamos.com" <pedro.netdev@dondevamos.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1417 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760784Ab0GSSQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jul 2010 14:16:04 -0400
In-Reply-To: <1279545854.2553.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding Jay to CC.

On Mon, 2010-07-19 at 06:24 -0700, Eric Dumazet wrote:
> [   32.046479] BUG: scheduling while atomic: ifenslave/4586/0x00000100
> [   32.046540] Modules linked in: ipmi_si ipmi_msghandler hpilo
> bonding ipv6
> [   32.046784] Pid: 4586, comm: ifenslave Tainted: G        W
> 2.6.35-rc1-01453-g3e12451-dirty #836
> [   32.046860] Call Trace:
> [   32.046910]  [<c13421c4>] ? printk+0x18/0x1c
> [   32.046965]  [<c10315c9>] __schedule_bug+0x59/0x60
> [   32.047019]  [<c1342a2c>] schedule+0x57c/0x850
> [   32.047074]  [<c104a106>] ? lock_timer_base+0x26/0x50
> [   32.047128]  [<c1342f78>] schedule_timeout+0x118/0x250
> [   32.047183]  [<c104a2c0>] ? process_timeout+0x0/0x10
> [   32.047238]  [<c13430c5>] schedule_timeout_uninterruptible
> +0x15/0x20
> [   32.047295]  [<c104a345>] msleep+0x15/0x20
> [   32.047350]  [<c1227082>] bnx2_napi_disable+0x52/0x80
> [   32.047405]  [<c122b56f>] bnx2_netif_stop+0x3f/0xa0
> [   32.047460]  [<c122b62a>] bnx2_vlan_rx_register+0x5a/0x80
> [   32.047516]  [<f8ced776>] bond_enslave+0x526/0xa90 [bonding]
> [   32.047576]  [<f8b8f0d0>] ? fib6_clean_node+0x0/0xb0 [ipv6]
> [   32.047634]  [<f8b8dda0>] ? fib6_age+0x0/0x90 [ipv6]
> [   32.047689]  [<c129d2d3>] ? netdev_set_master+0x3/0xc0
> [   32.047746]  [<f8cee4cb>] bond_do_ioctl+0x31b/0x430 [bonding]
> [   32.047804]  [<c105b19a>] ? raw_notifier_call_chain+0x1a/0x20
> [   32.047861]  [<c12abd5d>] ? __rtnl_unlock+0xd/0x10
> [   32.047915]  [<c129f8cd>] ? __dev_get_by_name+0x7d/0xa0
> [   32.047970]  [<c12a19b0>] dev_ifsioc+0xf0/0x290
> [   32.048025]  [<f8cee1b0>] ? bond_do_ioctl+0x0/0x430 [bonding]
> [   32.048081]  [<c12a1ce1>] dev_ioctl+0x191/0x610
> [   32.048136]  [<c12eeb20>] ? udp_ioctl+0x0/0x70
> [   32.048189]  [<c128f67c>] sock_ioctl+0x6c/0x240
> [   32.048243]  [<c10d3a44>] vfs_ioctl+0x34/0xa0
> [   32.048297]  [<c10c7cab>] ? alloc_file+0x1b/0xa0
> [   32.048351]  [<c128f610>] ? sock_ioctl+0x0/0x240
> [   32.048404]  [<c10d4186>] do_vfs_ioctl+0x66/0x550
> [   32.048459]  [<c1022ca0>] ? do_page_fault+0x0/0x350
> [   32.048513]  [<c1022e41>] ? do_page_fault+0x1a1/0x350
> [   32.048568]  [<c129098c>] ? sys_socket+0x5c/0x70
> [   32.048622]  [<c1291860>] ? sys_socketcall+0x60/0x270
> [   32.048677]  [<c10d46a9>] sys_ioctl+0x39/0x60
> [   32.048730]  [<c1002bd0>] sysenter_do_call+0x12/0x26
> [   32.052025] bonding: bond0: enslaving eth1 as a backup interface
> with a down link.
> [   32.100207] tg3 0000:14:04.0: PME# enabled
> [   32.100222]  pci0000:00: wake-up capability enabled by ACPI
> [   32.224488]  pci0000:00: wake-up capability disabled by ACPI
> [   32.224492] tg3 0000:14:04.0: PME# disabled
> [   32.348516] tg3 0000:14:04.0: BAR 0: set to [mem
> 0xfdff0000-0xfdffffff 64bit] (PCI address [0xfdff0000-0xfdffffff]
> [   32.348524] tg3 0000:14:04.0: BAR 2: set to [mem
> 0xfdfe0000-0xfdfeffff 64bit] (PCI address [0xfdfe0000-0xfdfeffff]
> [   32.363711] bonding: bond0: enslaving eth2 as a backup interface
> with a down link.
> 
> 
> 
> For bnx2, it seems commit 212f9934afccf9c9739921
> was not sufficient to correct the "scheduling while atomic" bug...
> enslaving a bnx2 on a bond device with one vlan already set :
>  bond_enslave -> bnx2_vlan_rx_register -> bnx2_netif_stop ->
> bnx2_napi_disable -> msleep()
> 

There are a number of drivers that call napi_disable() during
->ndo_vlan_rx_regsiter().  bnx2 is lockless in the rx path and so we
need to disable NAPI rx processing and wait for it to be done before
modifying the vlgrp.

Jay, is there an alternative to holding the bond->lock when calling the
slave's ->ndo_vlan_rx_register()?


