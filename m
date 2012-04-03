From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [3.4-rc1][Regression][network wireless] 'task xxxx blocked for
 more than 120 seconds' after resume
Date: Tue, 03 Apr 2012 10:07:49 +0200
Message-ID: <1333440469.3574.0.camel@jlt3.sipsolutions.net>
References: <201204022157.05598.maciej.rutecki@gmail.com>
	 (sfid-20120402_215800_170335_CC49F369)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: maciej.rutecki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:42577 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324Ab2DCIHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 04:07:55 -0400
In-Reply-To: <201204022157.05598.maciej.rutecki@gmail.com> (sfid-20120402_215800_170335_CC49F369)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-ilw
+netdev

I have no idea what this could be, but I'm almost certain it's not
caused by our wireless driver. Looks more like rtl8169 is to blame.

johannes


On Mon, 2012-04-02 at 21:57 +0200, Maciej Rutecki wrote:
> Last known good kernel: 3.3
> 
> Bad kernel: 3.4-rc1 + patch: http://cgit.freedesktop.org/~danvet/drm-
> intel/commit/?h=drm-intel-fixes&id=55a254ac63a3ac1867d1501030e7fba69c7d4aeb
> 
> Subsystem: network (wireless)
> 
> After resume from suspend to disk I do not have network connection (wireless) 
> and I got it in dmesg:
> 
> [ 2398.278375] INFO: task nmbd:2442 blocked for more than 120 seconds.
> [ 2398.278384] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables 
> this message.
> [ 2398.278390] nmbd            D ffff88023fb933c0     0  2442      1 0x00000000
> [ 2398.278401]  ffff880232d6f5d0 0000000000000082 0000000000000206 
> ffff880235186ee0
> [ 2398.278413]  00000000000133c0 ffff8802320fdfd8 ffff8802320fdfd8 ffff880232d6f5d0
> [ 2398.278423]  ffff8802320fde5c ffffffff81868020 ffff880232d6f5d0 0000000000000002
> [ 2398.278433] Call Trace:
> [ 2398.278451]  [<ffffffff813fba8c>] ? __mutex_lock_common.isra.5+0xff/0x164
> [ 2398.278462]  [<ffffffff813fb97a>] ? mutex_lock+0x1a/0x2d
> [ 2398.278471]  [<ffffffff8135bb44>] ? netlink_trim+0x13/0x79
> [ 2398.278480]  [<ffffffff81349f0c>] ? rtnetlink_rcv+0xe/0x28
> [ 2398.278488]  [<ffffffff8135cffc>] ? netlink_unicast+0xe6/0x14e
> [ 2398.278497]  [<ffffffff8135d265>] ? netlink_sendmsg+0x201/0x23c
> [ 2398.278505]  [<ffffffff811091b1>] ? __pollwait+0xce/0xce
> [ 2398.278515]  [<ffffffff8132e2a2>] ? sock_sendmsg+0xca/0xe7
> [ 2398.278521]  [<ffffffff811091b1>] ? __pollwait+0xce/0xce
> [ 2398.278530]  [<ffffffff8103d1da>] ? sys_time+0xc/0x39
> [ 2398.278539]  [<ffffffff81011e5d>] ? emulate_vsyscall+0x191/0x270
> [ 2398.278548]  [<ffffffff81056a33>] ? should_resched+0x5/0x23
> [ 2398.278554]  [<ffffffff813fc545>] ? _cond_resched+0x6/0x1b
> [ 2398.278562]  [<ffffffff8132cd08>] ? copy_from_user+0x18/0x30
> [ 2398.278571]  [<ffffffff8132fb20>] ? sys_sendto+0xf7/0x137
> [ 2398.278581]  [<ffffffff810fa2a0>] ? fd_install+0x25/0x4a
> [ 2398.278591]  [<ffffffff81401ff9>] ? system_call_fastpath+0x16/0x1b
> [ 2398.278659] INFO: task ifconfig:6734 blocked for more than 120 seconds.
> [ 2398.278664] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables 
> this message.
> [ 2398.278669] ifconfig        D ffff88023fb933c0     0  6734   2598 0x00000000
> [ 2398.278678]  ffff8801faae30a0 0000000000000086 0000000000000001 
> ffff880235186ee0
> [ 2398.278688]  00000000000133c0 ffff880232163fd8 ffff880232163fd8 ffff8801faae30a0
> [ 2398.278697]  0000000000000001 ffff880230f2b4d8 ffff8801faae30a0 
> 0000000000000002
> [ 2398.278707] Call Trace:
> [ 2398.278716]  [<ffffffff813fba8c>] ? __mutex_lock_common.isra.5+0xff/0x164
> [ 2398.278723]  [<ffffffff81056a33>] ? should_resched+0x5/0x23
> [ 2398.278732]  [<ffffffff813fb97a>] ? mutex_lock+0x1a/0x2d
> [ 2398.278759]  [<ffffffffa0116d33>] ? rtl8169_close+0x49/0x14f [r8169]
> [ 2398.278768]  [<ffffffff8133cb37>] ? __dev_close_many+0x85/0xb2
> [ 2398.278775]  [<ffffffff8133cb94>] ? __dev_close+0x30/0x47
> [ 2398.278783]  [<ffffffff813405c0>] ? dev_set_rx_mode+0x1d/0x29
> [ 2398.278792]  [<ffffffff81340844>] ? __dev_change_flags+0x9d/0x118
> [ 2398.278799]  [<ffffffff81340922>] ? dev_change_flags+0x12/0x42
> [ 2398.278810]  [<ffffffff8138a769>] ? devinet_ioctl+0x285/0x554
> [ 2398.278818]  [<ffffffff8132cdb3>] ? sock_do_ioctl+0x1b/0x36
> [ 2398.278826]  [<ffffffff8132d1be>] ? sock_ioctl+0x205/0x212
> [ 2398.278836]  [<ffffffff8110887d>] ? do_vfs_ioctl+0x459/0x49a
> [ 2398.278844]  [<ffffffff810ee42b>] ? kmem_cache_alloc+0x86/0xea
> [ 2398.278853]  [<ffffffff81108909>] ? sys_ioctl+0x4b/0x72
> [ 2398.278862]  [<ffffffff81401ff9>] ? system_call_fastpath+0x16/0x1b
> [ 2518.146666] INFO: task nmbd:2442 blocked for more than 120 seconds.
> [ 2518.146675] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables 
> this message.
> [ 2518.146682] nmbd            D ffff88023fb933c0     0  2442      1 0x00000000
> [ 2518.146693]  ffff880232d6f5d0 0000000000000082 0000000000000206 
> ffff880235186ee0
> [ 2518.146704]  00000000000133c0 ffff8802320fdfd8 ffff8802320fdfd8 ffff880232d6f5d0
> [ 2518.146714]  ffff8802320fde5c ffffffff81868020 ffff880232d6f5d0 0000000000000002
> [ 2518.146725] Call Trace:
> [ 2518.146743]  [<ffffffff813fba8c>] ? __mutex_lock_common.isra.5+0xff/0x164
> [ 2518.146753]  [<ffffffff813fb97a>] ? mutex_lock+0x1a/0x2d
> [ 2518.146763]  [<ffffffff8135bb44>] ? netlink_trim+0x13/0x79
> [ 2518.146772]  [<ffffffff81349f0c>] ? rtnetlink_rcv+0xe/0x28
> [ 2518.146780]  [<ffffffff8135cffc>] ? netlink_unicast+0xe6/0x14e
> [ 2518.146788]  [<ffffffff8135d265>] ? netlink_sendmsg+0x201/0x23c
> [ 2518.146796]  [<ffffffff811091b1>] ? __pollwait+0xce/0xce
> [ 2518.146807]  [<ffffffff8132e2a2>] ? sock_sendmsg+0xca/0xe7
> [ 2518.146813]  [<ffffffff811091b1>] ? __pollwait+0xce/0xce
> [ 2518.146822]  [<ffffffff8103d1da>] ? sys_time+0xc/0x39
> [ 2518.146831]  [<ffffffff81011e5d>] ? emulate_vsyscall+0x191/0x270
> [ 2518.146839]  [<ffffffff81056a33>] ? should_resched+0x5/0x23
> [ 2518.146846]  [<ffffffff813fc545>] ? _cond_resched+0x6/0x1b
> [ 2518.146854]  [<ffffffff8132cd08>] ? copy_from_user+0x18/0x30
> [ 2518.146862]  [<ffffffff8132fb20>] ? sys_sendto+0xf7/0x137
> [ 2518.146872]  [<ffffffff810fa2a0>] ? fd_install+0x25/0x4a
> [ 2518.146883]  [<ffffffff81401ff9>] ? system_call_fastpath+0x16/0x1b
> [ 2518.146915] INFO: task ksysguardd:3501 blocked for more than 120 seconds.
> [ 2518.146919] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables 
> this message.
> [ 2518.146924] ksysguardd      D ffff88023fa133c0     0  3501   3436 0x00000000
> [ 2518.146934]  ffff8802322ed8d0 0000000000000082 ffff880228522980 ffffffff81813020
> [ 2518.146943]  00000000000133c0 ffff880225c7bfd8 ffff880225c7bfd8 ffff8802322ed8d0
> [ 2518.146953]  00000008a01445fe ffffffff81868020 ffff8802322ed8d0 0000000000000002
> [ 2518.146962] Call Trace:
> [ 2518.146972]  [<ffffffff813fba8c>] ? __mutex_lock_common.isra.5+0xff/0x164
> [ 2518.146981]  [<ffffffff813fb97a>] ? mutex_lock+0x1a/0x2d
> [ 2518.146993]  [<ffffffff813daa7b>] ? wireless_dev_seq_start+0x12/0x5e
> [ 2518.147002]  [<ffffffff811136bd>] ? seq_read+0x148/0x354
> [ 2518.147012]  [<ffffffff81141a3e>] ? proc_reg_read+0x78/0x91
> [ 2518.147021]  [<ffffffff810fb7e5>] ? vfs_read+0x9f/0xe6
> [ 2518.147028]  [<ffffffff810fb871>] ? sys_read+0x45/0x6b
> [ 2518.147037]  [<ffffffff81401ff9>] ? system_call_fastpath+0x16/0x1b
> [ 2518.147063] INFO: task ifconfig:6734 blocked for more than 120 seconds.
> [ 2518.147068] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables 
> this message.
> [ 2518.147072] ifconfig        D ffff88023fb933c0     0  6734   2598 0x00000000
> [ 2518.147081]  ffff8801faae30a0 0000000000000086 0000000000000001 
> ffff880235186ee0
> [ 2518.147090]  00000000000133c0 ffff880232163fd8 ffff880232163fd8 ffff8801faae30a0
> [ 2518.147099]  0000000000000001 ffff880230f2b4d8 ffff8801faae30a0 
> 0000000000000002
> [ 2518.147109] Call Trace:
> [ 2518.147118]  [<ffffffff813fba8c>] ? __mutex_lock_common.isra.5+0xff/0x164
> [ 2518.147125]  [<ffffffff81056a33>] ? should_resched+0x5/0x23
> [ 2518.147133]  [<ffffffff813fb97a>] ? mutex_lock+0x1a/0x2d
> [ 2518.147160]  [<ffffffffa0116d33>] ? rtl8169_close+0x49/0x14f [r8169]
> [ 2518.147169]  [<ffffffff8133cb37>] ? __dev_close_many+0x85/0xb2
> [ 2518.147176]  [<ffffffff8133cb94>] ? __dev_close+0x30/0x47
> [ 2518.147184]  [<ffffffff813405c0>] ? dev_set_rx_mode+0x1d/0x29
> [ 2518.147192]  [<ffffffff81340844>] ? __dev_change_flags+0x9d/0x118
> [ 2518.147200]  [<ffffffff81340922>] ? dev_change_flags+0x12/0x42
> [ 2518.147210]  [<ffffffff8138a769>] ? devinet_ioctl+0x285/0x554
> [ 2518.147219]  [<ffffffff8132cdb3>] ? sock_do_ioctl+0x1b/0x36
> [ 2518.147227]  [<ffffffff8132d1be>] ? sock_ioctl+0x205/0x212
> [ 2518.147237]  [<ffffffff8110887d>] ? do_vfs_ioctl+0x459/0x49a
> [ 2518.147245]  [<ffffffff810ee42b>] ? kmem_cache_alloc+0x86/0xea
> [ 2518.147254]  [<ffffffff81108909>] ? sys_ioctl+0x4b/0x72
> [ 2518.147263]  [<ffffffff81401ff9>] ? system_call_fastpath+0x16/0x1b
> [ 2638.014954] INFO: task nmbd:2442 blocked for more than 120 seconds.
> [ 2638.014963] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables 
> this message.
> [ 2638.014969] nmbd            D ffff88023fb933c0     0  2442      1 0x00000000
> [ 2638.014980]  ffff880232d6f5d0 0000000000000082 0000000000000206 
> ffff880235186ee0
> [ 2638.014992]  00000000000133c0 ffff8802320fdfd8 ffff8802320fdfd8 ffff880232d6f5d0
> [ 2638.015002]  ffff8802320fde5c ffffffff81868020 ffff880232d6f5d0 0000000000000002
> [ 2638.015012] Call Trace:
> [ 2638.015030]  [<ffffffff813fba8c>] ? __mutex_lock_common.isra.5+0xff/0x164
> [ 2638.015041]  [<ffffffff813fb97a>] ? mutex_lock+0x1a/0x2d
> [ 2638.015050]  [<ffffffff8135bb44>] ? netlink_trim+0x13/0x79
> [ 2638.015059]  [<ffffffff81349f0c>] ? rtnetlink_rcv+0xe/0x28
> [ 2638.015067]  [<ffffffff8135cffc>] ? netlink_unicast+0xe6/0x14e
> [ 2638.015075]  [<ffffffff8135d265>] ? netlink_sendmsg+0x201/0x23c
> [ 2638.015083]  [<ffffffff811091b1>] ? __pollwait+0xce/0xce
> [ 2638.015093]  [<ffffffff8132e2a2>] ? sock_sendmsg+0xca/0xe7
> [ 2638.015099]  [<ffffffff811091b1>] ? __pollwait+0xce/0xce
> [ 2638.015108]  [<ffffffff8103d1da>] ? sys_time+0xc/0x39
> [ 2638.015116]  [<ffffffff81011e5d>] ? emulate_vsyscall+0x191/0x270
> [ 2638.015124]  [<ffffffff81056a33>] ? should_resched+0x5/0x23
> [ 2638.015131]  [<ffffffff813fc545>] ? _cond_resched+0x6/0x1b
> [ 2638.015138]  [<ffffffff8132cd08>] ? copy_from_user+0x18/0x30
> [ 2638.015147]  [<ffffffff8132fb20>] ? sys_sendto+0xf7/0x137
> [ 2638.015156]  [<ffffffff810fa2a0>] ? fd_install+0x25/0x4a
> [ 2638.015166]  [<ffffffff81401ff9>] ? system_call_fastpath+0x16/0x1b
> [ 2638.015196] INFO: task ksysguardd:3501 blocked for more than 120 seconds.
> [ 2638.015201] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables 
> this message.
> [ 2638.015205] ksysguardd      D ffff88023fa133c0     0  3501   3436 0x00000000
> [ 2638.015214]  ffff8802322ed8d0 0000000000000082 ffff880228522980 ffffffff81813020
> [ 2638.015224]  00000000000133c0 ffff880225c7bfd8 ffff880225c7bfd8 ffff8802322ed8d0
> [ 2638.015233]  00000008a01445fe ffffffff81868020 ffff8802322ed8d0 0000000000000002
> [ 2638.015243] Call Trace:
> [ 2638.015252]  [<ffffffff813fba8c>] ? __mutex_lock_common.isra.5+0xff/0x164
> [ 2638.015262]  [<ffffffff813fb97a>] ? mutex_lock+0x1a/0x2d
> [ 2638.015273]  [<ffffffff813daa7b>] ? wireless_dev_seq_start+0x12/0x5e
> [ 2638.015282]  [<ffffffff811136bd>] ? seq_read+0x148/0x354
> [ 2638.015291]  [<ffffffff81141a3e>] ? proc_reg_read+0x78/0x91
> [ 2638.015299]  [<ffffffff810fb7e5>] ? vfs_read+0x9f/0xe6
> [ 2638.015307]  [<ffffffff810fb871>] ? sys_read+0x45/0x6b
> [ 2638.015315]  [<ffffffff81401ff9>] ? system_call_fastpath+0x16/0x1b
> [ 2638.015339] INFO: task ifconfig:6734 blocked for more than 120 seconds.
> [ 2638.015344] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables 
> this message.
> [ 2638.015348] ifconfig        D ffff88023fb933c0     0  6734   2598 0x00000000
> [ 2638.015357]  ffff8801faae30a0 0000000000000086 0000000000000001 
> ffff880235186ee0
> [ 2638.015366]  00000000000133c0 ffff880232163fd8 ffff880232163fd8 ffff8801faae30a0
> [ 2638.015375]  0000000000000001 ffff880230f2b4d8 ffff8801faae30a0 
> 0000000000000002
> [ 2638.015384] Call Trace:
> [ 2638.015393]  [<ffffffff813fba8c>] ? __mutex_lock_common.isra.5+0xff/0x164
> [ 2638.015400]  [<ffffffff81056a33>] ? should_resched+0x5/0x23
> [ 2638.015409]  [<ffffffff813fb97a>] ? mutex_lock+0x1a/0x2d
> [ 2638.015434]  [<ffffffffa0116d33>] ? rtl8169_close+0x49/0x14f [r8169]
> [ 2638.015443]  [<ffffffff8133cb37>] ? __dev_close_many+0x85/0xb2
> [ 2638.015450]  [<ffffffff8133cb94>] ? __dev_close+0x30/0x47
> [ 2638.015458]  [<ffffffff813405c0>] ? dev_set_rx_mode+0x1d/0x29
> [ 2638.015466]  [<ffffffff81340844>] ? __dev_change_flags+0x9d/0x118
> [ 2638.015474]  [<ffffffff81340922>] ? dev_change_flags+0x12/0x42
> [ 2638.015484]  [<ffffffff8138a769>] ? devinet_ioctl+0x285/0x554
> [ 2638.015492]  [<ffffffff8132cdb3>] ? sock_do_ioctl+0x1b/0x36
> [ 2638.015500]  [<ffffffff8132d1be>] ? sock_ioctl+0x205/0x212
> [ 2638.015510]  [<ffffffff8110887d>] ? do_vfs_ioctl+0x459/0x49a
> [ 2638.015518]  [<ffffffff810ee42b>] ? kmem_cache_alloc+0x86/0xea
> [ 2638.015527]  [<ffffffff81108909>] ? sys_ioctl+0x4b/0x72
> [ 2638.015535]  [<ffffffff81401ff9>] ? system_call_fastpath+0x16/0x1b
> 
> 
> Config:
> http://mrutecki.pl/download/kernel/3.4-rc1/netdev_resume/config-3.4.0-rc1
> 
> full dmesg:
> http://mrutecki.pl/download/kernel/3.4-rc1/netdev_resume/dmesg_netdev-3.4-
> rc1.txt
> 
> lspci:
> 00:00.0 Host bridge: Intel Corporation 2nd Generation Core Processor Family 
> DRAM Controller (rev 09)
> 00:02.0 VGA compatible controller: Intel Corporation 2nd Generation Core 
> Processor Family Integrated Graphics Controller (rev 09)
> 00:16.0 Communication controller: Intel Corporation 6 Series/C200 Series 
> Chipset Family MEI Controller #1 (rev 04)
> 00:1a.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family 
> USB Enhanced Host Controller #2 (rev 04)
> 00:1b.0 Audio device: Intel Corporation 6 Series/C200 Series Chipset Family 
> High Definition Audio Controller (rev 04)
> 00:1c.0 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI 
> Express Root Port 1 (rev b4)
> 00:1c.1 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI 
> Express Root Port 2 (rev b4)
> 00:1c.2 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI 
> Express Root Port 3 (rev b4)
> 00:1c.3 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI 
> Express Root Port 4 (rev b4)
> 00:1c.7 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI 
> Express Root Port 8 (rev b4)
> 00:1d.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family 
> USB Enhanced Host Controller #1 (rev 04)
> 00:1f.0 ISA bridge: Intel Corporation HM65 Express Chipset Family LPC 
> Controller (rev 04)
> 00:1f.2 SATA controller: Intel Corporation 6 Series/C200 Series Chipset Family 
> 6 port SATA AHCI Controller (rev 04)
> 00:1f.3 SMBus: Intel Corporation 6 Series/C200 Series Chipset Family SMBus 
> Controller (rev 04)
> 02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI 
> Express Gigabit Ethernet controller (rev 06)
> 03:00.0 System peripheral: Ricoh Co Ltd MMC/SD Host Controller (rev 07)
> 08:00.0 Network controller: Intel Corporation Centrino Wireless-N 1000
> 
> Regards
