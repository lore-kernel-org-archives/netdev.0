From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux-next: net->netns_ids is used after calling idr_destroy for it
Date: Tue, 15 Nov 2016 10:50:50 -0800
Message-ID: <CAM_iQpU=DXKEboYHi4yO3m6VuUm1RoDRD26ZK-pVY--yUE0wNA@mail.gmail.com>
References: <CANaxB-x7FgxpAwpa-RgOvUptrCRUmAE6NFm3As+LuXUE=fHJyA@mail.gmail.com>
 <CAM_iQpUQOCsVkaRPU3OkmNvyOLDtmRRK1G3uzvi9URSVEbapJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114259fca641f205415b706a
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andrei Vagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:35483 "EHLO
        mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750928AbcKOSvM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:51:12 -0500
Received: by mail-yw0-f178.google.com with SMTP id i145so109014578ywg.2
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:51:11 -0800 (PST)
In-Reply-To: <CAM_iQpUQOCsVkaRPU3OkmNvyOLDtmRRK1G3uzvi9URSVEbapJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a114259fca641f205415b706a
Content-Type: text/plain; charset=UTF-8

On Tue, Nov 15, 2016 at 10:04 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Nov 14, 2016 at 10:23 PM, Andrei Vagin <avagin@gmail.com> wrote:
>> Hi Nicolas,
>>
>> cleanup_net() calls idr_destroy(net->netns_ids) for network namespaces
>> and then it calls unregister_netdevice_many() which calls
>> idr_alloc(net0>netns_ids). It looks wrong, doesn't it?
>>
>
> netns id is designed to allocate lazily, but yeah it makes no sense
> to allocate id for the netns being destroyed, not to mention idr is freed.
>
> I will send a patch.

Could you try the attached patch? I just did some quick netns creation/destroy
tests.

Thanks!

