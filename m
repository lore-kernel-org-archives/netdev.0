From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: [BISECTED] v4.9: OCTEON ethernet crash
Date: Thu, 15 Dec 2016 02:32:53 +0200
Message-ID: <20161215003253.un6hk2ytl3auiztn@raspberrypi-2.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Daney <ddaney@caviumnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh03.mail.saunalahti.fi ([62.142.5.109]:36234 "EHLO
        emh03.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754818AbcLOAc5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 19:32:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm getting the following crash on every boot on OCTEON (EdgeRouter Lite)
with v4.9 (right after setting up ethernet bridging):

[   16.814902] CPU 0 Unable to handle kernel paging request at virtual address 0000000000000080, epc == ffffffff81458570, ra == ffffffff81458804
[   16.827805] Oops[#1]:
[   16.830100] CPU: 0 PID: 706 Comm: ifconfig Not tainted 4.9.0-octeon-los_be07e6-00002-g29a0b7e #1
[   16.838884] task: 800000041f9dec00 task.stack: 800000041f0d8000
[   16.844801] $ 0   : 0000000000000000 0000000010108ce1 0000000000000000 0000000000000001
[   16.852867] $ 4   : 800000041f98a000 800000041fb67800 0000000000000000 0000000000000002
[   16.860932] $ 8   : 800000041fb67810 800000041f0dbb40 10434794771be290 771bf16800000001
[   16.868997] $12   : 0000000000000000 ffffffff81383edc ffffffff81296950 0000000000000000
[   16.877060] $16   : 800000041fb67800 800000041f98a000 ffffffff81508c48 800000041f817800
[   16.885125] $20   : 0000000000000000 0000000000000002 0000000000000000 800000041f98a000
[   16.893190] $24   : 0000000000000000 0000000000000000                                  
[   16.901256] $28   : 800000041f0d8000 800000041f0dbb10 800000041e109410 ffffffff81458804
[   16.909321] Hi    : 00000000000002c9
[   16.912896] Lo    : 0000000000001c1d
[   16.916484] epc   : ffffffff81458570 phy_attach_direct+0x38/0x1b0
[   16.922580] ra    : ffffffff81458804 phy_connect_direct+0x24/0x88
[   16.928671] Status: 10108ce3	KX SX UX KERNEL EXL IE 
[   16.933723] Cause : 00800008 (ExcCode 02)
[   16.937730] BadVA : 0000000000000080
[   16.941306] PrId  : 000d0601 (Cavium Octeon+)
[   16.945660] Modules linked in: at803x
[   16.949353] Process ifconfig (pid: 706, threadinfo=800000041f0d8000, task=800000041f9dec00, tls=00000000771c3490)
[   16.959605] Stack : 800000041fb67800 800000041f98a000 ffffffff81508c48 0000000000000002
[   16.967671]         0000000000000000 0000000000000000 800000041e109400 ffffffff81458804
[   16.975734]         800000041fb67800 800000041f98a000 ffffffff81508c48 ffffffff81504cd4
[   16.983799]         800000041f98a000 800000041f98a000 ffffffff81509830 0000000000000000
[   16.991864]         0000000000000000 ffffffff81508f58 0000000000000000 ffffffff815087e0
[   16.999928]         800000041f98a000 800000041f98a048 ffffffff816fcc88 0000000000001302
[   17.007993]         0000000000008914 ffffffff8150993c ffffffff816fcc88 0000000000001302
[   17.016057]         800000041f98a000 ffffffff8153bc6c 800000041f98a000 0000000000000008
[   17.024122]         8000000003c500d8 0000000000000000 800000041f98a000 0000000000000341
[   17.032187]         0000000000001043 ffffffff8153bf94 00000000000000fe 800000041f98a000
[   17.040251]         ...
[   17.042722] Call Trace:
[   17.045175] [<ffffffff81458570>] phy_attach_direct+0x38/0x1b0
[   17.050927] [<ffffffff81458804>] phy_connect_direct+0x24/0x88
[   17.056682] [<ffffffff81504cd4>] of_phy_connect+0x54/0xb0
[   17.062089] [<ffffffff81508f58>] cvm_oct_phy_setup_device+0x48/0xc0
[   17.068361] [<ffffffff815087e0>] cvm_oct_common_open+0x58/0x2a8
[   17.074285] [<ffffffff8150993c>] cvm_oct_rgmii_open+0x1c/0x90
[   17.080040] [<ffffffff8153bc6c>] __dev_open+0x104/0x198
[   17.085270] [<ffffffff8153bf94>] __dev_change_flags+0x94/0x180
[   17.091107] [<ffffffff8153c0a4>] dev_change_flags+0x24/0x68
[   17.096687] [<ffffffff815c6e30>] devinet_ioctl+0x6a8/0x8b0
[   17.102181] [<ffffffff81516e0c>] sock_do_ioctl.constprop.14+0x24/0x68
[   17.108626] [<ffffffff81518338>] compat_sock_ioctl+0xd18/0xfc8
[   17.114471] [<ffffffff81296a10>] compat_SyS_ioctl+0xc0/0x1980
[   17.120222] [<ffffffff8113109c>] syscall_common+0x18/0x3c
[   17.125621] Code: ffb20010  dc8204b8  dcb30298 <dc420080> de640000  dc520010  12440005  00a08025  0c46e4a6 
[   17.135490] 
[   17.137147] ---[ end trace f1d7b064cedee4e4 ]---
[   17.141882] Kernel panic - not syncing: Fatal exception
[   17.147140] ---[ end Kernel panic - not syncing: Fatal exception

Git bisect points to:

commit ec988ad78ed6d184a7f4ca6b8e962b0e8f1de461
Author: Florian Fainelli <f.fainelli@gmail.com>
Date:   Tue Dec 6 20:54:43 2016 -0800

    phy: Don't increment MDIO bus refcount unless it's a different owner

Reverting this patch from v4.9 fixes the issue...

A.
