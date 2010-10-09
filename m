From: =?ISO-8859-2?Q?Jind=F8ich_Makovi=E8ka?= <makovick@gmail.com>
Subject: Re: [PATCH] forcedeth: reconfigure multicast packet filter only when needed
Date: Sat, 9 Oct 2010 22:46:44 +0200
Message-ID: <AANLkTimMRQ+cmoCJTjWeSga+YrGDCGiBOCp5rJK+vF3Q@mail.gmail.com>
References: <20100812115430.2b5d8683@starbug.prg01.itonis.net>
	<AANLkTinbgud9enM1XDQrdZVBtGnTFaUeoEL-D8Z2FmJh@mail.gmail.com>
	<20101009113213.62c2f131@nehalam>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=00032557497e9ad9de04923539c8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, aabdulla@nvidia.com, mditto@google.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:61067 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760545Ab0JIUqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 16:46:44 -0400
In-Reply-To: <20101009113213.62c2f131@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--00032557497e9ad9de04923539c8
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: quoted-printable

2010/10/9 Stephen Hemminger <shemminger@vyatta.com>:
> On Sat, 9 Oct 2010 13:26:05 +0200
> Jind=F8ich Makovi=E8ka <makovick@gmail.com> wrote:
>
>> +
>> + =A0 =A0 /* current packet filter state */
>> + =A0 =A0 u32 cur_pff;
>> + =A0 =A0 u32 cur_addr[2];
>> + =A0 =A0 u32 cur_mask[2];
>> =A0};
>
> No big deal, but couldn't you just put those temporary variables
> on the stack. and reread the current value before stopping.

Sure, this version should do the same (still untested, I don't have a
machine with nForce here at the moment). I just wanted to avoid more
NIC register accesses, but it's probably a premature optimization.

Regards,
--=20
Jindrich Makovicka

--00032557497e9ad9de04923539c8
Content-Type: text/x-patch; charset=US-ASCII; name="forcedeth2.diff"
Content-Disposition: attachment; filename="forcedeth2.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gf2y5ky80