--001a114259fca641f205415b706a
Content-Type: text/plain; charset=US-ASCII; name="unregister-netdevice.diff"
Content-Disposition: attachment; filename="unregister-netdevice.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ivjutbvb0

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2Rldi5jIGIvbmV0L2NvcmUvZGV2LmMKaW5kZXggNmRlYmE2
OC4uZjlhMjk2OSAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvZGV2LmMKKysrIGIvbmV0L2NvcmUvZGV2
LmMKQEAgLTY2ODUsNyArNjY4NSw3IEBAIHN0YXRpYyB2b2lkIG5ldF9zZXRfdG9kbyhzdHJ1Y3Qg
bmV0X2RldmljZSAqZGV2KQogCWRldl9uZXQoZGV2KS0+ZGV2X3VucmVnX2NvdW50Kys7CiB9CiAK
LXN0YXRpYyB2b2lkIHJvbGxiYWNrX3JlZ2lzdGVyZWRfbWFueShzdHJ1Y3QgbGlzdF9oZWFkICpo
ZWFkKQorc3RhdGljIHZvaWQgcm9sbGJhY2tfcmVnaXN0ZXJlZF9tYW55KHN0cnVjdCBsaXN0X2hl
YWQgKmhlYWQsIGJvb2wgc2VuZF9ydG1zZykKIHsKIAlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCAq
dG1wOwogCUxJU1RfSEVBRChjbG9zZV9oZWFkKTsKQEAgLTY3MzcsOCArNjczNyw4IEBAIHN0YXRp
YyB2b2lkIHJvbGxiYWNrX3JlZ2lzdGVyZWRfbWFueShzdHJ1Y3QgbGlzdF9oZWFkICpoZWFkKQog
CQkqLwogCQljYWxsX25ldGRldmljZV9ub3RpZmllcnMoTkVUREVWX1VOUkVHSVNURVIsIGRldik7
CiAKLQkJaWYgKCFkZXYtPnJ0bmxfbGlua19vcHMgfHwKLQkJICAgIGRldi0+cnRubF9saW5rX3N0
YXRlID09IFJUTkxfTElOS19JTklUSUFMSVpFRCkKKwkJaWYgKCghZGV2LT5ydG5sX2xpbmtfb3Bz
IHx8CisJCSAgICBkZXYtPnJ0bmxfbGlua19zdGF0ZSA9PSBSVE5MX0xJTktfSU5JVElBTElaRUQp
ICYmIHNlbmRfcnRtc2cpCiAJCQlza2IgPSBydG1zZ19pZmluZm9fYnVpbGRfc2tiKFJUTV9ERUxM
SU5LLCBkZXYsIH4wVSwKIAkJCQkJCSAgICAgR0ZQX0tFUk5FTCk7CiAKQEAgLTY3NzcsNyArNjc3
Nyw3IEBAIHN0YXRpYyB2b2lkIHJvbGxiYWNrX3JlZ2lzdGVyZWQoc3RydWN0IG5ldF9kZXZpY2Ug
KmRldikKIAlMSVNUX0hFQUQoc2luZ2xlKTsKIAogCWxpc3RfYWRkKCZkZXYtPnVucmVnX2xpc3Qs
ICZzaW5nbGUpOwotCXJvbGxiYWNrX3JlZ2lzdGVyZWRfbWFueSgmc2luZ2xlKTsKKwlyb2xsYmFj
a19yZWdpc3RlcmVkX21hbnkoJnNpbmdsZSwgdHJ1ZSk7CiAJbGlzdF9kZWwoJnNpbmdsZSk7CiB9
CiAKQEAgLTc3NjksNiArNzc2OSwxOCBAQCB2b2lkIHVucmVnaXN0ZXJfbmV0ZGV2aWNlX3F1ZXVl
KHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIHN0cnVjdCBsaXN0X2hlYWQgKmhlYWQpCiB9CiBFWFBP
UlRfU1lNQk9MKHVucmVnaXN0ZXJfbmV0ZGV2aWNlX3F1ZXVlKTsKIAorc3RhdGljIHZvaWQgX191
bnJlZ2lzdGVyX25ldGRldmljZV9tYW55KHN0cnVjdCBsaXN0X2hlYWQgKmhlYWQsIGJvb2wgc2Vu
ZF9ydG1zZykKK3sKKwlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2OworCisJaWYgKCFsaXN0X2VtcHR5
KGhlYWQpKSB7CisJCXJvbGxiYWNrX3JlZ2lzdGVyZWRfbWFueShoZWFkLCBzZW5kX3J0bXNnKTsK
KwkJbGlzdF9mb3JfZWFjaF9lbnRyeShkZXYsIGhlYWQsIHVucmVnX2xpc3QpCisJCQluZXRfc2V0
X3RvZG8oZGV2KTsKKwkJbGlzdF9kZWwoaGVhZCk7CisJfQorfQorCiAvKioKICAqCXVucmVnaXN0
ZXJfbmV0ZGV2aWNlX21hbnkgLSB1bnJlZ2lzdGVyIG1hbnkgZGV2aWNlcwogICoJQGhlYWQ6IGxp
c3Qgb2YgZGV2aWNlcwpAQCAtNzc3OCwxNCArNzc5MCw3IEBAIEVYUE9SVF9TWU1CT0wodW5yZWdp
c3Rlcl9uZXRkZXZpY2VfcXVldWUpOwogICovCiB2b2lkIHVucmVnaXN0ZXJfbmV0ZGV2aWNlX21h
bnkoc3RydWN0IGxpc3RfaGVhZCAqaGVhZCkKIHsKLQlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2Owot
Ci0JaWYgKCFsaXN0X2VtcHR5KGhlYWQpKSB7Ci0JCXJvbGxiYWNrX3JlZ2lzdGVyZWRfbWFueSho
ZWFkKTsKLQkJbGlzdF9mb3JfZWFjaF9lbnRyeShkZXYsIGhlYWQsIHVucmVnX2xpc3QpCi0JCQlu
ZXRfc2V0X3RvZG8oZGV2KTsKLQkJbGlzdF9kZWwoaGVhZCk7Ci0JfQorCV9fdW5yZWdpc3Rlcl9u
ZXRkZXZpY2VfbWFueShoZWFkLCB0cnVlKTsKIH0KIEVYUE9SVF9TWU1CT0wodW5yZWdpc3Rlcl9u
ZXRkZXZpY2VfbWFueSk7CiAKQEAgLTgyMzksNyArODI0NCw3IEBAIHN0YXRpYyB2b2lkIF9fbmV0
X2V4aXQgZGVmYXVsdF9kZXZpY2VfZXhpdF9iYXRjaChzdHJ1Y3QgbGlzdF9oZWFkICpuZXRfbGlz
dCkKIAkJCQl1bnJlZ2lzdGVyX25ldGRldmljZV9xdWV1ZShkZXYsICZkZXZfa2lsbF9saXN0KTsK
IAkJfQogCX0KLQl1bnJlZ2lzdGVyX25ldGRldmljZV9tYW55KCZkZXZfa2lsbF9saXN0KTsKKwlf
X3VucmVnaXN0ZXJfbmV0ZGV2aWNlX21hbnkoJmRldl9raWxsX2xpc3QsIGZhbHNlKTsKIAlydG5s
X3VubG9jaygpOwogfQogCg==
--001a114259fca641f205415b706a--
