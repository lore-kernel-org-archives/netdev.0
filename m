From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too long
Date: Wed, 20 Mar 2013 14:06:06 -0700
Message-ID: <CAE9FiQXgv8EZGQ142NyV5D1M2+HKSaSoafNzdXY2SBO+iQjdGw@mail.gmail.com>
References: <1363693648-10015-2-git-send-email-yamato@redhat.com>
	<20130320.120705.58997943737455552.davem@davemloft.net>
	<CAE9FiQURBR=iTbksUzb_i23g6N56Acg2J8bab9zr1UcwT5tWzA@mail.gmail.com>
	<20130320.170511.343122156621608721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rui.zhang@intel.com, yamato@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:52708 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149Ab3CTVGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 17:06:07 -0400
Received: by mail-ie0-f174.google.com with SMTP id k10so2698894iea.33
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 14:06:06 -0700 (PDT)
In-Reply-To: <20130320.170511.343122156621608721.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 2:05 PM, David Miller <davem@davemloft.net> wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> Date: Wed, 20 Mar 2013 14:01:09 -0700
>
>> On Wed, Mar 20, 2013 at 9:07 AM, David Miller <davem@davemloft.net> wrote:
>>> From: Masatake YAMATO <yamato@redhat.com>
>>> Date: Tue, 19 Mar 2013 20:47:27 +0900
>>>
>>>> Trigger BUG_ON if a group name is longer than GENL_NAMSIZ.
>>>>
>>>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
>>>
>>> Applied, thanks.
>>
>> catch one in
>
> Seriously?
>
> That's what his second patch in this series fixes, we know about it
> already.

[    6.047966] ------------[ cut here ]------------
[    6.048944] kernel BUG at net/netlink/genetlink.c:145!
[    6.049204] invalid opcode: 0000 [#1] SMP
[    6.049501] Modules linked in:
[    6.049728] CPU 2
[    6.050003] Pid: 1, comm: swapper/0 Not tainted
3.9.0-rc3-yh-00486-gb6d1e23-dirty #1371 Bochs Bochs
[    6.050299] RIP: 0010:[<ffffffff81f0f968>]  [<ffffffff81f0f968>]
genl_register_mc_group+0x38/0x270
[    6.050593] RSP: 0000:ffff880119e63dd8  EFLAGS: 00000246
[    6.050804] RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffffffff82b667c8
[    6.050931] RDX: ffffffff82b667c8 RSI: 0000000000000000 RDI: ffffffff82b667b8
[    6.050931] RBP: ffff880119e63e28 R08: 0000000000000000 R09: 0000000000000000
[    6.050931] R10: 0000000000000000 R11: 0000000000000001 R12: ffffffff82b667a0
[    6.050931] R13: ffffffff82b66720 R14: 00000001683fe47c R15: 0000000000000000
[    6.050931] FS:  0000000000000000(0000) GS:ffff88019f600000(0000)
knlGS:0000000000000000
[    6.050931] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    6.050931] CR2: 0000000000000000 CR3: 0000000002a14000 CR4: 00000000000006e0
[    6.050931] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    6.050931] DR3: 0000000000000000 DR6: 0000000000000000 DR7: 0000000000000000
[    6.050931] Process swapper/0 (pid: 1, threadinfo ffff880119e62000,
task ffff880119e68000)
[    6.050931] Stack:
[    6.050931]  ffff880119e63de8 ffffffff82b66720 ffffffff82dcb082
0000000000000000
[    6.050931]  ffff880119e63e28 ffffffff81f0f901 0000000000000000
ffffffff82dcb082
[    6.050931]  0000000000000000 00000001683fe47c ffff880119e63e48
ffffffff82dcb0f8
[    6.050931] Call Trace:
[    6.050931]  [<ffffffff82dcb082>] ? smsc47b397_init+0x19d/0x19d
[    6.050931]  [<ffffffff81f0f901>] ? genl_register_family+0x1b1/0x1e0
[    6.050931]  [<ffffffff82dcb082>] ? smsc47b397_init+0x19d/0x19d
[    6.050931]  [<ffffffff82dcb0f8>] thermal_init+0x76/0x8e
[    6.050931]  [<ffffffff81000254>] do_one_initcall+0x64/0x160
[    6.050931]  [<ffffffff82d8a321>] kernel_init_freeable+0x1bf/0x251
[    6.050931]  [<ffffffff82d89a71>] ? loglevel+0x31/0x31
[    6.050931]  [<ffffffff81ff0740>] ? rest_init+0xc0/0xc0
[    6.050931]  [<ffffffff81ff074e>] kernel_init+0xe/0xf0
[    6.050931]  [<ffffffff8202999c>] ret_from_fork+0x7c/0xb0
[    6.050931]  [<ffffffff81ff0740>] ? rest_init+0xc0/0xc0
[    6.050931] Code: 41 54 49 89 f4 53 48 83 ec 30 80 7e 18 00 75 03
0f 0b 90 49 89 fd 48 8d 7e 18 ba 10 00 00 00 31 f6 e8 3d 01 5e ff 48
85 c0 75 08 <0f> 0b 66 0f 1f 44 00 00 e8 7b f3 ff ff 49 81 fc a0 20 b8
82 74
[    6.050931] RIP  [<ffffffff81f0f968>] genl_register_mc_group+0x38/0x270
[    6.050931]  RSP <ffff880119e63dd8>
[    6.063404] ---[ end trace 60aaac53e4d8e418 ]---
