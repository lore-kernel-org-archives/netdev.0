From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: No fragmentation of packets with length <= mtu
Date: Wed, 6 Aug 2003 13:00:41 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308061039550.1401-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-377318441-1293612270-1060158514=:1401"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: usagi-core@linux-ipv6.org
Content-ID: <Pine.LNX.4.44.0308061153180.1676@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---377318441-1293612270-1060158514=:1401
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.44.0308061153181.1676@rhea.tcs.hut.fi>

Hi guys,

I noticed ip6_append_data() always reserves space for the fragment header
at the cost of the payload data. This leads to the unnecessary
fragmentation of packets with lengths close (or equal) to the link-mtu.
This can for example be seen with ping6 -s 1448 (on an ethernet link).

My attached patch _seems_ to fix the problem without breaking anything
else, but can you still verify this?

Thanks,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

---377318441-1293612270-1060158514=:1401
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ip6_output_frag.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0308061300410.1676@rhea.tcs.hut.fi>
Content-Description: 
Content-Disposition: attachment; filename="ip6_output_frag.patch"

LS0tIGxpbnV4LTIuNS5PTEQvbmV0L2lwdjYvaXA2X291dHB1dC5jCTIwMDMt
MDgtMDUgMTU6MTU6MDcuMDAwMDAwMDAwICswMzAwDQorKysgbGludXgtMi41
L25ldC9pcHY2L2lwNl9vdXRwdXQuYwkyMDAzLTA4LTA2IDExOjI3OjM4LjAw
MDAwMDAwMCArMDMwMA0KQEAgLTEyMTcsNyArMTIxNyw3IEBADQogCXN0cnVj
dCBpbmV0X29wdCAqaW5ldCA9IGluZXRfc2soc2spOw0KIAlzdHJ1Y3QgaXB2
Nl9waW5mbyAqbnAgPSBpbmV0Nl9zayhzayk7DQogCXN0cnVjdCBza19idWZm
ICpza2I7DQotCXVuc2lnbmVkIGludCBtYXhmcmFnbGVuLCBmcmFnaGVhZGVy
bGVuOw0KKwl1bnNpZ25lZCBpbnQgbWF4ZnJhZ2xlbiwgZnJhZ2hlYWRlcmxl
biwgeHRyYV9maF9sZW47DQogCWludCBleHRoZHJsZW47DQogCWludCBoaF9s
ZW47DQogCWludCBtdHU7DQpAQCAtMTI2Myw3ICsxMjYzLDEyIEBADQogCWho
X2xlbiA9IChydC0+dS5kc3QuZGV2LT5oYXJkX2hlYWRlcl9sZW4mfjE1KSAr
IDE2Ow0KIA0KIAlmcmFnaGVhZGVybGVuID0gc2l6ZW9mKHN0cnVjdCBpcHY2
aGRyKSArIChvcHQgPyBvcHQtPm9wdF9uZmxlbiA6IDApOw0KLQltYXhmcmFn
bGVuID0gKChtdHUgLSBmcmFnaGVhZGVybGVuKSAmIH43KSArIGZyYWdoZWFk
ZXJsZW4gLSBzaXplb2Yoc3RydWN0IGZyYWdfaGRyKTsNCisJbWF4ZnJhZ2xl
biA9ICgobXR1IC0gZnJhZ2hlYWRlcmxlbikgJiB+NykgKyBmcmFnaGVhZGVy
bGVuOw0KKw0KKwkvKiBPbmx5IHJlc2VydmUgc3BhY2UgZm9yIGZyYWdfaGRy
IGlmIHRoZSBwYWNrZXQgd2lsbCBiZSBmcmFnbWVudGVkICovDQorCXh0cmFf
ZmhfbGVuID0gKGxlbmd0aCA+IG1heGZyYWdsZW4gPyBzaXplb2Yoc3RydWN0
IGZyYWdfaGRyKSA6IDApOw0KKw0KKwltYXhmcmFnbGVuIC09IHh0cmFfZmhf
bGVuOw0KIA0KIAlpZiAobXR1IDw9IHNpemVvZihzdHJ1Y3QgaXB2Nmhkcikg
KyBJUFY2X01BWFBMRU4pIHsNCiAJCWlmIChpbmV0LT5jb3JrLmxlbmd0aCAr
IGxlbmd0aCA+IHNpemVvZihzdHJ1Y3QgaXB2NmhkcikgKyBJUFY2X01BWFBM
RU4gLSBmcmFnaGVhZGVybGVuKSB7DQpAQCAtMTI5NCw3ICsxMjk5LDcgQEAN
CiAJCQkJYWxsb2NsZW4gPSBtYXhmcmFnbGVuOw0KIAkJCWVsc2UNCiAJCQkJ
YWxsb2NsZW4gPSBmcmFnbGVuOw0KLQkJCWFsbG9jbGVuICs9IHNpemVvZihz
dHJ1Y3QgZnJhZ19oZHIpOw0KKwkJCWFsbG9jbGVuICs9IHh0cmFfZmhfbGVu
Ow0KIAkJCWlmICh0cmFuc2hkcmxlbikgew0KIAkJCQlza2IgPSBzb2NrX2Fs
bG9jX3NlbmRfc2tiKHNrLA0KIAkJCQkJCWFsbG9jbGVuICsgaGhfbGVuICsg
MTUsDQpAQCAtMTMxNyw3ICsxMzIyLDcgQEANCiAJCQlza2ItPmlwX3N1bW1l
ZCA9IGNzdW1tb2RlOw0KIAkJCXNrYi0+Y3N1bSA9IDA7DQogCQkJLyogcmVz
ZXJ2ZSA4IGJ5dGUgZm9yIGZyYWdtZW50YXRpb24gKi8NCi0JCQlza2JfcmVz
ZXJ2ZShza2IsIGhoX2xlbitzaXplb2Yoc3RydWN0IGZyYWdfaGRyKSk7DQor
CQkJc2tiX3Jlc2VydmUoc2tiLCBoaF9sZW4gKyB4dHJhX2ZoX2xlbik7DQog
DQogCQkJLyoNCiAJCQkgKglGaW5kIHdoZXJlIHRvIHN0YXJ0IHB1dHRpbmcg
Ynl0ZXMNCg==
---377318441-1293612270-1060158514=:1401--
