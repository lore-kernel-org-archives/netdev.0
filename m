From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: tun device, unregister_netdevice: waiting for tunx0 to become free. Usage count = 30
Date: Sun, 12 Apr 2009 19:58:22 +0300
Message-ID: <200904121958.22606.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, maxk@qualcomm.com, vtun@office.satix.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:58470 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbZDLQ5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2009 12:57:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel 2.6.29 
I have program, that creates tunnel interfaces over /dev/net/tun tunx0, tunx1, 
tunx2

After some event i killed program over SIGKILL, and tunnels remain alive, and 
program become unkillable.

dmesg flooded slowly by:
[598567.076211] unregister_netdevice: waiting for tunx0 to become free. Usage 
count = 30
[598577.118112] unregister_netdevice: waiting for tunx0 to become free. Usage 
count = 30
[598587.384016] unregister_netdevice: waiting for tunx0 to become free. Usage 
count = 30
[598597.398905] unregister_netdevice: waiting for tunx0 to become free. Usage 
count = 30
[598607.426808] unregister_netdevice: waiting for tunx0 to become free. Usage 
count = 30
[598617.470706] unregister_netdevice: waiting for tunx0 to become free. Usage 
count = 30
[598627.502599] unregister_netdevice: waiting for tunx0 to become free. Usage 
count = 30
[598637.522509] unregister_netdevice: waiting for tunx0 to become free. Usage 
count = 30
[598647.557402] unregister_netdevice: waiting for tunx0 to become free. Usage 
count = 30
[598657.605296] unregister_netdevice: waiting for tunx0 to become free. Usage 
count = 30


Here it more info
egaRouterXeon-KARAM /proc/2863 # cat status
Name:   globax
State:  D (disk sleep)
Tgid:   2863
Pid:    2863
PPid:   1

MegaRouterXeon-KARAM /proc/2863 # cat stack
[<c012daca>] msleep+0x10/0x16
[<c02660fa>] netdev_run_todo+0xfe/0x1c7
[<c026dcd6>] rtnl_unlock+0x8/0xa
[<f858121d>] tun_chr_close+0x53/0x59 [tun]
[<c0171b37>] __fput+0xaf/0x150
[<c0171bf1>] fput+0x19/0x1b
[<c016f6f7>] filp_close+0x48/0x52
[<c012724e>] put_files_struct+0x68/0xaa
[<c01272c6>] exit_files+0x36/0x3b
[<c0128595>] do_exit+0x167/0x65d
[<c0128ae7>] do_group_exit+0x5c/0x83
[<c01307c8>] get_signal_to_deliver+0x2e8/0x304
[<c010217a>] do_notify_resume+0x69/0x759
[<c0102ebe>] work_notifysig+0x13/0x19
[<ffffffff>] 0xffffffff


