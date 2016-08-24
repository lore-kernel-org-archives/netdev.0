From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: kernel BUG at net/unix/garbage.c:149!"
Date: Wed, 24 Aug 2016 23:40:27 +0200
Message-ID: <9dde3145-9128-ffef-1b84-e3bd429dd4e8@stressinduktion.org>
References: <57BDAE06.1040400@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
To: Nikolay Borisov <kernel@kyup.com>, mszeredi@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:41577 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757032AbcHXVsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 17:48:03 -0400
In-Reply-To: <57BDAE06.1040400@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24.08.2016 16:24, Nikolay Borisov wrote:
> Hello, 
> 
> I hit the following BUG: 
> 
> [1851513.239831] ------------[ cut here ]------------
> [1851513.240079] kernel BUG at net/unix/garbage.c:149!
> [1851513.240313] invalid opcode: 0000 [#1] SMP 
> [1851513.248320] CPU: 37 PID: 11683 Comm: nginx Tainted: G           O    4.4.14-clouder3 #26
> [1851513.248719] Hardware name: Supermicro X10DRi/X10DRi, BIOS 1.1 04/14/2015
> [1851513.248966] task: ffff883b0f6f0000 ti: ffff880189cf0000 task.ti: ffff880189cf0000
> [1851513.249361] RIP: 0010:[<ffffffff815f895d>]  [<ffffffff815f895d>] unix_notinflight+0x8d/0x90
> [1851513.249846] RSP: 0018:ffff880189cf3cf8  EFLAGS: 00010246
> [1851513.250082] RAX: ffff883b05491968 RBX: ffff883b05491680 RCX: ffff8807f9967330
> [1851513.250476] RDX: 0000000000000001 RSI: ffff882e6d8bae00 RDI: ffffffff82073f10
> [1851513.250886] RBP: ffff880189cf3d08 R08: ffff880cbc70e200 R09: 0000000180200001
> [1851513.251280] R10: ffff883fff3b9dc0 R11: ffffea0032f1c380 R12: ffff883fbaf50000
> [1851513.251674] R13: ffffffff815f6354 R14: ffff881a7c77b140 R15: ffff881a7c7792c0
> [1851513.252083] FS:  00007f4f19573720(0000) GS:ffff883fff3a0000(0000) knlGS:0000000000000000
> [1851513.252481] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [1851513.252717] CR2: 00000000013062d8 CR3: 0000001712f32000 CR4: 00000000001406e0
> [1851513.253116] Stack:
> [1851513.253345]  00000000ffffffff ffff880189cf3d40 ffff880189cf3d28 ffffffff815f4383
> [1851513.254022]  ffff8839ee11a800 ffff8839ee11a800 ffff880189cf3d60 ffffffff815f53b8
> [1851513.254685]  0000000000000000 ffff883406788de0 0000000000000000 0000000000000000
> [1851513.255360] Call Trace:
> [1851513.255594]  [<ffffffff815f4383>] unix_detach_fds.isra.19+0x43/0x50
> [1851513.255851]  [<ffffffff815f53b8>] unix_destruct_scm+0x48/0x80
> [1851513.256090]  [<ffffffff815384af>] skb_release_head_state+0x4f/0xb0
> [1851513.256328]  [<ffffffff81538522>] skb_release_all+0x12/0x30
> [1851513.256564]  [<ffffffff81538592>] kfree_skb+0x32/0xa0
> [1851513.256810]  [<ffffffff815f6354>] unix_release_sock+0x1e4/0x2c0
> [1851513.257046]  [<ffffffff815f6450>] unix_release+0x20/0x30
> [1851513.257284]  [<ffffffff8152fbcf>] sock_release+0x1f/0x80
> [1851513.257521]  [<ffffffff8152fc42>] sock_close+0x12/0x20
> [1851513.257769]  [<ffffffff8119a8aa>] __fput+0xea/0x1f0
> [1851513.258005]  [<ffffffff8119a9ee>] ____fput+0xe/0x10
> [1851513.258244]  [<ffffffff8106fccf>] task_work_run+0x7f/0xb0
> [1851513.258488]  [<ffffffff81002210>] exit_to_usermode_loop+0xc0/0xd0
> [1851513.258728]  [<ffffffff81002a90>] syscall_return_slowpath+0x80/0xf0
> [1851513.258983]  [<ffffffff816147b4>] int_ret_from_sys_call+0x25/0x9f
> [1851513.259222] Code: 7e 5b 41 5c 5d c3 48 8b 8b e8 02 00 00 48 8b 93 f0 02 00 00 48 89 51 08 48 89 0a 48 89 83 e8 02 00 00 48 89 83 f0 02 00 00 eb b8 <0f> 0b 90 0f 1f 44 00 00 55 48 c7 c7 10 3f 07 82 48 89 e5 41 54 
> [1851513.268473] RIP  [<ffffffff815f895d>] unix_notinflight+0x8d/0x90
> [1851513.268793]  RSP <ffff880189cf3cf8>
> 
> That's essentially BUG_ON(list_empty(&u->link));
> 
> I see that all the code involving the ->link member hasn't really been 
> touched since it was introduced in 2007. So this must be a latent bug. 
> This is the first time I've observed it. The state 
> of the struct unix_sock can be found here http://sprunge.us/WCMW . Evidently, 
> there are no inflight sockets. 

One commit which could have to do with that is

commit fc64869c48494a401b1fb627c9ecc4e6c1d74b0d
Author: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date:   Wed May 18 19:19:27 2016 +0300

    net: sock: move ->sk_shutdown out of bitfields.

but that is only a wild guess.

Which unix_sock did you extract specifically in the url you provided? In
unix_notinflight we are specifically checking an unix domain socket that
is itself being transferred over another af_unix domain socket and not
the unix domain socket being released at this point.

Can you reproduce this and maybe also with a newer kernel?

Thanks for the report,
Hannes
