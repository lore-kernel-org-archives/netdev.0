From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: new kmemleak reports (was: Re: [PATCH 0/5] genetlink improvements)
Date: Tue, 1 Nov 2016 11:32:52 -0700
Message-ID: <CAM_iQpVeB+2M1MPxjRx++E=q4mDuo7XQqfQn3-160PqG8bNLdQ@mail.gmail.com>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net> <20161101172840.6d7d6278@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1141ac509751800540418eff
Cc: Johannes Berg <johannes@sipsolutions.net>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34381 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753852AbcKASdN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:33:13 -0400
Received: by mail-it0-f66.google.com with SMTP id q124so4118476itd.1
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 11:33:13 -0700 (PDT)
In-Reply-To: <20161101172840.6d7d6278@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1141ac509751800540418eff
Content-Type: text/plain; charset=UTF-8

On Tue, Nov 1, 2016 at 10:28 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> unreferenced object 0xffff8807389cba28 (size 128):
>   comm "swapper/0", pid 1, jiffies 4294898463 (age 781.332s)
>   hex dump (first 32 bytes):
>     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
>     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
>   backtrace:
>     [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
>     [<ffffffff84771246>] __kmalloc+0x206/0x5a0
>     [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
>     [<ffffffff888d9524>] netlbl_mgmt_genl_init+0x10/0x12
>     [<ffffffff888d91e8>] netlbl_netlink_init+0x9/0x26
>     [<ffffffff888d9254>] netlbl_init+0x4f/0x85
>     [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
>     [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
>     [<ffffffff85de7793>] kernel_init+0x13/0x140
>     [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40

Looks like we are missing a kfree(family->attrbuf); on error path,
but it is not related to Johannes' recent patches.

Could the attached patch help?

Thanks.

--001a1141ac509751800540418eff
Content-Type: text/plain; charset=US-ASCII; name="genetlink.diff"
Content-Disposition: attachment; filename="genetlink.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iuztyhxp0

ZGlmZiAtLWdpdCBhL25ldC9uZXRsaW5rL2dlbmV0bGluay5jIGIvbmV0L25ldGxpbmsvZ2VuZXRs
aW5rLmMKaW5kZXggYmJkM2JmZi4uZjBiNjVmZSAxMDA2NDQKLS0tIGEvbmV0L25ldGxpbmsvZ2Vu
ZXRsaW5rLmMKKysrIGIvbmV0L25ldGxpbmsvZ2VuZXRsaW5rLmMKQEAgLTM2NCw3ICszNjQsNyBA
QCBpbnQgZ2VubF9yZWdpc3Rlcl9mYW1pbHkoc3RydWN0IGdlbmxfZmFtaWx5ICpmYW1pbHkpCiAJ
CQkgICAgICAgc3RhcnQsIGVuZCArIDEsIEdGUF9LRVJORUwpOwogCWlmIChmYW1pbHktPmlkIDwg
MCkgewogCQllcnIgPSBmYW1pbHktPmlkOwotCQlnb3RvIGVycm91dF9sb2NrZWQ7CisJCWdvdG8g
ZXJyb3V0X2ZyZWU7CiAJfQogCiAJZXJyID0gZ2VubF92YWxpZGF0ZV9hc3NpZ25fbWNfZ3JvdXBz
KGZhbWlseSk7CkBAIC0zODMsNiArMzgzLDggQEAgaW50IGdlbmxfcmVnaXN0ZXJfZmFtaWx5KHN0
cnVjdCBnZW5sX2ZhbWlseSAqZmFtaWx5KQogCiBlcnJvdXRfcmVtb3ZlOgogCWlkcl9yZW1vdmUo
JmdlbmxfZmFtX2lkciwgZmFtaWx5LT5pZCk7CitlcnJvdXRfZnJlZToKKwlrZnJlZShmYW1pbHkt
PmF0dHJidWYpOwogZXJyb3V0X2xvY2tlZDoKIAlnZW5sX3VubG9ja19hbGwoKTsKIAlyZXR1cm4g
ZXJyOwo=
--001a1141ac509751800540418eff--
