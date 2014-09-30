From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Patch net-next] net_sched: fix another crash in cls_tcindex
Date: Tue, 30 Sep 2014 16:50:06 -0700
Message-ID: <542B41AE.5080004@gmail.com>
References: <1412118444-29179-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	John Fastabend <john.r.fastabend@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:45135 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbaI3XuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 19:50:23 -0400
Received: by mail-ob0-f178.google.com with SMTP id wn1so18748obc.23
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 16:50:23 -0700 (PDT)
In-Reply-To: <1412118444-29179-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2014 04:07 PM, Cong Wang wrote:
> This patch fixes the following crash:
>
> [  166.670795] BUG: unable to handle kernel NULL pointer dereference at           (null)
> [  166.674230] IP: [<ffffffff814b739f>] __list_del_entry+0x5c/0x98
> [  166.674230] PGD d0ea5067 PUD ce7fc067 PMD 0
> [  166.674230] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  166.674230] CPU: 1 PID: 775 Comm: tc Not tainted 3.17.0-rc6+ #642
> [  166.674230] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  166.674230] task: ffff8800d03c4d20 ti: ffff8800cae7c000 task.ti: ffff8800cae7c000
> [  166.674230] RIP: 0010:[<ffffffff814b739f>]  [<ffffffff814b739f>] __list_del_entry+0x5c/0x98
> [  166.674230] RSP: 0018:ffff8800cae7f7d0  EFLAGS: 00010207
> [  166.674230] RAX: 0000000000000000 RBX: ffff8800cba8d700 RCX: ffff8800cba8d700
> [  166.674230] RDX: 0000000000000000 RSI: dead000000200200 RDI: ffff8800cba8d700
> [  166.674230] RBP: ffff8800cae7f7d0 R08: 0000000000000001 R09: 0000000000000001
> [  166.674230] R10: 0000000000000000 R11: 000000000000859a R12: ffffffffffffffe8
> [  166.674230] R13: ffff8800cba8c5b8 R14: 0000000000000001 R15: ffff8800cba8d700
> [  166.674230] FS:  00007fdb5f04a740(0000) GS:ffff88011a800000(0000) knlGS:0000000000000000
> [  166.674230] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  166.674230] CR2: 0000000000000000 CR3: 00000000cf929000 CR4: 00000000000006e0
> [  166.674230] Stack:
> [  166.674230]  ffff8800cae7f7e8 ffffffff814b73e8 ffff8800cba8d6e8 ffff8800cae7f828
> [  166.674230]  ffffffff817caeec 0000000000000046 ffff8800cba8c5b0 ffff8800cba8c5b8
> [  166.674230]  0000000000000000 0000000000000001 ffff8800cf8e33e8 ffff8800cae7f848
> [  166.674230] Call Trace:
> [  166.674230]  [<ffffffff814b73e8>] list_del+0xd/0x2b
> [  166.674230]  [<ffffffff817caeec>] tcf_action_destroy+0x4c/0x71
> [  166.674230]  [<ffffffff817ca0ce>] tcf_exts_destroy+0x20/0x2d
> [  166.674230]  [<ffffffff817ec2b5>] tcindex_delete+0x196/0x1b7
>
> struct list_head can not be simply copied and we should always init it.
>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Thanks again.

Acked-by: John Fastabend <john.r.fastabend@intel.com>


-- 
John Fastabend         Intel Corporation
