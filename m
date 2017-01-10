From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/atm: warning in alloc_tx/__might_sleep
Date: Tue, 10 Jan 2017 09:35:00 -0800
Message-ID: <CAM_iQpWaHX_orHbFjKcjBZL67b6LUAmOfvS1SQP13VPZDo-69w@mail.gmail.com>
References: <CAAeHK+yZ16SKcmJbv2ARafGgAuX2wwQNE0HGdiFy1WgqPjxLMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a113f44348c54690545c0e880
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+yZ16SKcmJbv2ARafGgAuX2wwQNE0HGdiFy1WgqPjxLMg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a113f44348c54690545c0e880
Content-Type: text/plain; charset=UTF-8

On Mon, Jan 9, 2017 at 9:20 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi!
>
> I've got the following error report while running the syzkaller fuzzer.
>
> On commit a121103c922847ba5010819a3f250f1f7fc84ab8 (4.10-rc3).
>
> A reproducer is attached.
>
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 4114 at kernel/sched/core.c:7737 __might_sleep+0x149/0x1a0
> do not call blocking ops when !TASK_RUNNING; state=1 set at
> [<ffffffff813fcb22>] prepare_to_wait+0x182/0x530
> Modules linked in:
> CPU: 0 PID: 4114 Comm: a.out Not tainted 4.10.0-rc3+ #59
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:15
>  dump_stack+0x292/0x398 lib/dump_stack.c:51
>  __warn+0x19f/0x1e0 kernel/panic.c:547
>  warn_slowpath_fmt+0xc5/0x110 kernel/panic.c:562
>  __might_sleep+0x149/0x1a0 kernel/sched/core.c:7732
>  slab_pre_alloc_hook mm/slab.h:408
>  slab_alloc_node mm/slub.c:2634
>  kmem_cache_alloc_node+0x14a/0x280 mm/slub.c:2744
>  __alloc_skb+0x10f/0x800 net/core/skbuff.c:219
>  alloc_skb ./include/linux/skbuff.h:926
>  alloc_tx net/atm/common.c:75
>  vcc_sendmsg+0x5e8/0x1010 net/atm/common.c:609
>  sock_sendmsg_nosec net/socket.c:635
>  sock_sendmsg+0xca/0x110 net/socket.c:645
>  ___sys_sendmsg+0x9d2/0xae0 net/socket.c:1985
>  __sys_sendmsg+0x138/0x320 net/socket.c:2019
>  SYSC_sendmsg net/socket.c:2030
>  SyS_sendmsg+0x2d/0x50 net/socket.c:2026
>  entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:203
> RIP: 0033:0x7fcbacfddb79
> RSP: 002b:00007ffed8b5a7b8 EFLAGS: 00000206 ORIG_RAX: 000000000000002e
> RAX: ffffffffffffffda RBX: 00007ffed8b5a950 RCX: 00007fcbacfddb79
> RDX: 000000000000c000 RSI: 0000000020002000 RDI: 0000000000000003
> RBP: 0000000000400af0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000206 R12: 0000000000000000
> R13: 00007ffed8b5a950 R14: 0000000000000000 R15: 0000000000000000
> ---[ end trace 9edf2da84d8112da ]---
> atm:sigd_send: bad message type 0

The fix should be straight-forward. Mind to try the attached patch?

--001a113f44348c54690545c0e880
Content-Type: text/plain; charset=US-ASCII; name="atm.diff"
Content-Disposition: attachment; filename="atm.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ixrss0cu1

