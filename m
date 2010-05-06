From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe and mac-vlans problem
Date: Thu, 6 May 2010 11:51:20 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FEA26A2D0@rrsmsx501.amr.corp.intel.com>
References: <4BDA07DB.8020206@candelatech.com>
 <201004302000.58763.arnd@arndb.de> <4BDB1CF3.8030906@candelatech.com>
 <EA929A9653AAE14F841771FB1DE5A1365FE55609F0@rrsmsx501.amr.corp.intel.com>
 <4BDB57A6.1090400@candelatech.com>
 <EA929A9653AAE14F841771FB1DE5A1365FE5560B00@rrsmsx501.amr.corp.intel.com>
 <4BE2ECEE.7070200@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_EA929A9653AAE14F841771FB1DE5A1365FEA26A2D0rrsmsx501amrc_"
Cc: Arnd Bergmann <arnd@arndb.de>, NetDev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50379 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752553Ab0EFRvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 13:51:23 -0400
In-Reply-To: <4BE2ECEE.7070200@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_EA929A9653AAE14F841771FB1DE5A1365FEA26A2D0rrsmsx501amrc_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Ben Greear wrote:
> On 04/30/2010 03:26 PM, Tantilov, Emil S wrote:
>> Ben Greear wrote:
>>> On 04/30/2010 02:13 PM, Tantilov, Emil S wrote:
>=20
>>>> I ran a quick test in my setup with 82599 and was able to pass
>>>> traffic on all 50 mac-vlans without issues. This is on net-next.
>>>=20
>>> For an 82599 system, I can get 127 mac-vlans working out of 500
>>> created.=20
>>>=20
>>> That NIC also does not go PROMISC with lots (500) of mac-vlans.
>>>=20
>>> Once I put it in promisc mode manually, it works fine.
>>>=20
>>> So, I think whatever logic is supposed to put the NIC into promisc
>>> mode when it overflows it's lookup tables isn't working for ixgbe
>>> in 2.6.31.12.
>>=20
>> Yeah, you're right. I was able to repro it.
>>=20
>> We'll look into it.
>=20
> I'd be happy to test out a patch if you have one available.
>=20
> If you don't expect to have one soon, please let me know and
> I'll add work-arounds to my code to throw ixgbe NICs into PROMISC
> mode manually.
>=20
> Thanks,
> Ben

Hi Ben,

We do have a patch in testing (see attached). It may not apply cleanly as i=
t is on top of some other patches currently in validation. Let me know if i=
t works for you.

Thanks,
Emil=

--_002_EA929A9653AAE14F841771FB1DE5A1365FEA26A2D0rrsmsx501amrc_
Content-Type: application/octet-stream; name="ixgbe_macvlan_v5.patch"
Content-Description: ixgbe_macvlan_v5.patch
Content-Disposition: attachment; filename="ixgbe_macvlan_v5.patch"; size=2680;
	creation-date="Thu, 06 May 2010 11:48:24 GMT";
	modification-date="Thu, 06 May 2010 11:50:10 GMT"
Content-Transfer-Encoding: base64

