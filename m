From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] SCTP: Free the per-net sysctl table on net exit. v2
Date: Mon, 28 Jan 2013 16:20:35 -0800
Message-ID: <87zjzskffw.fsf@xmission.com>
References: <20130127.193511.2294954038548420781.davem@davemloft.net>
	<87libe3w69.fsf@xmission.com> <87obgayoo8.fsf_-_@xmission.com>
	<20130128.001125.1697434398997976656.davem@davemloft.net>
	<510637D8.9000305@fold.natur.cuni.cz> <877gmxtim7.fsf@xmission.com>
	<5106EAD5.6000703@fold.natur.cuni.cz>
	<5106ECCF.7080105@fold.natur.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, vyasevich@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49466 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293Ab3A2AVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 19:21:15 -0500
In-Reply-To: <5106ECCF.7080105@fold.natur.cuni.cz> (Martin Mokrejs's message
	of "Mon, 28 Jan 2013 22:25:35 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Mokrejs <mmokrejs@fold.natur.cuni.cz> writes:

> Martin Mokrejs wrote:
>> Hi Eric,
>> 
>> Eric W. Biederman wrote:
>>> Martin Mokrejs <mmokrejs@fold.natur.cuni.cz> writes:
>>>
>>>> David Miller wrote:
>>>>> From: ebiederm@xmission.com (Eric W. Biederman)
>>>>> Date: Sun, 27 Jan 2013 19:25:11 -0800
>>>>>
>>>>>> The typo is fixed in the patch this time in addition to my test
>>>>>> tree.
>>>>>
>>>>> Applied, thanks for fixing this up Eric.
>
>> So I haven't tested the patch yet. doh. Provided I am running 3 days without reproducing
>> the original memleak on an unpatched kernel I doubt I can easily prove it after a reboot.
>
> Umm, I spoke too early. It did happen again during these 3 days on unpatched 3.7.4:
>
> unreferenced object 0xffff880402769030 (size 2048):
>   comm "chrome_sandbox", pid 4720, jiffies 4294966701 (age 285697.590s)
>   hex dump (first 32 bytes):
>     b2 68 89 81 ff ff ff ff 20 84 4f d8 03 88 ff ff  .h...... .O.....
>     04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff815b4aad>] kmemleak_alloc+0x21/0x3e
>     [<ffffffff81110352>] slab_post_alloc_hook+0x28/0x2a
>     [<ffffffff81113fad>] __kmalloc_track_caller+0xf1/0x104
>     [<ffffffff810f10c2>] kmemdup+0x1b/0x30
>     [<ffffffff81571e9f>] sctp_sysctl_net_register+0x1f/0x72
>     [<ffffffff8155d305>] sctp_net_init+0x100/0x39f
>     [<ffffffff814ad53c>] ops_init+0xc6/0xf5
>     [<ffffffff814ad5b7>] setup_net+0x4c/0xd0
>     [<ffffffff814ada5e>] copy_net_ns+0x6d/0xd6
>     [<ffffffff810938b1>] create_new_namespaces+0xd7/0x147
>     [<ffffffff810939f4>] copy_namespaces+0x63/0x99
>     [<ffffffff81076733>] copy_process+0xa65/0x1233
>     [<ffffffff81077030>] do_fork+0x10b/0x271
>     [<ffffffff8100a0e9>] sys_clone+0x23/0x25
>     [<ffffffff815dda73>] stub_clone+0x13/0x20
>     [<ffffffffffffffff>] 0xffffffffffffffff
>
> But I won't make it to a reboot in next 2-3 days to test the patch v2, sorry.

No biggy the logic remains the same and the fix in the patch is clrearly
needed from an inspection of the code.

Eric
