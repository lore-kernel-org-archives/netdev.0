From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: 2.6.27-rc1-git4 BUG: sched while atomic
Date: Mon, 4 Aug 2008 10:17:12 -0700
Message-ID: <20080804101712.659780ef@extreme>
References: <20080804094835.da083484.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, mchan@broadcom.com
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:44981 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754182AbYHDRRO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 13:17:14 -0400
In-Reply-To: <20080804094835.da083484.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Aug 2008 09:48:35 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> Usually (e.g., in 2.6.27-rc1 & earlier), I see lots of these messages for
> some reason:
> 
> tg3: eth2: Link is up at 1000 Mbps, full duplex.
> tg3: eth2: Flow control is off for TX and off for RX.
> tg3: eth3: Link is up at 1000 Mbps, full duplex.
> tg3: eth3: Flow control is off for TX and off for RX.
> bnx2: eth1: using MSI
> bnx2: eth1 NIC SerDes Link is Up, 1000 Mbps full duplex
> tg3: eth2: Link is up at 1000 Mbps, full duplex.
> tg3: eth2: Flow control is off for TX and off for RX.
> tg3: eth3: Link is up at 1000 Mbps, full duplex.
> tg3: eth3: Flow control is off for TX and off for RX.
> bnx2: eth1: using MSI
> bnx2: eth1 NIC SerDes Link is Up, 1000 Mbps full duplex
> tg3: eth2: Link is up at 1000 Mbps, full duplex.
> tg3: eth2: Flow control is off for TX and off for RX.
> tg3: eth3: Link is up at 1000 Mbps, full duplex.
> tg3: eth3: Flow control is off for TX and off for RX.
> bnx2: eth1: using MSI
> bnx2: eth1 NIC SerDes Link is Up, 1000 Mbps full duplex
> tg3: eth2: Link is up at 1000 Mbps, full duplex.
> tg3: eth2: Flow control is off for TX and off for RX.
> tg3: eth3: Link is up at 1000 Mbps, full duplex.
> tg3: eth3: Flow control is off for TX and off for RX.
> bnx2: eth1: using MSI

You have a bad cable or broken ethernet switch that is causing
the link to restart autonegotiation.

> In 2.6.27-rc1-git4, I now see this (39 times):
> 
> BUG: scheduling while atomic: ifconfig/16971/0x00000100
> Modules linked in: parport_pc lp parport tg3 lpfc cciss ehci_hcd ohci_hcd uhci_hcd
> Pid: 16971, comm: ifconfig Not tainted 2.6.27-rc1-git4 #1
> 
> Call Trace:
>  [<ffffffff80283db9>] ? page_add_new_anon_rmap+0x20/0x22
>  [<ffffffff802310e9>] __schedule_bug+0x62/0x66
>  [<ffffffff80551146>] schedule+0x99/0x759
>  [<ffffffff8023dc9f>] ? __mod_timer+0xc1/0xd3
>  [<ffffffff8055584a>] ? do_page_fault+0x473/0x7dd
>  [<ffffffff80551ce4>] schedule_timeout+0x8d/0xb4
>  [<ffffffff8023d99e>] ? process_timeout+0x0/0xb
>  [<ffffffff80551cdf>] ? schedule_timeout+0x88/0xb4
>  [<ffffffff80551d24>] schedule_timeout_uninterruptible+0x19/0x1b
>  [<ffffffff8023dcc5>] msleep+0x14/0x1e
>  [<ffffffff80375f2f>] pci_set_power_state+0x1cd/0x292
>  [<ffffffff803739fc>] ? pci_bus_write_config_dword+0x64/0x73
>  [<ffffffffa00651b6>] tg3_set_power_state+0x58/0x884 [tg3]
>  [<ffffffff80552525>] ? __mutex_lock_slowpath+0x1d8/0x1e5
>  [<ffffffffa006b57a>] tg3_open+0x46/0x6cc [tg3]
>  [<ffffffff80552525>] ? __mutex_lock_slowpath+0x1d8/0x1e5
>  [<ffffffff804bdcfe>] dev_open+0x73/0xa8
>  [<ffffffff804bbf5e>] dev_change_flags+0xab/0x167
>  [<ffffffff804f7094>] devinet_ioctl+0x269/0x5da
>  [<ffffffff8026d9da>] ? unlock_page+0x2d/0x32
>  [<ffffffff804f7ca8>] inet_ioctl+0x92/0xaa
>  [<ffffffff804b2046>] sock_ioctl+0x1d1/0x1fb
>  [<ffffffff802a50aa>] vfs_ioctl+0x2a/0x77
>  [<ffffffff802a534c>] do_vfs_ioctl+0x255/0x272
>  [<ffffffff8055584a>] ? do_page_fault+0x473/0x7dd
>  [<ffffffff802a53ab>] sys_ioctl+0x42/0x67
>  [<ffffffff8020beeb>] system_call_fastpath+0x16/0x1b

This is a bug.
