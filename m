From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] htb: call qdisc_root with rcu read lock held
Date: Tue, 14 Jun 2016 18:26:05 -0700
Message-ID: <CAM_iQpXN2_FRm522t4NzjhBZFzD2NNoX7Pxqek0FkXjjmmqtEA@mail.gmail.com>
References: <1465877787-7974-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:36189 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbcFOB0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 21:26:25 -0400
Received: by mail-yw0-f193.google.com with SMTP id w195so884617ywd.3
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 18:26:24 -0700 (PDT)
In-Reply-To: <1465877787-7974-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 9:16 PM, Florian Westphal <fw@strlen.de> wrote:
> saw a debug splat:
> net/include/net/sch_generic.h:287 suspicious rcu_dereference_check() usage!
> other info that might help us debug this:
> rcu_scheduler_active = 1, debug_locks = 0
>  2 locks held by kworker/2:1/710:
>   #0:  ("events"){.+.+.+}, at: [<ffffffff8106ca1d>]
>   #1:  ((&q->work)){+.+...}, at: [<ffffffff8106ca1d>] process_one_work+0x14d/0x690
> Workqueue: events htb_work_func
> Call Trace:
>  [<ffffffff812dc763>] dump_stack+0x85/0xc2
>  [<ffffffff8109fee7>] lockdep_rcu_suspicious+0xe7/0x120
>  [<ffffffff814ced47>] htb_work_func+0x67/0x70
>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
