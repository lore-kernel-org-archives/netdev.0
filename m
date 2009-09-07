From: "Ilia K." <mail4ilia@gmail.com>
Subject: Re: multicast routing and multiple interfaces with same IP
Date: Mon, 7 Sep 2009 18:35:41 +0300
Message-ID: <1b9338490909070835t3517bc36o396539e7ea1721fc@mail.gmail.com>
References: <1b9338490908111626j55b49177q71b8a373b6e6381b@mail.gmail.com>
	 <200908270253.19132.opurdila@ixiacom.com>
	 <20090829.000154.263733862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001636025e7d36cae00472fe9a18
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:59639 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931AbZIGPfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 11:35:39 -0400
Received: by fg-out-1718.google.com with SMTP id 22so775419fge.1
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2009 08:35:41 -0700 (PDT)
In-Reply-To: <20090829.000154.263733862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001636025e7d36cae00472fe9a18
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,
I'm attaching a new patch. The changes:
mroute.h:
- consistent name for interface index: vifc_lcl_ifindex
- union of vifc_lcl_addr and vifc_lcl_ifindex since either one of them
can be used
ipmr.c:
- case VIFF_USE_IFINDEX and case 0 had almost the same code, so using
fall through and if to eliminate code duplication

Regards,
Ilia.

On Sat, Aug 29, 2009 at 10:01 AM, David Miller<davem@davemloft.net> wrote:
> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Thu, 27 Aug 2009 02:53:18 +0300
>
>> I don't have context on multicast routing, but this caught my attention:
>>
>>>@@ -61,11 +61,13 @@
>>> =A0 =A0 =A0unsigned int vifc_rate_limit; =A0 /* Rate limiter values (NI=
) */
>>> =A0 =A0 =A0struct in_addr vifc_lcl_addr; =A0 /* Our address */
>>> =A0 =A0 =A0struct in_addr vifc_rmt_addr; =A0 /* IPIP tunnel addr */
>>>+ =A0 =A0 int ifindex; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Local i=
nterface index */
>>> };
>>>
>>
>> Wouldn't this break userspace ABI?
>>
>> Perhaps you could use a union between vifc_lcl_addr and vifc_ifindex, th=
ey seem
>> to be exclusive.
>
> Indeed, this will need to be fixed up.
>

--001636025e7d36cae00472fe9a18
Content-Type: text/x-diff; charset=US-ASCII; name="vif_add.patch"
Content-Disposition: attachment; filename="vif_add.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fzbddri00

PT09IG1vZGlmaWVkIGZpbGUgJ2luY2x1ZGUvbGludXgvbXJvdXRlLmgnCi0tLSBpbmNsdWRlL2xp
bnV4L21yb3V0ZS5oCTIwMDktMDgtMTAgMTE6MTc6MzIgKzAwMDAKKysrIGluY2x1ZGUvbGludXgv
bXJvdXRlLmgJMjAwOS0wOS0wNyAxNToxNjo0MyArMDAwMApAQCAtNTksMTMgKzU5LDE3IEBACiAJ
dW5zaWduZWQgY2hhciB2aWZjX2ZsYWdzOwkvKiBWSUZGXyBmbGFncyAqLwogCXVuc2lnbmVkIGNo
YXIgdmlmY190aHJlc2hvbGQ7CS8qIHR0bCBsaW1pdCAqLwogCXVuc2lnbmVkIGludCB2aWZjX3Jh
dGVfbGltaXQ7CS8qIFJhdGUgbGltaXRlciB2YWx1ZXMgKE5JKSAqLwotCXN0cnVjdCBpbl9hZGRy
IHZpZmNfbGNsX2FkZHI7CS8qIE91ciBhZGRyZXNzICovCisJdW5pb24geworCQlzdHJ1Y3QgaW5f
YWRkciB2aWZjX2xjbF9hZGRyOyAgICAgLyogTG9jYWwgaW50ZXJmYWNlIGFkZHJlc3MgKi8KKwkJ
aW50ICAgICAgICAgICAgdmlmY19sY2xfaWZpbmRleDsgIC8qIExvY2FsIGludGVyZmFjZSBpbmRl
eCAgICovCisJfTsKIAlzdHJ1Y3QgaW5fYWRkciB2aWZjX3JtdF9hZGRyOwkvKiBJUElQIHR1bm5l
bCBhZGRyICovCiB9OwogCi0jZGVmaW5lIFZJRkZfVFVOTkVMCTB4MQkvKiBJUElQIHR1bm5lbCAq
LwotI2RlZmluZSBWSUZGX1NSQ1JUCTB4MgkvKiBOSSAqLwotI2RlZmluZSBWSUZGX1JFR0lTVEVS
CTB4NAkvKiByZWdpc3RlciB2aWYJKi8KKyNkZWZpbmUgVklGRl9UVU5ORUwJCTB4MQkvKiBJUElQ
IHR1bm5lbCAqLworI2RlZmluZSBWSUZGX1NSQ1JUCQkweDIJLyogTkkgKi8KKyNkZWZpbmUgVklG
Rl9SRUdJU1RFUgkJMHg0CS8qIHJlZ2lzdGVyIHZpZgkqLworI2RlZmluZSBWSUZGX1VTRV9JRklO
REVYCTB4OAkvKiB1c2UgdmlmY19sY2xfaWZpbmRleCB0byBmaW5kIGFuIGludGVyZmFjZSAqLwog
CiAvKgogICoJQ2FjaGUgbWFuaXB1bGF0aW9uIHN0cnVjdHVyZXMgZm9yIG1yb3V0ZWQgYW5kIFBJ
TWQKCj09PSBtb2RpZmllZCBmaWxlICduZXQvaXB2NC9pcG1yLmMnCi0tLSBuZXQvaXB2NC9pcG1y
LmMJMjAwOS0wOC0xMCAxMToxNzozMiArMDAwMAorKysgbmV0L2lwdjQvaXBtci5jCTIwMDktMDkt
MDcgMTU6MjA6MDcgKzAwMDAKQEAgLTQ3MCw4ICs0NzAsMTggQEAKIAkJCXJldHVybiBlcnI7CiAJ
CX0KIAkJYnJlYWs7CisKKwljYXNlIFZJRkZfVVNFX0lGSU5ERVg6CiAJY2FzZSAwOgotCQlkZXYg
PSBpcF9kZXZfZmluZChuZXQsIHZpZmMtPnZpZmNfbGNsX2FkZHIuc19hZGRyKTsKKwkJaWYgKHZp
ZmMtPnZpZmNfZmxhZ3M9PVZJRkZfVVNFX0lGSU5ERVgpIHsKKwkJCWRldiA9IGRldl9nZXRfYnlf
aW5kZXgobmV0LCB2aWZjLT52aWZjX2xjbF9pZmluZGV4KTsKKwkJCWlmIChkZXYgJiYgZGV2LT5p
cF9wdHIgPT0gTlVMTCkgeworCQkJCWRldl9wdXQoZGV2KTsKKwkJCQlyZXR1cm4gLUVBRERSTk9U
QVZBSUw7CisJCQl9CisJCX0gZWxzZSB7CisJCQlkZXYgPSBpcF9kZXZfZmluZChuZXQsIHZpZmMt
PnZpZmNfbGNsX2FkZHIuc19hZGRyKTsKKwkJfQogCQlpZiAoIWRldikKIAkJCXJldHVybiAtRUFE
RFJOT1RBVkFJTDsKIAkJZXJyID0gZGV2X3NldF9hbGxtdWx0aShkZXYsIDEpOwoK
--001636025e7d36cae00472fe9a18--