ZGlmZiAtLWdpdCBhL25ldC9hdG0vY29tbW9uLmMgYi9uZXQvYXRtL2NvbW1vbi5jCmluZGV4IGEz
Y2E5MjIuLmI3ZDk2NjEgMTAwNjQ0Ci0tLSBhL25ldC9hdG0vY29tbW9uLmMKKysrIGIvbmV0L2F0
bS9jb21tb24uYwpAQCAtNTcxLDggKzU3MSw4IEBAIGludCB2Y2NfcmVjdm1zZyhzdHJ1Y3Qgc29j
a2V0ICpzb2NrLCBzdHJ1Y3QgbXNnaGRyICptc2csIHNpemVfdCBzaXplLAogCiBpbnQgdmNjX3Nl
bmRtc2coc3RydWN0IHNvY2tldCAqc29jaywgc3RydWN0IG1zZ2hkciAqbSwgc2l6ZV90IHNpemUp
CiB7CisJREVGSU5FX1dBSVRfRlVOQyh3YWl0LCB3b2tlbl93YWtlX2Z1bmN0aW9uKTsKIAlzdHJ1
Y3Qgc29jayAqc2sgPSBzb2NrLT5zazsKLQlERUZJTkVfV0FJVCh3YWl0KTsKIAlzdHJ1Y3QgYXRt
X3ZjYyAqdmNjOwogCXN0cnVjdCBza19idWZmICpza2I7CiAJaW50IGVmZiwgZXJyb3I7CkBAIC02
MDQsNyArNjA0LDcgQEAgaW50IHZjY19zZW5kbXNnKHN0cnVjdCBzb2NrZXQgKnNvY2ssIHN0cnVj
dCBtc2doZHIgKm0sIHNpemVfdCBzaXplKQogCX0KIAogCWVmZiA9IChzaXplKzMpICYgfjM7IC8q
IGFsaWduIHRvIHdvcmQgYm91bmRhcnkgKi8KLQlwcmVwYXJlX3RvX3dhaXQoc2tfc2xlZXAoc2sp
LCAmd2FpdCwgVEFTS19JTlRFUlJVUFRJQkxFKTsKKwlhZGRfd2FpdF9xdWV1ZShza19zbGVlcChz
ayksICZ3YWl0KTsKIAllcnJvciA9IDA7CiAJd2hpbGUgKCEoc2tiID0gYWxsb2NfdHgodmNjLCBl
ZmYpKSkgewogCQlpZiAobS0+bXNnX2ZsYWdzICYgTVNHX0RPTlRXQUlUKSB7CkBAIC02MTIsNiAr
NjEyLDcgQEAgaW50IHZjY19zZW5kbXNnKHN0cnVjdCBzb2NrZXQgKnNvY2ssIHN0cnVjdCBtc2do
ZHIgKm0sIHNpemVfdCBzaXplKQogCQkJYnJlYWs7CiAJCX0KIAkJc2NoZWR1bGUoKTsKKwkJd2Fp
dF93b2tlbigmd2FpdCwgVEFTS19JTlRFUlJVUFRJQkxFLCBNQVhfU0NIRURVTEVfVElNRU9VVCk7
CiAJCWlmIChzaWduYWxfcGVuZGluZyhjdXJyZW50KSkgewogCQkJZXJyb3IgPSAtRVJFU1RBUlRT
WVM7CiAJCQlicmVhazsKQEAgLTYyMyw5ICs2MjQsOCBAQCBpbnQgdmNjX3NlbmRtc2coc3RydWN0
IHNvY2tldCAqc29jaywgc3RydWN0IG1zZ2hkciAqbSwgc2l6ZV90IHNpemUpCiAJCQlzZW5kX3Np
ZyhTSUdQSVBFLCBjdXJyZW50LCAwKTsKIAkJCWJyZWFrOwogCQl9Ci0JCXByZXBhcmVfdG9fd2Fp
dChza19zbGVlcChzayksICZ3YWl0LCBUQVNLX0lOVEVSUlVQVElCTEUpOwogCX0KLQlmaW5pc2hf
d2FpdChza19zbGVlcChzayksICZ3YWl0KTsKKwlyZW1vdmVfd2FpdF9xdWV1ZShza19zbGVlcChz
ayksICZ3YWl0KTsKIAlpZiAoZXJyb3IpCiAJCWdvdG8gb3V0OwogCXNrYi0+ZGV2ID0gTlVMTDsg
LyogZm9yIHBhdGhzIHNoYXJlZCB3aXRoIG5ldF9kZXZpY2UgaW50ZXJmYWNlcyAqLwo=
--001a113f44348c54690545c0e880--
