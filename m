From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv4: disable BH in set_ping_group_range()
Date: Thu, 20 Oct 2016 12:44:02 -0700
Message-ID: <CAM_iQpV-00gemayMkdLGzb8wo8CNimOZQHDXrvH1jeN6Svrs8w@mail.gmail.com>
References: <1476984408.7065.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVFQD0Oqf8YO9HybDpPMhzMMK5m_wNyLwTfVpEwpAVBNw@mail.gmail.com> <CAM_iQpVBHa2ujKN1hsU0LT+g899+WEy9a1oBgDj1FmpifPmz6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1141d7e4081be3053f512781
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Eric Salo <salo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:36503 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753865AbcJTToZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 15:44:25 -0400
Received: by mail-it0-f54.google.com with SMTP id 139so178974420itm.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 12:44:25 -0700 (PDT)
In-Reply-To: <CAM_iQpVBHa2ujKN1hsU0LT+g899+WEy9a1oBgDj1FmpifPmz6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1141d7e4081be3053f512781
Content-Type: text/plain; charset=UTF-8

On Thu, Oct 20, 2016 at 12:40 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Oct 20, 2016 at 12:32 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Thu, Oct 20, 2016 at 10:26 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> From: Eric Dumazet <edumazet@google.com>
>>>
>>> In commit 4ee3bd4a8c746 ("ipv4: disable BH when changing ip local port
>>> range") Cong added BH protection in set_local_port_range() but missed
>>> that same fix was needed in set_ping_group_range()
>>
>> Don't know why ping_group_range shares the same lock with local_port_range...
>> Perhaps just for saving a few bytes, but that is why I missed this place.
>
> Hold on... We clearly have typos there... Your fix is not correct.

We need the attached patch, your patch should be reverted, because
unlike local_port_range we never read it in BH context, no need to bother _bh.

--001a1141d7e4081be3053f512781
Content-Type: text/plain; charset=US-ASCII; name="ping.diff"
Content-Disposition: attachment; filename="ping.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iuira8380

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3N5c2N0bF9uZXRfaXB2NC5jIGIvbmV0L2lwdjQvc3lzY3Rs
X25ldF9pcHY0LmMKaW5kZXggMWNiNjdkZS4uODBiYzM2YiAxMDA2NDQKLS0tIGEvbmV0L2lwdjQv
c3lzY3RsX25ldF9pcHY0LmMKKysrIGIvbmV0L2lwdjQvc3lzY3RsX25ldF9pcHY0LmMKQEAgLTk2
LDExICs5NiwxMSBAQCBzdGF0aWMgdm9pZCBpbmV0X2dldF9waW5nX2dyb3VwX3JhbmdlX3RhYmxl
KHN0cnVjdCBjdGxfdGFibGUgKnRhYmxlLCBrZ2lkX3QgKmxvdwogCQljb250YWluZXJfb2YodGFi
bGUtPmRhdGEsIHN0cnVjdCBuZXQsIGlwdjQucGluZ19ncm91cF9yYW5nZS5yYW5nZSk7CiAJdW5z
aWduZWQgaW50IHNlcTsKIAlkbyB7Ci0JCXNlcSA9IHJlYWRfc2VxYmVnaW4oJm5ldC0+aXB2NC5p
cF9sb2NhbF9wb3J0cy5sb2NrKTsKKwkJc2VxID0gcmVhZF9zZXFiZWdpbigmbmV0LT5pcHY0LnBp
bmdfZ3JvdXBfcmFuZ2UubG9jayk7CiAKIAkJKmxvdyA9IGRhdGFbMF07CiAJCSpoaWdoID0gZGF0
YVsxXTsKLQl9IHdoaWxlIChyZWFkX3NlcXJldHJ5KCZuZXQtPmlwdjQuaXBfbG9jYWxfcG9ydHMu
bG9jaywgc2VxKSk7CisJfSB3aGlsZSAocmVhZF9zZXFyZXRyeSgmbmV0LT5pcHY0LnBpbmdfZ3Jv
dXBfcmFuZ2UubG9jaywgc2VxKSk7CiB9CiAKIC8qIFVwZGF0ZSBzeXN0ZW0gdmlzaWJsZSBJUCBw
b3J0IHJhbmdlICovCkBAIC0xMDksMTAgKzEwOSwxMCBAQCBzdGF0aWMgdm9pZCBzZXRfcGluZ19n
cm91cF9yYW5nZShzdHJ1Y3QgY3RsX3RhYmxlICp0YWJsZSwga2dpZF90IGxvdywga2dpZF90IGhp
ZwogCWtnaWRfdCAqZGF0YSA9IHRhYmxlLT5kYXRhOwogCXN0cnVjdCBuZXQgKm5ldCA9CiAJCWNv
bnRhaW5lcl9vZih0YWJsZS0+ZGF0YSwgc3RydWN0IG5ldCwgaXB2NC5waW5nX2dyb3VwX3Jhbmdl
LnJhbmdlKTsKLQl3cml0ZV9zZXFsb2NrKCZuZXQtPmlwdjQuaXBfbG9jYWxfcG9ydHMubG9jayk7
CisJd3JpdGVfc2VxbG9jaygmbmV0LT5pcHY0LnBpbmdfZ3JvdXBfcmFuZ2UubG9jayk7CiAJZGF0
YVswXSA9IGxvdzsKIAlkYXRhWzFdID0gaGlnaDsKLQl3cml0ZV9zZXF1bmxvY2soJm5ldC0+aXB2
NC5pcF9sb2NhbF9wb3J0cy5sb2NrKTsKKwl3cml0ZV9zZXF1bmxvY2soJm5ldC0+aXB2NC5waW5n
X2dyb3VwX3JhbmdlLmxvY2spOwogfQogCiAvKiBWYWxpZGF0ZSBjaGFuZ2VzIGZyb20gL3Byb2Mg
aW50ZXJmYWNlLiAqLwo=
--001a1141d7e4081be3053f512781--
