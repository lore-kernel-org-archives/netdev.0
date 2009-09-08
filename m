From: "Ilia K." <mail4ilia@gmail.com>
Subject: [PATCH] add vif using local interface index (was Re: multicast
	routing and multiple interfaces with same IP)
Date: Tue, 8 Sep 2009 10:21:18 +0300
Message-ID: <1b9338490909080021n6dcac8e8x40e7c4676df74e29@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=00c09ffb585c01f62804730bd07f
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:48178 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785AbZIHHVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 03:21:16 -0400
Received: by fg-out-1718.google.com with SMTP id 22so1863080fge.1
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2009 00:21:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--00c09ffb585c01f62804730bd07f
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 7, 2009 at 7:25 PM, Octavian Purdila<opurdila@ixiacom.com> wrot=
e:
> On Monday 07 September 2009 18:35:41 you wrote:
>> Hi,
>> I'm attaching a new patch. The changes:
>> mroute.h:
>> - consistent name for interface index: vifc_lcl_ifindex
>> - union of vifc_lcl_addr and vifc_lcl_ifindex since either one of them
>> can be used
>> ipmr.c:
>> - case VIFF_USE_IFINDEX and case 0 had almost the same code, so using
>> fall through and if to eliminate code duplication
>>
>
> Hi Ilia,
>
> Looks good to me, but there are a couple of code style issues reported by
> ./scripts/checkpatch.pl.
>
> Also, here:
>
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev =3D ip_dev_find(net, vi=
fc->vifc_lcl_addr.s_addr);
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> Usually no braces are used for single line statements in if/else.

Hi,
I'm just  used to place braces either on both if/else parts or none,
but since you think this breaks linux code style, I've removed braces.
Another coding style issues reported by checkpatch.pl are fixed too.

Regards,
Ilia.

--00c09ffb585c01f62804730bd07f
Content-Type: text/x-diff; charset=US-ASCII; name="vif_add.patch"
Content-Disposition: attachment; filename="vif_add.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fzcaz8z70

PT09IG1vZGlmaWVkIGZpbGUgJ2luY2x1ZGUvbGludXgvbXJvdXRlLmgnCi0tLSBvbGQvaW5jbHVk
ZS9saW51eC9tcm91dGUuaAkyMDA5LTA4LTEwIDExOjE3OjMyICswMDAwCisrKyBuZXcvaW5jbHVk
ZS9saW51eC9tcm91dGUuaAkyMDA5LTA5LTA4IDA2OjU4OjQ2ICswMDAwCkBAIC01OSwxMyArNTks
MTggQEAKIAl1bnNpZ25lZCBjaGFyIHZpZmNfZmxhZ3M7CS8qIFZJRkZfIGZsYWdzICovCiAJdW5z
aWduZWQgY2hhciB2aWZjX3RocmVzaG9sZDsJLyogdHRsIGxpbWl0ICovCiAJdW5zaWduZWQgaW50
IHZpZmNfcmF0ZV9saW1pdDsJLyogUmF0ZSBsaW1pdGVyIHZhbHVlcyAoTkkpICovCi0Jc3RydWN0
IGluX2FkZHIgdmlmY19sY2xfYWRkcjsJLyogT3VyIGFkZHJlc3MgKi8KKwl1bmlvbiB7CisJCXN0
cnVjdCBpbl9hZGRyIHZpZmNfbGNsX2FkZHI7ICAgICAvKiBMb2NhbCBpbnRlcmZhY2UgYWRkcmVz
cyAqLworCQlpbnQgICAgICAgICAgICB2aWZjX2xjbF9pZmluZGV4OyAgLyogTG9jYWwgaW50ZXJm
YWNlIGluZGV4ICAgKi8KKwl9OwogCXN0cnVjdCBpbl9hZGRyIHZpZmNfcm10X2FkZHI7CS8qIElQ
SVAgdHVubmVsIGFkZHIgKi8KIH07CiAKLSNkZWZpbmUgVklGRl9UVU5ORUwJMHgxCS8qIElQSVAg
dHVubmVsICovCi0jZGVmaW5lIFZJRkZfU1JDUlQJMHgyCS8qIE5JICovCi0jZGVmaW5lIFZJRkZf
UkVHSVNURVIJMHg0CS8qIHJlZ2lzdGVyIHZpZgkqLworI2RlZmluZSBWSUZGX1RVTk5FTAkJMHgx
CS8qIElQSVAgdHVubmVsICovCisjZGVmaW5lIFZJRkZfU1JDUlQJCTB4MgkvKiBOSSAqLworI2Rl
ZmluZSBWSUZGX1JFR0lTVEVSCQkweDQJLyogcmVnaXN0ZXIgdmlmCSovCisjZGVmaW5lIFZJRkZf
VVNFX0lGSU5ERVgJMHg4CS8qIHVzZSB2aWZjX2xjbF9pZmluZGV4IGluc3RlYWQgb2YKKwkJCQkJ
ICAgdmlmY19sY2xfYWRkciB0byBmaW5kIGFuIGludGVyZmFjZSAqLwogCiAvKgogICoJQ2FjaGUg
bWFuaXB1bGF0aW9uIHN0cnVjdHVyZXMgZm9yIG1yb3V0ZWQgYW5kIFBJTWQKCj09PSBtb2RpZmll
ZCBmaWxlICduZXQvaXB2NC9pcG1yLmMnCi0tLSBvbGQvbmV0L2lwdjQvaXBtci5jCTIwMDktMDgt
MTAgMTE6MTc6MzIgKzAwMDAKKysrIG5ldy9uZXQvaXB2NC9pcG1yLmMJMjAwOS0wOS0wOCAwNjoz
NDoyMSArMDAwMApAQCAtNDcwLDggKzQ3MCwxOCBAQAogCQkJcmV0dXJuIGVycjsKIAkJfQogCQli
cmVhazsKKworCWNhc2UgVklGRl9VU0VfSUZJTkRFWDoKIAljYXNlIDA6Ci0JCWRldiA9IGlwX2Rl
dl9maW5kKG5ldCwgdmlmYy0+dmlmY19sY2xfYWRkci5zX2FkZHIpOworCQlpZiAodmlmYy0+dmlm
Y19mbGFncyA9PSBWSUZGX1VTRV9JRklOREVYKSB7CisJCQlkZXYgPSBkZXZfZ2V0X2J5X2luZGV4
KG5ldCwgdmlmYy0+dmlmY19sY2xfaWZpbmRleCk7CisJCQlpZiAoZGV2ICYmIGRldi0+aXBfcHRy
ID09IE5VTEwpIHsKKwkJCQlkZXZfcHV0KGRldik7CisJCQkJcmV0dXJuIC1FQUREUk5PVEFWQUlM
OworCQkJfQorCQl9IGVsc2UKKwkJCWRldiA9IGlwX2Rldl9maW5kKG5ldCwgdmlmYy0+dmlmY19s
Y2xfYWRkci5zX2FkZHIpOworCiAJCWlmICghZGV2KQogCQkJcmV0dXJuIC1FQUREUk5PVEFWQUlM
OwogCQllcnIgPSBkZXZfc2V0X2FsbG11bHRpKGRldiwgMSk7Cgo=
--00c09ffb585c01f62804730bd07f--
