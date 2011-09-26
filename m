From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: [PATCH 1/2] net: Disable false positive memory leak report
Date: Mon, 26 Sep 2011 16:42:46 +0800
Message-ID: <CA+v9cxZk_bsxrnn8zS-viH-0Wozz-T0XiFB0AE1fOOKqjcQ2ZQ@mail.gmail.com>
References: <CA+v9cxao_66a1Jb2L4M3fmUvNv8+QzWTFMqu7Dxnh7a5Zyqt0g@mail.gmail.com>
	<1317014958.2853.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Huajun Li <huajun.li.lee@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61652 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab1IZI6X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 04:58:23 -0400
Received: by fxe4 with SMTP id 4so5873644fxe.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 01:58:22 -0700 (PDT)
In-Reply-To: <1317014958.2853.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric, thanks for your response. :)

2011/9/26 Eric Dumazet <eric.dumazet@gmail.com>:
> Le samedi 24 septembre 2011 =E0 23:57 +0800, Huajun Li a =E9crit :
>> Memory leak detector reports following false positive memory leak, t=
he
>> patch disables it.
>>
>> unreferenced object 0xffff880073a70000 (size 8192):
>> =A0 comm "swapper", pid 1, jiffies 4294937832 (age 445.740s)
>> =A0 hex dump (first 32 bytes):
>> =A0 =A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =A0.........=
=2E......
>> =A0 =A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =A0.........=
=2E......
>> =A0 backtrace:
>> =A0 =A0 [<ffffffff8124db64>] create_object+0x144/0x360
>> =A0 =A0 [<ffffffff8191192e>] kmemleak_alloc+0x7e/0x110
>> =A0 =A0 [<ffffffff81235b26>] __kmalloc_node+0x156/0x3a0
>> =A0 =A0 [<ffffffff81935512>] flow_cache_cpu_prepare.clone.1+0x58/0xc=
0
>> =A0 =A0 [<ffffffff8214c361>] flow_cache_init_global+0xb6/0x1af
>> =A0 =A0 [<ffffffff8100225d>] do_one_initcall+0x4d/0x260
>> =A0 =A0 [<ffffffff820ec2e9>] kernel_init+0x161/0x23a
>> =A0 =A0 [<ffffffff8194ab04>] kernel_thread_helper+0x4/0x10
>> =A0 =A0 [<ffffffffffffffff>] 0xffffffffffffffff
>> unreferenced object 0xffff880073a74290 (size 8192):
>> =A0 comm "swapper", pid 1, jiffies 4294937832 (age 445.740s)
>> =A0 hex dump (first 32 bytes):
>> =A0 =A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =A0.........=
=2E......
>> =A0 =A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =A0.........=
=2E......
>> =A0 backtrace:
>> =A0 =A0 [<ffffffff8124db64>] create_object+0x144/0x360
>> =A0 =A0 [<ffffffff8191192e>] kmemleak_alloc+0x7e/0x110
>> =A0 =A0 [<ffffffff81235b26>] __kmalloc_node+0x156/0x3a0
>> =A0 =A0 [<ffffffff81935512>] flow_cache_cpu_prepare.clone.1+0x58/0xc=
0
>> =A0 =A0 [<ffffffff8214c361>] flow_cache_init_global+0xb6/0x1af
>> =A0 =A0 [<ffffffff8100225d>] do_one_initcall+0x4d/0x260
>> =A0 =A0 [<ffffffff820ec2e9>] kernel_init+0x161/0x23a
>> =A0 =A0 [<ffffffff8194ab04>] kernel_thread_helper+0x4/0x10
>> =A0 =A0 [<ffffffffffffffff>] 0xffffffffffffffff
>>
>>
>> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
>> ---
>> =A0net/core/flow.c | =A0 =A07 +++++++
>> =A01 files changed, 7 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/core/flow.c b/net/core/flow.c
>> index 555a456..ba3e617 100644
>> --- a/net/core/flow.c
>> +++ b/net/core/flow.c
>> @@ -365,6 +365,13 @@ static int __cpuinit
>> flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
>>
>> =A0 =A0 =A0 if (!fcp->hash_table) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 fcp->hash_table =3D kzalloc_node(sz, GFP=
_KERNEL, cpu_to_node(cpu));
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* Avoid a kmemleak false positive. The =
pointer to this block
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* is refferenced by per-CPU varaible, h=
ere just mark it as not
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* being a leak.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 kmemleak_not_leak(fcp->hash_table);
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!fcp->hash_table) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("NET: failed to a=
llocate flow cache sz %zu\n", sz);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>
> This makes no sense to me.
>
> per-cpu variables are taken into account by kmemleak.
>

Yes, I think so.

> If not, you should report this problem to kmemleak maintainer.
>

To deal with false positives/negatives, in kmemleak document, it says:
=2E..
The false positives are objects wrongly reported as being memory leaks
(orphan). For objects known not to be leaks, kmemleak provides the
kmemleak_not_leak function. The kmemleak_ignore could also be used if
the memory block is known not to contain other pointers and it will no
longer be scanned.
=2E..

=46or some scenarios, _maybe_ it's hard for kmemleak to give report
exactly, and I think it is known issue for the maintainers, so hope
there will be a powerful version soon. :)
However, before the new version of kmemleak(if there is new version)
comes, is it possible to disable this false positive report as other
components? You know, other guys maybe also check the code once they
meet the report again just like me.
