From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000e oops, sysfs related?
Date: Fri, 05 Oct 2007 09:37:12 -0700
Message-ID: <47066838.7030209@intel.com>
References: <20071005131115.GA31453@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17151 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753115AbXJEQha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 12:37:30 -0400
In-Reply-To: <20071005131115.GA31453@stro.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

maximilian attems wrote:
> Linux tau 2.6.23-rc8-mm2-686 #1 SMP Wed Oct 3 23:56:32 CEST 2007 i686
> GNU/Linux
> 
> eth0 renamed to eth1
> sysfs: duplicate filename 'eth1' can not be created
> WARNING: at fs/sysfs/dir.c:433 sysfs_add_one()
>  [<c0104f9c>] dump_trace+0x68/0x1d5
>  [<c0105121>] show_trace_log_lvl+0x18/0x2c
>  [<c0105b9b>] show_trace+0xf/0x11
>  [<c0105c81>] dump_stack+0x12/0x14
>  [<c01ac02e>] sysfs_add_one+0x54/0xb8
>  [<c01acc2a>] sysfs_create_link+0xb3/0x125
>  [<c023c05f>] device_rename+0x13d/0x196
>  [<c025a970>] dev_change_name+0x137/0x205
>  [<c025b12c>] dev_ioctl+0x357/0x44f
>  [<c017b05f>] do_ioctl+0x1f/0x62
>  [<c017b2d9>] vfs_ioctl+0x237/0x249
>  [<c017b330>] sys_ioctl+0x45/0x5d
>  [<c0103eda>] syscall_call+0x7/0xb
>  [<b7edbde4>] 0xb7edbde4
>  =======================
> net eth1: device_rename: sysfs_create_symlink failed (-17)
> 
> 00:19.0 Ethernet controller [0200]: Intel Corporation 82801I (ICH9 Family) Gigabit Ethernet Controller [8086:294c] (rev 02)
>         Subsystem: Intel Corporation Unknown device [8086:0001]
>         Flags: bus master, fast devsel, latency 0, IRQ 218
>         Memory at 50380000 (32-bit, non-prefetchable) [size=128K]
>         Memory at 503a4000 (32-bit, non-prefetchable) [size=4K]
>         I/O ports at 20e0 [size=32]
>         Capabilities: [c8] Power Management version 2
>         Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
>         Capabilities: [e0] Vendor Specific Information
> 
> 
> no idea if aboves belongs to netdev or sysfs dep.

I'm seeing the same when removing/inserting network drivers frequently, ixgbe does
the same thing: (git://davem/net-2.6.24)

ixgbe 0000:01:00.0: (PCI Express:2.5Gb/s:Width x8) 00:1a:64:3b:81:c3
ixgbe 0000:01:00.0: MAC: 0, PHY: 0, PBA No: d95854-003
ixgbe 0000:01:00.0: Intel(R) 10 Gigabit Network Connection
net eth2: device_rename: sysfs_create_symlink failed (-17)

but I can't make it throw a stack trace.

perhaps one of the sysfs knowledgeable people can take a look at this. We might be
doing something wrong in e1000e / ixgbe at setup time, but I have no idea what.

Auke

> 