LS0tIGZvcmNlZGV0aC5jLm9yaWcJMjAxMC0xMC0wNyAwODo1Njo1NS41NjQ1MTExNTMgKzAyMDAK
KysrIGZvcmNlZGV0aC5jCTIwMTAtMTAtMDkgMjI6MzQ6NTMuMTUxNTIzNTExICswMjAwCkBAIC0z
MDI3LDkgKzMwMjcsMTUgQEAKIHsKIAlzdHJ1Y3QgZmVfcHJpdiAqbnAgPSBuZXRkZXZfcHJpdihk
ZXYpOwogCXU4IF9faW9tZW0gKmJhc2UgPSBnZXRfaHdiYXNlKGRldik7Ci0JdTMyIGFkZHJbMl07
Ci0JdTMyIG1hc2tbMl07Ci0JdTMyIHBmZiA9IHJlYWRsKGJhc2UgKyBOdlJlZ1BhY2tldEZpbHRl
ckZsYWdzKSAmIE5WUkVHX1BGRl9QQVVTRV9SWDsKKwl1MzIgYWRkclsyXSwgcHJldl9hZGRyWzJd
OworCXUzMiBtYXNrWzJdLCBwcmV2X21hc2tbMl07CisJdTMyIHByZXZfcGZmID0gcmVhZGwoYmFz
ZSArIE52UmVnUGFja2V0RmlsdGVyRmxhZ3MpOworCXUzMiBwZmYgPSBwcmV2X3BmZiAmIE5WUkVH
X1BGRl9QQVVTRV9SWDsKKworCXByZXZfYWRkclswXSA9IHJlYWRsKGJhc2UgKyBOdlJlZ011bHRp
Y2FzdEFkZHJBKTsKKwlwcmV2X2FkZHJbMV0gPSByZWFkbChiYXNlICsgTnZSZWdNdWx0aWNhc3RB
ZGRyQik7CisJcHJldl9tYXNrWzBdID0gcmVhZGwoYmFzZSArIE52UmVnTXVsdGljYXN0TWFza0Ep
OworCXByZXZfbWFza1sxXSA9IHJlYWRsKGJhc2UgKyBOdlJlZ011bHRpY2FzdE1hc2tCKTsKIAog
CW1lbXNldChhZGRyLCAwLCBzaXplb2YoYWRkcikpOwogCW1lbXNldChtYXNrLCAwLCBzaXplb2Yo
bWFzaykpOwpAQCAtMzA3MiwxNyArMzA3OCwyNSBAQAogCX0KIAlhZGRyWzBdIHw9IE5WUkVHX01D
QVNUQUREUkFfRk9SQ0U7CiAJcGZmIHw9IE5WUkVHX1BGRl9BTFdBWVM7Ci0Jc3Bpbl9sb2NrX2ly
cSgmbnAtPmxvY2spOwotCW52X3N0b3BfcngoZGV2KTsKLQl3cml0ZWwoYWRkclswXSwgYmFzZSAr
IE52UmVnTXVsdGljYXN0QWRkckEpOwotCXdyaXRlbChhZGRyWzFdLCBiYXNlICsgTnZSZWdNdWx0
aWNhc3RBZGRyQik7Ci0Jd3JpdGVsKG1hc2tbMF0sIGJhc2UgKyBOdlJlZ011bHRpY2FzdE1hc2tB
KTsKLQl3cml0ZWwobWFza1sxXSwgYmFzZSArIE52UmVnTXVsdGljYXN0TWFza0IpOwotCXdyaXRl
bChwZmYsIGJhc2UgKyBOdlJlZ1BhY2tldEZpbHRlckZsYWdzKTsKLQlkcHJpbnRrKEtFUk5fSU5G
TyAiJXM6IHJlY29uZmlndXJhdGlvbiBmb3IgbXVsdGljYXN0IGxpc3RzLlxuIiwKLQkJZGV2LT5u
YW1lKTsKLQludl9zdGFydF9yeChkZXYpOwotCXNwaW5fdW5sb2NrX2lycSgmbnAtPmxvY2spOwor
CWlmIChwcmV2X3BmZiAhPSBwZmYKKwkgICAgfHwgbWVtY21wKHByZXZfYWRkciwgYWRkciwgc2l6
ZW9mKHByZXZfYWRkcikpICE9IDAKKwkgICAgfHwgbWVtY21wKHByZXZfbWFzaywgbWFzaywgc2l6
ZW9mKHByZXZfbWFzaykpICE9IDApCisJeworCQlkcHJpbnRrKEtFUk5fSU5GTyAiJXM6IHJlY29u
ZmlndXJhdGlvbiBmb3IgbXVsdGljYXN0IGxpc3RzLlxuIiwKKwkJCWRldi0+bmFtZSk7CisJCXNw
aW5fbG9ja19pcnEoJm5wLT5sb2NrKTsKKwkJbnZfc3RvcF9yeChkZXYpOworCQl3cml0ZWwoYWRk
clswXSwgYmFzZSArIE52UmVnTXVsdGljYXN0QWRkckEpOworCQl3cml0ZWwoYWRkclsxXSwgYmFz
ZSArIE52UmVnTXVsdGljYXN0QWRkckIpOworCQl3cml0ZWwobWFza1swXSwgYmFzZSArIE52UmVn
TXVsdGljYXN0TWFza0EpOworCQl3cml0ZWwobWFza1sxXSwgYmFzZSArIE52UmVnTXVsdGljYXN0
TWFza0IpOworCQl3cml0ZWwocGZmLCBiYXNlICsgTnZSZWdQYWNrZXRGaWx0ZXJGbGFncyk7CisJ
CW52X3N0YXJ0X3J4KGRldik7CisJCXNwaW5fdW5sb2NrX2lycSgmbnAtPmxvY2spOworCX0gZWxz
ZSB7CisJCWRwcmludGsoS0VSTl9JTkZPICIlczogcGZmIHN0YXRlIHVuY2hhbmdlZCAtIHNraXBw
aW5nIHJlY29uZmlndXJhdGlvbi5cbiIsCisJCQlkZXYtPm5hbWUpOworCX0KIH0KIAogc3RhdGlj
IHZvaWQgbnZfdXBkYXRlX3BhdXNlKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIHUzMiBwYXVzZV9m
bGFncykK
--00032557497e9ad9de04923539c8--
