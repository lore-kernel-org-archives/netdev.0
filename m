From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: potential deadlock in do_ipv6_setsockopt
Date: Sun, 16 Oct 2016 11:50:26 -0700
Message-ID: <CAM_iQpWKfkkYzF6yb9fGQsieGwok196kqGtRNVVS_ULxZghyew@mail.gmail.com>
References: <f43836e6-82b2-4673-1f5e-cd41ba0bc609@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a113f1e64f78760053effefe1
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Baozeng Ding <sploving1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35868 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753411AbcJPSur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2016 14:50:47 -0400
Received: by mail-io0-f174.google.com with SMTP id j37so168558249ioo.3
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2016 11:50:47 -0700 (PDT)
In-Reply-To: <f43836e6-82b2-4673-1f5e-cd41ba0bc609@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a113f1e64f78760053effefe1
Content-Type: text/plain; charset=UTF-8

On Sun, Oct 16, 2016 at 6:34 AM, Baozeng Ding <sploving1@gmail.com> wrote:
>  Possible unsafe locking scenario:
>
>        CPU0                    CPU1
>        ----                    ----
>   lock([  165.136033] sk_lock-AF_INET6
> );
>                                lock([  165.136033] rtnl_mutex
> );
>                                lock([  165.136033] sk_lock-AF_INET6
> );
>   lock([  165.136033] rtnl_mutex
> );
>
>  *** DEADLOCK ***

This is caused by the conditional rtnl locking in do_ipv6_setsockopt().
It looks like we miss the case of IPV6_ADDRFORM.

Please try the attached patch.

--001a113f1e64f78760053effefe1
Content-Type: text/plain; charset=US-ASCII; name="ipv6-setsockopt.diff"
Content-Disposition: attachment; filename="ipv6-setsockopt.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iuczlslk0

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L2FmX2luZXQ2LmMgYi9uZXQvaXB2Ni9hZl9pbmV0Ni5jCmlu
ZGV4IDQ2YWQ2OTkuLmI4YzhkMjAgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L2FmX2luZXQ2LmMKKysr
IGIvbmV0L2lwdjYvYWZfaW5ldDYuYwpAQCAtNDE0LDcgKzQxNCw5IEBAIGludCBpbmV0Nl9yZWxl
YXNlKHN0cnVjdCBzb2NrZXQgKnNvY2spCiAJCXJldHVybiAtRUlOVkFMOwogCiAJLyogRnJlZSBt
YyBsaXN0cyAqLworCXJ0bmxfbG9jaygpOwogCWlwdjZfc29ja19tY19jbG9zZShzayk7CisJcnRu
bF91bmxvY2soKTsKIAogCS8qIEZyZWUgYWMgbGlzdHMgKi8KIAlpcHY2X3NvY2tfYWNfY2xvc2Uo
c2spOwpkaWZmIC0tZ2l0IGEvbmV0L2lwdjYvaXB2Nl9zb2NrZ2x1ZS5jIGIvbmV0L2lwdjYvaXB2
Nl9zb2NrZ2x1ZS5jCmluZGV4IDUzMzAyNjIuLjFlNGJjY2UgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2
L2lwdjZfc29ja2dsdWUuYworKysgYi9uZXQvaXB2Ni9pcHY2X3NvY2tnbHVlLmMKQEAgLTEyMCw2
ICsxMjAsNyBAQCBzdHJ1Y3QgaXB2Nl90eG9wdGlvbnMgKmlwdjZfdXBkYXRlX29wdGlvbnMoc3Ry
dWN0IHNvY2sgKnNrLAogc3RhdGljIGJvb2wgc2V0c29ja29wdF9uZWVkc19ydG5sKGludCBvcHRu
YW1lKQogewogCXN3aXRjaCAob3B0bmFtZSkgeworCWNhc2UgSVBWNl9BRERSRk9STToKIAljYXNl
IElQVjZfQUREX01FTUJFUlNISVA6CiAJY2FzZSBJUFY2X0RST1BfTUVNQkVSU0hJUDoKIAljYXNl
IElQVjZfSk9JTl9BTllDQVNUOgpkaWZmIC0tZ2l0IGEvbmV0L2lwdjYvbWNhc3QuYyBiL25ldC9p
cHY2L21jYXN0LmMKaW5kZXggNzVjMWZjNS4uNDFiYWRmZCAxMDA2NDQKLS0tIGEvbmV0L2lwdjYv
bWNhc3QuYworKysgYi9uZXQvaXB2Ni9tY2FzdC5jCkBAIC0yODIsMTAgKzI4MiwxMSBAQCB2b2lk
IGlwdjZfc29ja19tY19jbG9zZShzdHJ1Y3Qgc29jayAqc2spCiAJc3RydWN0IGlwdjZfbWNfc29j
a2xpc3QgKm1jX2xzdDsKIAlzdHJ1Y3QgbmV0ICpuZXQgPSBzb2NrX25ldChzayk7CiAKKwlBU1NF
UlRfUlROTCgpOworCiAJaWYgKCFyY3VfYWNjZXNzX3BvaW50ZXIobnAtPmlwdjZfbWNfbGlzdCkp
CiAJCXJldHVybjsKIAotCXJ0bmxfbG9jaygpOwogCXdoaWxlICgobWNfbHN0ID0gcnRubF9kZXJl
ZmVyZW5jZShucC0+aXB2Nl9tY19saXN0KSkgIT0gTlVMTCkgewogCQlzdHJ1Y3QgbmV0X2Rldmlj
ZSAqZGV2OwogCkBAIC0zMDUsNyArMzA2LDYgQEAgdm9pZCBpcHY2X3NvY2tfbWNfY2xvc2Uoc3Ry
dWN0IHNvY2sgKnNrKQogCQlrZnJlZV9yY3UobWNfbHN0LCByY3UpOwogCiAJfQotCXJ0bmxfdW5s
b2NrKCk7CiB9CiAKIGludCBpcDZfbWNfc291cmNlKGludCBhZGQsIGludCBvbW9kZSwgc3RydWN0
IHNvY2sgKnNrLAo=
--001a113f1e64f78760053effefe1--
