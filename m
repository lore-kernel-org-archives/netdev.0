From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] bnx2x : lockdep assertion
Date: Mon, 06 Jan 2014 08:28:00 -0800
Message-ID: <1389025680.12212.178.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
	 <1388939634-19948-3-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ariele@broadcom.com,
	Michal Kalderon <michals@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:33120 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574AbaAFQ2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 11:28:04 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so18678129pbb.31
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 08:28:04 -0800 (PST)
In-Reply-To: <1388939634-19948-3-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Caught this with latest net-next tree :

Does this ring a bell to you guys ?


[   27.339221] BUG: sleeping function called from invalid context at include/linux/netdevice.h:486
[   27.347927] in_atomic(): 1, irqs_disabled(): 0, pid: 5672, name: ethtool
[   27.354628] 1 lock held by ethtool/5672:
[   27.354629]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814f3b97>] rtnl_lock+0x17/0x20
[   27.354641] CPU: 6 PID: 5672 Comm: ethtool Not tainted 3.13.0-dbg-DEV #430
[   27.354644]  0000000000000000 ffff880656881aa8 ffffffff81594454 0000000000000002
[   27.354648]  ffff88065d7f4ad0 ffff880656881ac8 ffffffff810c37af ffff880656881ac8
[   27.354651]  ffff880c50df8000 ffff880656881b18 ffffffffa00b8c18 ffff880c50df0940
[   27.354655] Call Trace:
[   27.354661]  [<ffffffff81594454>] dump_stack+0x4e/0x68
[   27.354666]  [<ffffffff810c37af>] __might_sleep+0xdf/0x110
[   27.354680]  [<ffffffffa00b8c18>] bnx2x_napi_disable.isra.84+0x58/0x130 [bnx2x]
[   27.354689]  [<ffffffffa00bdf65>] bnx2x_netif_stop+0x25/0x40 [bnx2x]
[   27.354696]  [<ffffffffa009123d>] bnx2x_chip_cleanup+0x24d/0x630 [bnx2x]
[   27.354700]  [<ffffffff810a2c55>] ? del_timer_sync+0x5/0xd0
[   27.354708]  [<ffffffffa00c0b40>] bnx2x_nic_unload+0x1f0/0x7f0 [bnx2x]
[   27.354714]  [<ffffffff8118e1af>] ? might_fault+0x5f/0xb0
[   27.354722]  [<ffffffffa00c3a0c>] bnx2x_reload_if_running+0x2c/0x50 [bnx2x]
[   27.354730]  [<ffffffffa00c57e4>] bnx2x_set_ringparam+0x2a4/0x400 [bnx2x]
[   27.354735]  [<ffffffff814ea242>] dev_ethtool+0x752/0x1b30
[   27.354741]  [<ffffffff810e3e1d>] ? trace_hardirqs_on+0xd/0x10
[   27.354743]  [<ffffffff814f3b97>] ? rtnl_lock+0x17/0x20
[   27.354747]  [<ffffffff814fa31d>] dev_ioctl+0x25d/0x5a0
[   27.354752]  [<ffffffff814c9746>] compat_sock_ioctl+0x4e6/0xa50
[   27.354757]  [<ffffffff815a0334>] ? __do_page_fault+0x2c4/0x560
[   27.354763]  [<ffffffff81224c08>] compat_sys_ioctl+0xc8/0x1500
[   27.354765]  [<ffffffff814c832b>] ? sock_map_fd+0x4b/0x70
[   27.354768]  [<ffffffff8159c989>] ? retint_swapgs+0xe/0x13
[   27.354771]  [<ffffffff810e3d45>] ? trace_hardirqs_on_caller+0x105/0x1d0
[   27.354774]  [<ffffffff813207ad>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[   27.354779]  [<ffffffff815a65e5>] sysenter_dispatch+0x7/0x1f
[   27.354781]  [<ffffffff8132076e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   28.096865] bnx2x 0000:03:00.0 eth0: using MSI-X  IRQs: sp 41  fp[0] 43 ... fp[3] 46
[   28.211869] bnx2x 0000:03:00.0 eth0: NIC Link is Up, 10000 Mbps full duplex, Flow control: ON - receive