SW50cm9kdWNlIHVjX3NldF9wcm9taXNjIGZsYWcgdG8gYmV0dGVyIGhhbmRsZSB0aGUgZW5hYmxp
bmcgb2YgcHJvbWlzYyB3aGVuCnRoZSBudW1iZXIgb2YgUkFScyBpcyBleGNlZWRlZC4KClNpZ25l
ZC1vZmYtYnk6IEVtaWwgVGFudGlsb3YgPGVtaWwucy50YW50aWxvdkBpbnRlbC5jb20+CgogZHJp
dmVycy9uZXQvaXhnYmUvaXhnYmVfY29tbW9uLmMgfCAgICA1ICsrKystCiBkcml2ZXJzL25ldC9p
eGdiZS9peGdiZV9tYWluLmMgICB8ICAgIDggKysrKy0tLS0KIGRyaXZlcnMvbmV0L2l4Z2JlL2l4
Z2JlX3R5cGUuaCAgIHwgICAgMSArCiAzIGZpbGVzIGNoYW5nZWQsIDkgaW5zZXJ0aW9ucygrKSwg
NSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9peGdiZS9peGdiZV9jb21t
b24uYyBiL2RyaXZlcnMvbmV0L2l4Z2JlL2l4Z2JlX2NvbW1vbi5jCmluZGV4IGVlNDJmZDYuLjQ5
Nzc1YjYgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L2l4Z2JlL2l4Z2JlX2NvbW1vbi5jCisrKyBi
L2RyaXZlcnMvbmV0L2l4Z2JlL2l4Z2JlX2NvbW1vbi5jCkBAIC0xMzk3LDE0ICsxMzk3LDE3IEBA
IHMzMiBpeGdiZV91cGRhdGVfdWNfYWRkcl9saXN0X2dlbmVyaWMoc3RydWN0IGl4Z2JlX2h3ICpo
dywKIAkJCWZjdHJsID0gSVhHQkVfUkVBRF9SRUcoaHcsIElYR0JFX0ZDVFJMKTsKIAkJCWZjdHJs
IHw9IElYR0JFX0ZDVFJMX1VQRTsKIAkJCUlYR0JFX1dSSVRFX1JFRyhodywgSVhHQkVfRkNUUkws
IGZjdHJsKTsKKwkJCWh3LT5hZGRyX2N0cmwudWNfc2V0X3Byb21pc2MgPSB0cnVlOwogCQl9CiAJ
fSBlbHNlIHsKIAkJLyogb25seSBkaXNhYmxlIGlmIHNldCBieSBvdmVyZmxvdywgbm90IGJ5IHVz
ZXIgKi8KLQkJaWYgKG9sZF9wcm9taXNjX3NldHRpbmcgJiYgIWh3LT5hZGRyX2N0cmwudXNlcl9z
ZXRfcHJvbWlzYykgeworCQlpZiAoKG9sZF9wcm9taXNjX3NldHRpbmcgJiYgaHctPmFkZHJfY3Ry
bC51Y19zZXRfcHJvbWlzYykgJiYKKwkJICAgIShody0+YWRkcl9jdHJsLnVzZXJfc2V0X3Byb21p
c2MpKXsKIAkJCWh3X2RiZyhodywgIiBMZWF2aW5nIGFkZHJlc3Mgb3ZlcmZsb3cgcHJvbWlzYyBt
b2RlXG4iKTsKIAkJCWZjdHJsID0gSVhHQkVfUkVBRF9SRUcoaHcsIElYR0JFX0ZDVFJMKTsKIAkJ
CWZjdHJsICY9IH5JWEdCRV9GQ1RSTF9VUEU7CiAJCQlJWEdCRV9XUklURV9SRUcoaHcsIElYR0JF
X0ZDVFJMLCBmY3RybCk7CisJCQlody0+YWRkcl9jdHJsLnVjX3NldF9wcm9taXNjID0gZmFsc2U7
CiAJCX0KIAl9CiAKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2l4Z2JlL2l4Z2JlX21haW4uYyBi
L2RyaXZlcnMvbmV0L2l4Z2JlL2l4Z2JlX21haW4uYwppbmRleCA1NzdhYzcyLi43YmYzYjQwIDEw
MDY0NAotLS0gYS9kcml2ZXJzL25ldC9peGdiZS9peGdiZV9tYWluLmMKKysrIGIvZHJpdmVycy9u
ZXQvaXhnYmUvaXhnYmVfbWFpbi5jCkBAIC0yOTcwLDggKzI5NzAsOCBAQCB2b2lkIGl4Z2JlX3Nl
dF9yeF9tb2RlKHN0cnVjdCBuZXRfZGV2aWNlICpuZXRkZXYpCiAKIAlmY3RybCA9IElYR0JFX1JF
QURfUkVHKGh3LCBJWEdCRV9GQ1RSTCk7CiAKLQlpZiAobmV0ZGV2LT5mbGFncyAmIElGRl9QUk9N
SVNDKSB7Ci0JCWh3LT5hZGRyX2N0cmwudXNlcl9zZXRfcHJvbWlzYyA9IDE7CisJaWYgKG5ldGRl
di0+ZmxhZ3MgJiBJRkZfUFJPTUlTQyl7CisJCWh3LT5hZGRyX2N0cmwudXNlcl9zZXRfcHJvbWlz
YyA9IHRydWU7CQogCQlmY3RybCB8PSAoSVhHQkVfRkNUUkxfVVBFIHwgSVhHQkVfRkNUUkxfTVBF
KTsKIAkJLyogZG9uJ3QgaGFyZHdhcmUgZmlsdGVyIHZsYW5zIGluIHByb21pc2MgbW9kZSAqLwog
CQlpeGdiZV92bGFuX2ZpbHRlcl9kaXNhYmxlKGFkYXB0ZXIpOwpAQCAtMjk3OSwxMSArMjk3OSwx
MSBAQCB2b2lkIGl4Z2JlX3NldF9yeF9tb2RlKHN0cnVjdCBuZXRfZGV2aWNlICpuZXRkZXYpCiAJ
CWlmIChuZXRkZXYtPmZsYWdzICYgSUZGX0FMTE1VTFRJKSB7CiAJCQlmY3RybCB8PSBJWEdCRV9G
Q1RSTF9NUEU7CiAJCQlmY3RybCAmPSB+SVhHQkVfRkNUUkxfVVBFOwotCQl9IGVsc2UgeworCQl9
IGVsc2UgaWYgKCFody0+YWRkcl9jdHJsLnVjX3NldF9wcm9taXNjKSB7CiAJCQlmY3RybCAmPSB+
KElYR0JFX0ZDVFJMX1VQRSB8IElYR0JFX0ZDVFJMX01QRSk7CiAJCX0KIAkJaXhnYmVfdmxhbl9m
aWx0ZXJfZW5hYmxlKGFkYXB0ZXIpOwotCQlody0+YWRkcl9jdHJsLnVzZXJfc2V0X3Byb21pc2Mg
PSAwOworCQlody0+YWRkcl9jdHJsLnVzZXJfc2V0X3Byb21pc2MgPSBmYWxzZTsJCiAJfQogCiAJ
SVhHQkVfV1JJVEVfUkVHKGh3LCBJWEdCRV9GQ1RSTCwgZmN0cmwpOwpkaWZmIC0tZ2l0IGEvZHJp
dmVycy9uZXQvaXhnYmUvaXhnYmVfdHlwZS5oIGIvZHJpdmVycy9uZXQvaXhnYmUvaXhnYmVfdHlw
ZS5oCmluZGV4IDFjODljYmIuLjM4ZjI2YmIgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L2l4Z2Jl
L2l4Z2JlX3R5cGUuaAorKysgYi9kcml2ZXJzL25ldC9peGdiZS9peGdiZV90eXBlLmgKQEAgLTIy
ODUsNiArMjI4NSw3IEBAIHN0cnVjdCBpeGdiZV9hZGRyX2ZpbHRlcl9pbmZvIHsKIAl1MzIgbWNf
YWRkcl9pbl9yYXJfY291bnQ7CiAJdTMyIG10YV9pbl91c2U7CiAJdTMyIG92ZXJmbG93X3Byb21p
c2M7CisJYm9vbCB1Y19zZXRfcHJvbWlzYzsKIAlib29sIHVzZXJfc2V0X3Byb21pc2M7CiB9Owog
Cg==

--_002_EA929A9653AAE14F841771FB1DE5A1365FEA26A2D0rrsmsx501amrc_--
