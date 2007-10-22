From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [patch 0/1] remove header_ops bug in qeth driver
Date: Mon, 22 Oct 2007 09:24:32 +0200
Message-ID: <20071022072431.GA8044@osiris.boeblingen.de.ibm.com>
References: <20071019215538.395133000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, mschwid2@linux.vnet.ibm.com,
	apw@shadowen.org, linux-kernel@vger.kernel.org,
	kamalesh@linux.vnet.ibm.com, kaber@trash.net,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Ursula Braun <braunu@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:43819 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbXJVHYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 03:24:35 -0400
Content-Disposition: inline
In-Reply-To: <20071019215538.395133000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 11:55:38PM +0200, Ursula Braun wrote:
> -- 
> Remove qeth driver bug introduced by this commit:
> 
> commit 3b04ddde02cf1b6f14f2697da5c20eca5715017f
> Author: Stephen Hemminger <shemminger@linux-foundation.org>
> Date:   Tue Oct 9 01:40:57 2007 -0700
> 
>     [NET]: Move hardware header operations out of netdevice.

Still broken:

Kernel BUG at 0000000000000002 [verbose debug info unavailable] 
illegal operation: 0001 [#1] 
Modules linked in: 
CPU:    1    Not tainted 
Process ip (pid: 2170, task: 0000000001f1d038, ksp: 0000000002d87b30) 
Krnl PSW : 0704200180000000 0000000000000002 (0x2) 
           R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:2 PM:0 EA:3 
Krnl GPRS: 0000000000000000 0000000000000038 00000000027c2800 00000000016d6000
           00000000000086dd 00000000029f8b78 0000000000000000 00000000029f8b00
           00000000029f8b40 00000000027c2800 0000000000000000 0000000002d874c8
           00000000016d6000 00000000003cb960 00000000002c58d2 0000000002d874c8
Krnl Code:>0000000000000002: 0000               unknown 
           0000000000000004: 0000               unknown 
           0000000000000006: 0000               unknown 
           0000000000000008: 0000               unknown 
           000000000000000a: 0000               unknown 
           000000000000000c: 0000               unknown 
           000000000000000e: 0000               unknown 
           0000000000000010: 0000               unknown 
Call Trace: 
([<00000000002c588e>] neigh_connected_output+0x76/0x118) 
 [<0000000000339e00>] ip6_output2+0x22c/0x478 
 [<000000000033a46c>] ip6_output+0x250/0x10fc 
 [<000000000034d65e>] __ndisc_send+0x416/0x768 
 [<000000000034da1c>] ndisc_send_rs+0x6c/0x7c 
 [<0000000000340776>] addrconf_dad_completed+0xb2/0x100 
 [<000000000034269c>] addrconf_dad_start+0xa4/0x134 
 [<000000000034279e>] addrconf_add_linklocal+0x72/0xa4 
 [<00000000003439d4>] addrconf_notify+0x6ec/0x8bc 
 [<000000000039905a>] notifier_call_chain+0x5e/0xa4 
 [<0000000000062832>] __raw_notifier_call_chain+0x26/0x38 
 [<0000000000062872>] raw_notifier_call_chain+0x2e/0x40 
 [<00000000002beaa8>] call_netdevice_notifiers+0x34/0x48 
 [<00000000002c0288>] dev_open+0xd4/0xe0 
 [<00000000002bed42>] dev_change_flags+0x14e/0x1c4 
 [<0000000000316cb2>] devinet_ioctl+0x5d2/0x724 
 [<000000000031753c>] inet_ioctl+0xf4/0x130 
 [<00000000002ac6fa>] sock_ioctl+0x86/0x300 
 [<00000000000c8124>] do_ioctl+0x50/0xe0 
 [<00000000000c8440>] vfs_ioctl+0x28c/0x3e4 
 [<00000000000c85e8>] sys_ioctl+0x50/0x8c 
 [<00000000000ff744>] dev_ifsioc+0xb8/0x4c8 
 [<00000000000fc15c>] compat_sys_ioctl+0x11c/0x444 
 [<00000000000229d0>] sysc_noemu+0x10/0x16 
 [<0000000077f3b9ca>] 0x77f3b9ca 
