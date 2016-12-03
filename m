From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: use-after-free in worker_thread
Date: Sat, 3 Dec 2016 10:14:48 -0800
Message-ID: <CAM_iQpWo42AnAT-LMJNSOL=3NQswRwHxPNC_4FAk3teAPEQDJg@mail.gmail.com>
References: <CAAeHK+x95-n__YSbzebp51ez78yjqjK4CJL=tgOgPuBuGh+q1A@mail.gmail.com>
 <CAM_iQpUSSc6xvAd3u5C3d=xk_yL4LUBgui7pgK5AHxJ8LP363A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114ab894eba66c0542c50810
Cc: "David S. Miller" <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Eric Dumazet <edumazet@google.com>,
        Bob Copeland <me@bobcopeland.com>,
        Tom Herbert <tom@herbertland.com>,
        David Decotigny <decot@googlers.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33896 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbcLCSPK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 13:15:10 -0500
In-Reply-To: <CAM_iQpUSSc6xvAd3u5C3d=xk_yL4LUBgui7pgK5AHxJ8LP363A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a114ab894eba66c0542c50810
Content-Type: text/plain; charset=UTF-8

On Sat, Dec 3, 2016 at 9:41 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sat, Dec 3, 2016 at 4:56 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi!
>>
>> I'm seeing lots of the following error reports while running the
>> syzkaller fuzzer.
>>
>> Reports appeared when I updated to 3c49de52 (Dec 2) from 2caceb32 (Dec 1).
>>
>> ==================================================================
>> BUG: KASAN: use-after-free in worker_thread+0x17d8/0x18a0
>> Read of size 8 at addr ffff880067f3ecd8 by task kworker/3:1/774
>>
>> page:ffffea00019fce00 count:1 mapcount:0 mapping:          (null)
>> index:0xffff880067f39c10 compound_mapcount: 0
>> flags: 0x500000000004080(slab|head)
>> page dumped because: kasan: bad access detected
>>
>> CPU: 3 PID: 774 Comm: kworker/3:1 Not tainted 4.9.0-rc7+ #66
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>  ffff88006c267838 ffffffff81f882da ffffffff6c25e338 1ffff1000d84ce9a
>>  ffffed000d84ce92 ffff88006c25e340 0000000041b58ab3 ffffffff8541e198
>>  ffffffff81f88048 0000000100000000 0000000041b58ab3 ffffffff853d3ee8
>> Call Trace:
>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>  [<ffffffff81f882da>] dump_stack+0x292/0x398 lib/dump_stack.c:51
>>  [<     inline     >] describe_address mm/kasan/report.c:262
>>  [<ffffffff817e50d1>] kasan_report_error+0x121/0x560 mm/kasan/report.c:368
>>  [<     inline     >] kasan_report mm/kasan/report.c:390
>>  [<ffffffff817e560e>] __asan_report_load8_noabort+0x3e/0x40
>> mm/kasan/report.c:411
>>  [<ffffffff81329b88>] worker_thread+0x17d8/0x18a0 kernel/workqueue.c:2228
>>  [<ffffffff8133ebf3>] kthread+0x323/0x3e0 kernel/kthread.c:209
>>  [<ffffffff84a2a22a>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:433
>
> Heck... this is the pending work vs. sk_destruct() race. :-/
> We can't wait for the work in RCU callback, let me think about it...

Please try the attached patch, I only did compile test, I can't access
my desktop now, so can't do further tests.

Thanks!

--001a114ab894eba66c0542c50810
Content-Type: text/plain; charset=US-ASCII; name="netlink.diff"
Content-Disposition: attachment; filename="netlink.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iw9jg91j0

ZGlmZiAtLWdpdCBhL25ldC9uZXRsaW5rL2FmX25ldGxpbmsuYyBiL25ldC9uZXRsaW5rL2FmX25l
dGxpbmsuYwppbmRleCA2MDJlNWViLi42ZjMzMDEzIDEwMDY0NAotLS0gYS9uZXQvbmV0bGluay9h
Zl9uZXRsaW5rLmMKKysrIGIvbmV0L25ldGxpbmsvYWZfbmV0bGluay5jCkBAIC0zMjIsMTEgKzMy
MiwxMyBAQCBzdGF0aWMgdm9pZCBuZXRsaW5rX3NrYl9zZXRfb3duZXJfcihzdHJ1Y3Qgc2tfYnVm
ZiAqc2tiLCBzdHJ1Y3Qgc29jayAqc2spCiAJc2tfbWVtX2NoYXJnZShzaywgc2tiLT50cnVlc2l6
ZSk7CiB9CiAKLXN0YXRpYyB2b2lkIF9fbmV0bGlua19zb2NrX2Rlc3RydWN0KHN0cnVjdCBzb2Nr
ICpzaykKK3N0YXRpYyB2b2lkIG5ldGxpbmtfc29ja19kZXN0cnVjdChzdHJ1Y3Qgc29jayAqc2sp
CiB7CiAJc3RydWN0IG5ldGxpbmtfc29jayAqbmxrID0gbmxrX3NrKHNrKTsKIAogCWlmIChubGst
PmNiX3J1bm5pbmcpIHsKKwkJaWYgKG5say0+Y2IuZG9uZSkKKwkJCW5say0+Y2IuZG9uZSgmbmxr
LT5jYik7CiAJCW1vZHVsZV9wdXQobmxrLT5jYi5tb2R1bGUpOwogCQlrZnJlZV9za2IobmxrLT5j
Yi5za2IpOwogCX0KQEAgLTM0MywyOCArMzQ1LDYgQEAgc3RhdGljIHZvaWQgX19uZXRsaW5rX3Nv
Y2tfZGVzdHJ1Y3Qoc3RydWN0IHNvY2sgKnNrKQogCVdBUk5fT04obmxrX3NrKHNrKS0+Z3JvdXBz
KTsKIH0KIAotc3RhdGljIHZvaWQgbmV0bGlua19zb2NrX2Rlc3RydWN0X3dvcmsoc3RydWN0IHdv
cmtfc3RydWN0ICp3b3JrKQotewotCXN0cnVjdCBuZXRsaW5rX3NvY2sgKm5sayA9IGNvbnRhaW5l
cl9vZih3b3JrLCBzdHJ1Y3QgbmV0bGlua19zb2NrLAotCQkJCQkJd29yayk7Ci0KLQlubGstPmNi
LmRvbmUoJm5say0+Y2IpOwotCV9fbmV0bGlua19zb2NrX2Rlc3RydWN0KCZubGstPnNrKTsKLX0K
LQotc3RhdGljIHZvaWQgbmV0bGlua19zb2NrX2Rlc3RydWN0KHN0cnVjdCBzb2NrICpzaykKLXsK
LQlzdHJ1Y3QgbmV0bGlua19zb2NrICpubGsgPSBubGtfc2soc2spOwotCi0JaWYgKG5say0+Y2Jf
cnVubmluZyAmJiBubGstPmNiLmRvbmUpIHsKLQkJSU5JVF9XT1JLKCZubGstPndvcmssIG5ldGxp
bmtfc29ja19kZXN0cnVjdF93b3JrKTsKLQkJc2NoZWR1bGVfd29yaygmbmxrLT53b3JrKTsKLQkJ
cmV0dXJuOwotCX0KLQotCV9fbmV0bGlua19zb2NrX2Rlc3RydWN0KHNrKTsKLX0KLQogLyogVGhp
cyBsb2NrIHdpdGhvdXQgV1FfRkxBR19FWENMVVNJVkUgaXMgZ29vZCBvbiBVUCBhbmQgaXQgaXMg
X3ZlcnlfIGJhZCBvbgogICogU01QLiBMb29rLCB3aGVuIHNldmVyYWwgd3JpdGVycyBzbGVlcCBh
bmQgcmVhZGVyIHdha2VzIHRoZW0gdXAsIGFsbCBidXQgb25lCiAgKiBpbW1lZGlhdGVseSBoaXQg
d3JpdGUgbG9jayBhbmQgZ3JhYiBhbGwgdGhlIGNwdXMuIEV4Y2x1c2l2ZSBzbGVlcCBzb2x2ZXMK
QEAgLTY2NCwxMSArNjQ0LDE5IEBAIHN0YXRpYyBpbnQgbmV0bGlua19jcmVhdGUoc3RydWN0IG5l
dCAqbmV0LCBzdHJ1Y3Qgc29ja2V0ICpzb2NrLCBpbnQgcHJvdG9jb2wsCiAJZ290byBvdXQ7CiB9
CiAKK3N0YXRpYyB2b2lkIG5ldGxpbmtfc29ja19wdXRfd29yayhzdHJ1Y3Qgd29ya19zdHJ1Y3Qg
KndvcmspCit7CisJc3RydWN0IG5ldGxpbmtfc29jayAqbmxrID0gY29udGFpbmVyX29mKHdvcmss
IHN0cnVjdCBuZXRsaW5rX3NvY2ssCisJCQkJCQl3b3JrKTsKKwlzb2NrX3B1dCgmbmxrLT5zayk7
Cit9CisKIHN0YXRpYyB2b2lkIGRlZmVycmVkX3B1dF9ubGtfc2soc3RydWN0IHJjdV9oZWFkICpo
ZWFkKQogewogCXN0cnVjdCBuZXRsaW5rX3NvY2sgKm5sayA9IGNvbnRhaW5lcl9vZihoZWFkLCBz
dHJ1Y3QgbmV0bGlua19zb2NrLCByY3UpOwogCi0Jc29ja19wdXQoJm5say0+c2spOworCUlOSVRf
V09SSygmbmxrLT53b3JrLCBuZXRsaW5rX3NvY2tfcHV0X3dvcmspOworCXNjaGVkdWxlX3dvcmso
Jm5say0+d29yayk7CiB9CiAKIHN0YXRpYyBpbnQgbmV0bGlua19yZWxlYXNlKHN0cnVjdCBzb2Nr
ZXQgKnNvY2spCg==
--001a114ab894eba66c0542c50810--
