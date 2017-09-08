From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Fri, 8 Sep 2017 09:10:20 -0700
Message-ID: <CAM_iQpXKfUkbyuuZEZXyPrVVCoPaxnCmCARz=Jf0VtU1m9NsZg@mail.gmail.com>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="089e082249e08bf07f0558afd127"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36477 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753132AbdIHQKm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 12:10:42 -0400
Received: by mail-pf0-f170.google.com with SMTP id e199so5199630pfh.3
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 09:10:42 -0700 (PDT)
In-Reply-To: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--089e082249e08bf07f0558afd127
Content-Type: text/plain; charset="UTF-8"

On Thu, Sep 7, 2017 at 5:52 PM, Subash Abhinov Kasiviswanathan
<subashab@codeaurora.org> wrote:
> We are seeing a possible use after free in ip6_dst_destroy.
>
> It appears as if memory of the __DST_METRICS_PTR(old) was freed in some path
> and allocated
> to ion driver. ion driver has also freed it. Finally the memory is freed by
> the
> fib gc and crashes since it is already deallocated.

Does the attach (compile-only) patch help anything?

>From my _quick_ glance, it seems we miss the refcnt'ing
right in __dst_destroy_metrics_generic().

Thanks!

--089e082249e08bf07f0558afd127
Content-Type: text/plain; charset="US-ASCII"; name="dst-metrics-ref.diff"
Content-Disposition: attachment; filename="dst-metrics-ref.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j7c2urgm0

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2RzdC5jIGIvbmV0L2NvcmUvZHN0LmMKaW5kZXggMDBhYTk3
MmFkMWExLi5iMjkzYWVhZTMwMTggMTAwNjQ0Ci0tLSBhL25ldC9jb3JlL2RzdC5jCisrKyBiL25l
dC9jb3JlL2RzdC5jCkBAIC0yNDEsOCArMjQxLDE0IEBAIHZvaWQgX19kc3RfZGVzdHJveV9tZXRy
aWNzX2dlbmVyaWMoc3RydWN0IGRzdF9lbnRyeSAqZHN0LCB1bnNpZ25lZCBsb25nIG9sZCkKIAog
CW5ldyA9ICgodW5zaWduZWQgbG9uZykgJmRzdF9kZWZhdWx0X21ldHJpY3MpIHwgRFNUX01FVFJJ
Q1NfUkVBRF9PTkxZOwogCXByZXYgPSBjbXB4Y2hnKCZkc3QtPl9tZXRyaWNzLCBvbGQsIG5ldyk7
Ci0JaWYgKHByZXYgPT0gb2xkKQotCQlrZnJlZShfX0RTVF9NRVRSSUNTX1BUUihvbGQpKTsKKwlp
ZiAocHJldiA9PSBvbGQpIHsKKwkJc3RydWN0IGRzdF9tZXRyaWNzICpvbGRfcCA9IChzdHJ1Y3Qg
ZHN0X21ldHJpY3MgKilfX0RTVF9NRVRSSUNTX1BUUihvbGQpOworCisJCWlmIChwcmV2ICYgRFNU
X01FVFJJQ1NfUkVGQ09VTlRFRCkgeworCQkJaWYgKGF0b21pY19kZWNfYW5kX3Rlc3QoJm9sZF9w
LT5yZWZjbnQpKQorCQkJCWtmcmVlKG9sZF9wKTsKKwkJfQorCX0KIH0KIEVYUE9SVF9TWU1CT0wo
X19kc3RfZGVzdHJveV9tZXRyaWNzX2dlbmVyaWMpOwogCg==
--089e082249e08bf07f0558afd127--
