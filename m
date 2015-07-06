From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 0/3] net: dsa: mv88e6xxx: add support for VLAN Table
 Unit
Date: Tue, 7 Jul 2015 01:38:04 +0200
Message-ID: <20150706233804.GE469@lunn.ch>
References: <1436148893-14379-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35026 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293AbbGFXoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2015 19:44:22 -0400
Content-Disposition: inline
In-Reply-To: <1436148893-14379-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 05, 2015 at 10:14:50PM -0400, Vivien Didelot wrote:
> Hi all,
> 
> This patchset brings full support for hardware VLANs in DSA, and the Marvell
> 88E6xxx compatible switch chips.

Hi Vivien

I just booted these patches on my board, and i'm getting WARNINGS:

[   61.111302] WARNING: CPU: 0 PID: 2751 at net/switchdev/switchdev.c:265 switchdev_port_obj_add+0xd4/0xdc()
[   61.119602] lan0: Commit of object (id=2) failed.
[   61.123007] Modules linked in:
[   61.124790] CPU: 0 PID: 2751 Comm: ip Tainted: G        W       4.2.0-rc1-00029-g5b5313438cfd #187
[   61.132484] Hardware name: Freescale Vybrid VF5xx/VF6xx (Device Tree)
[   61.137622] Backtrace: 
[   61.138817] [<80012ecc>] (dump_backtrace) from [<80013118>] (show_stack+0x20/0x24)
[   61.145123]  r6:804e3aa4 r5:00000009 r4:00000000 r3:00000000
[   61.149616] [<800130f8>] (show_stack) from [<804ea2e0>] (dump_stack+0x24/0x28)
[   61.155562] [<804ea2bc>] (dump_stack) from [<8001e4b0>] (warn_slowpath_common+0x98/0xc4)
[   61.162411] [<8001e418>] (warn_slowpath_common) from [<8001e51c>] (warn_slowpath_fmt+0x40/0x48)
[   61.169843]  r8:00000020 r7:00000000 r6:87b4d000 r5:ffffffa1 r4:80647708
[   61.175345] [<8001e4e0>] (warn_slowpath_fmt) from [<804e3aa4>] (switchdev_port_obj_add+0xd4/0xdc)
[   61.182950]  r3:87b4d000 r2:80647708
[   61.185255]  r4:870b3abc
[   61.186525] [<804e39d0>] (switchdev_port_obj_add) from [<804e3b9c>] (switchdev_fib_ipv4_add+0x90/0xbc)
[   61.194564]  r6:00000003 r5:00000c00 r4:87243d80
[   61.197949] [<804e3b0c>] (switchdev_fib_ipv4_add) from [<80491f8c>] (fib_table_insert+0x1cc/0x4cc)
[   61.205642]  r7:870b3b60 r6:c0a80d00 r5:87108794 r4:00000000
[   61.210125] [<80491dc0>] (fib_table_insert) from [<8048ce58>] (fib_magic.isra.18+0xdc/0xf0)
[   61.217169]  r10:8717c6c0 r9:871c9b00 r8:00000020 r7:000da8c0 r6:00000018 r5:040da8c0
[   61.223812]  r4:00000003
[   61.225089] [<8048cd7c>] (fib_magic.isra.18) from [<8048defc>] (fib_add_ifaddr+0x150/0x1a0)
[   61.232168]  r9:87243a00 r8:87a40000 r7:040da8c0 r6:00ffffff r5:000da8c0 r4:87243a00
[   61.238712] [<8048ddac>] (fib_add_ifaddr) from [<8048e500>] (fib_inetaddr_event+0x84/0xc4)
[   61.245707]  r9:00000000 r8:00000000 r7:ffffffff r6:87a40000 r5:00000001 r4:87243a00
[   61.252284] [<8048e47c>] (fib_inetaddr_event) from [<8003892c>] (notifier_call_chain+0x54/0x94)
[   61.259716]  r6:00000001 r5:87243a00 r4:ffffffff r3:8048e47c
[   61.264159] [<800388d8>] (notifier_call_chain) from [<80038cd8>] (__blocking_notifier_call_chain+0x58/0x70)
[   61.272633]  r9:871c9b00 r8:871c9b0c r7:00000001 r6:87243a00 r5:8071a720 r4:ffffffff
[   61.279176] [<80038c80>] (__blocking_notifier_call_chain) from [<80038d18>] (blocking_notifier_call_chain+0x28/0x30)
[   61.288428]  r7:000000c5 r6:87243a00 r5:871c9000 r4:00000abf
[   61.292901] [<80038cf0>] (blocking_notifier_call_chain) from [<80483674>] (__inet_insert_ifa+0x18c/0x238)
[   61.301219] [<804834e8>] (__inet_insert_ifa) from [<80484c24>] (inet_rtm_newaddr+0x188/0x3d0)
[   61.308439]  r9:00000000 r8:ffffffff r7:87243a00 r6:8717c6c0 r5:871c9000 r4:00000000
[   61.315022] [<80484a9c>] (inet_rtm_newaddr) from [<80438130>] (rtnetlink_rcv_msg+0x188/0x228)
[   61.322275]  r9:00000000 r8:00000000 r7:00000002 r6:8717c6c0 r5:871c9000 r4:00000030
[   61.328818] [<80437fa8>] (rtnetlink_rcv_msg) from [<8044a4b0>] (netlink_rcv_skb+0xb0/0xcc)
[   61.335815]  r8:00000000 r7:8717c6c0 r6:8717c6c0 r5:80437fa8 r4:871c9000
[   61.341353] [<8044a400>] (netlink_rcv_skb) from [<80437fa0>] (rtnetlink_rcv+0x34/0x3c)
[   61.347968]  r6:8709c400 r5:00000038 r4:8717c6c0 r3:80437f6c
[   61.352446] [<80437f6c>] (rtnetlink_rcv) from [<80449e74>] (netlink_unicast+0x174/0x1f4)
[   61.359235]  r4:878d3c00 r3:80437f6c
[   61.361596] [<80449d00>] (netlink_unicast) from [<8044a2f0>] (netlink_sendmsg+0x334/0x348)
[   61.368560]  r8:00000000 r7:00000038 r6:00000000 r5:8709c400 r4:870b3f4c
[   61.374100] [<80449fbc>] (netlink_sendmsg) from [<8040e928>] (sock_sendmsg+0x24/0x34)
[   61.380662]  r10:00000000 r9:870b3e30 r8:00000000 r7:8773e3c0 r6:00000000 r5:00000000
[   61.387269]  r4:870b3f4c
[   61.388545] [<8040e904>] (sock_sendmsg) from [<8040f294>] (___sys_sendmsg+0x1dc/0x1e4)
[   61.395218] [<8040f0b8>] (___sys_sendmsg) from [<8040ffe8>] (__sys_sendmsg+0x4c/0x7c)
[   61.401782]  r9:870b2000 r8:8000fa44 r7:00000128 r6:7e9169b4 r5:00000000 r4:8773e3c0
[   61.408331] [<8040ff9c>] (__sys_sendmsg) from [<80410030>] (SyS_sendmsg+0x18/0x1c)
[   61.414630]  r6:7e9169a0 r5:00000010 r4:0000000c
[   61.418019] [<80410018>] (SyS_sendmsg) from [<8000f8a0>] (ret_fast_syscall+0x0/0x3c)
[   61.424494] ---[ end trace 6a5447143fac0dcb ]---

This is with -rc1.

     Andrew
