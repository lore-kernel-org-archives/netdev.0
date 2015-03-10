From: Fabio Estevam <festevam@gmail.com>
Subject: net/ipv4/fib_trie.c:1550 suspicious rcu_dereference_check() usage
Date: Tue, 10 Mar 2015 01:19:04 -0300
Message-ID: <CAOMZO5Aghpf7b-p0YWB_PdF-frN-rERmdjoUOk+PW_rzJY+eMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Olof Johansson <olof@lixom.net>
To: "David S. Miller" <davem@davemloft.net>,
	alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:38090 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbbCJETG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 00:19:06 -0400
Received: by labgf13 with SMTP id gf13so50932064lab.5
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 21:19:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On a imx6sl-warp board running linux-next 20150306:

root@imx6sl-warp:~# reboot

The system is going down for reboot NOW!(ttymxc0) (Wed Feb 25 18:41:59 2015):
INIT: Switching to runlevel: 6
INIT: Sending processes the TERM signal
INIT: Sending processe Stopping syslogd/klogd: stopped syslogd (pid 301)
stopped klogd (pid 304)
done
Deconfiguring network interfaces... [   36.083246]
[   36.084753] ===============================
[   36.089026] [ INFO: suspicious RCU usage. ]
[   36.093217] 4.0.0-rc2-next-20150306-00003-g62c7037-dirty #2699 Not tainted
[   36.100128] -------------------------------
[   36.104316] net/ipv4/fib_trie.c:1550 suspicious
rcu_dereference_check() usage!
[   36.111559]
[   36.111559] other info that might help us debug this:
[   36.111559]
[   36.119604]
[   36.119604] rcu_scheduler_active = 1, debug_locks = 0
[   36.126139] 1 lock held by ifconfig/324:
[   36.130083]  #0:  (rtnl_mutex){+.+.+.}, at: [<805a6914>] rtnl_lock+0x18/0x20
[   36.137222]
[   36.137222] stack backtrace:
[   36.141609] CPU: 0 PID: 324 Comm: ifconfig Not tainted
4.0.0-rc2-next-20150306-00003-g62c7037-dirty #2699
[   36.151196] Hardware name: Freescale i.MX6 SoloLite (Device Tree)
[   36.157293] Backtrace:
[   36.159793] [<80011f0c>] (dump_backtrace) from [<800120a8>]
(show_stack+0x18/0x1c)
[   36.167365]  r6:0000060e r5:00000000 r4:00000000 r3:00000000
[   36.173118] [<80012090>] (show_stack) from [<807651c8>]
(dump_stack+0x88/0xa4)
[   36.180374] [<80765140>] (dump_stack) from [<80064110>]
(lockdep_rcu_suspicious+0xbc/0x11c)
[   36.188729]  r5:80913288 r4:9dff0000
[   36.192367] [<80064054>] (lockdep_rcu_suspicious) from [<8060f740>]
(fib_table_flush+0x270/0x294)
[   36.201260]  r7:80aa3680 r6:00000000 r5:00000000 r4:80aad668
[   36.206985] [<8060f4d0>] (fib_table_flush) from [<80608cb0>]
(fib_flush.constprop.10+0x34/0x64)
[   36.215702]  r10:80aa8784 r9:9dfa3000 r8:00000002 r7:80aa3680
r6:00000000 r5:00000000
[   36.223623]  r4:00000000
[   36.226178] [<80608c7c>] (fib_flush.constprop.10) from [<80608d00>]
(fib_disable_ip+0x20/0x38)
[   36.234810]  r7:9dc7fe0c r6:80aad660 r5:9e4b6000 r4:9e4b6000
[   36.240551] [<80608ce0>] (fib_disable_ip) from [<8060a0e4>]
(fib_netdev_event+0x100/0x138)
[   36.248834]  r4:00000001 r3:9e58aa00
[   36.252451] [<80609fe4>] (fib_netdev_event) from [<80048170>]
(notifier_call_chain+0x54/0x94)
[   36.260997]  r6:00000000 r5:fffffffa r4:80aa735c r3:80609fe4
[   36.266722] [<8004811c>] (notifier_call_chain) from [<800481cc>]
(__raw_notifier_call_chain+0x1c/0x24)
[   36.276048]  r10:00000000 r8:00000000 r7:00000000 r6:9e4b6000
r5:00000002 r4:9dc7fe0c
[   36.283976] [<800481b0>] (__raw_notifier_call_chain) from
[<800481f4>] (raw_notifier_call_chain+0x20/0x28)
[   36.293661] [<800481d4>] (raw_notifier_call_chain) from
[<8058f440>] (call_netdevice_notifiers_info+0x38/0x64)
[   36.303691] [<8058f408>] (call_netdevice_notifiers_info) from
[<8058f4f0>] (call_netdevice_notifiers+0x18/0x20)
[   36.313798]  r6:00000009 r5:00000001 r4:9e4b6000 r3:00000008
[   36.319541] [<8058f4d8>] (call_netdevice_notifiers) from
[<8059632c>] (__dev_notify_flags+0x40/0x98)
[   36.328682] [<805962ec>] (__dev_notify_flags) from [<805969b4>]
(dev_change_flags+0x48/0x50)
[   36.337139]  r5:00000138 r4:9e4b6000
[   36.340777] [<8059696c>] (dev_change_flags) from [<8060129c>]
(devinet_ioctl+0x690/0x788)
[   36.348976]  r8:00008914 r7:00000000 r6:7e9b6c78 r5:9e58aa0c
r4:9dfa3000 r3:00000000
[   36.356801] [<80600c0c>] (devinet_ioctl) from [<80602ee8>]
(inet_ioctl+0x1b4/0x1c8)
[   36.364477]  r10:9e222fe0 r9:7e9b6c78 r8:00000003 r7:9e222fc0
r6:7e9b6c78 r5:8010c90c
[   36.372402]  r4:00008914
[   36.374958] [<80602d34>] (inet_ioctl) from [<80579dd0>]
(sock_ioctl+0x64/0x2a4)
[   36.382298] [<80579d6c>] (sock_ioctl) from [<8010c2dc>]
(do_vfs_ioctl+0x80/0x674)
[   36.389801]  r7:7e9b6c78 r6:00000003 r5:8010c90c r4:9dc6d640
[   36.395526] [<8010c25c>] (do_vfs_ioctl) from [<8010c90c>]
(SyS_ioctl+0x3c/0x60)
[   36.402854]  r10:00000000 r9:9dc7e000 r8:00000003 r7:7e9b6c78
r6:00008914 r5:9dc6d640
[   36.410776]  r4:9dc6d640
[   36.413335] [<8010c8d0>] (SyS_ioctl) from [<8000eca0>]
(ret_fast_syscall+0x0/0x4c)
[   36.420925]  r8:8000ee64 r7:00000036 r6:00000001 r5:7e9b6e60
r4:0007e93c r3:0007e93c
ifdown: interface eth0 not configured
done.
Sending all processes the TERM signal...
Sending all processes the KILL signal...
Unmounting remote filesystems...
Deactivating swap...
Unmounting local filesystems...
Rebooting... [   46.221628] imx2-wdt 20bc000.wdog: Device shutdown:
Expect reboot!
[   46.228119] reboot: Restarting system

Olof's boot farm also reported the same on a imx6q-wandboard after a
halt command:

http://arm-soc.lixom.net/bootlogs/next/next-20150306/wandboard-arm-imx_v6_v7_defconfig.html

linux-next 20150305 does not show this problem. Haven't bisected it yet.

Regards,

Fabio Estevam
