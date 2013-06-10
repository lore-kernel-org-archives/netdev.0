From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: kmemleak reports in kernel 3.9.5+
Date: Mon, 10 Jun 2013 23:32:12 +0100
Message-ID: <CAHkRjk5SDCbqr0Br24YQuHr=j7DmnpYk9CShrz1qiuYff7+qAw@mail.gmail.com>
References: <51B61982.2050903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:45421 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab3FJWcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 18:32:32 -0400
In-Reply-To: <51B61982.2050903@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 June 2013 19:22, Ben Greear <greearb@candelatech.com> wrote:
> We had a system go OOM while doing lots of wireless
> stations.  (System had 8GB of RAM, so I suspect a leak).
>
> I enabled kmemleak in a 3.9.5 (plus some local patches) and
> I see the entries below.  Any idea if these are real or not?
>
> unreferenced object 0xffff880212281c80 (size 128):
>   comm "systemd", pid 1, jiffies 4294682684 (age 1159.517s)
>   hex dump (first 32 bytes):
>     60 39 27 12 02 88 ff ff 00 02 20 00 00 00 ad de  `9'....... .....
>     10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
>     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
>     [<ffffffff8118d605>] __kmalloc+0xf9/0x122
>     [<ffffffff8154946d>] kzalloc.clone.0+0xe/0x10
>     [<ffffffff81549494>] fib_default_rule_add+0x25/0x7a
>     [<ffffffffa014f5a9>] ip6mr_net_init+0x7e/0x118 [ipv6]
>     [<ffffffff8152c992>] ops_init+0xd6/0xf7
>     [<ffffffff8152cb51>] register_pernet_operations+0xc2/0x16b
>     [<ffffffff8152cc87>] register_pernet_subsys+0x2e/0x47
>     [<ffffffffa016db69>] 0xffffffffa016db69
>     [<ffffffffa016d109>] 0xffffffffa016d109
>     [<ffffffff8100207f>] do_one_initcall+0x7f/0x13e
>     [<ffffffff810f3985>] do_init_module+0x44/0x18f
>     [<ffffffff810f5da7>] load_module+0x14d1/0x168e
>     [<ffffffff810f6114>] sys_init_module+0xfd/0x101
>     [<ffffffff815f6599>] system_call_fastpath+0x16/0x1b

No idea yet. You can try:

echo clear > /sys/kernel/debug/kmemleak

and see if there are more appearing after. All seem to have a common
allocation path via debug_object_activate -> ... ->
rcuhead_fixup_activate -> ... -> __debug_object_init.

--
Catalin
