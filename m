From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: (1/5) Fix bugs in ip6_tunnel.c ICMP error handler
Date: Mon, 1 Sep 2003 02:34:55 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309010230180.26242-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-377318441-713958419-1062372895=:26242"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, <usagi-core@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---377318441-713958419-1062372895=:26242
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi,

this patch fixes two byte order bugs in ip6ip6_err(). Please apply!

Thanks,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

---377318441-713958419-1062372895=:26242
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ip6_tnl_icmp_err.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0309010234550.26242@rhea.tcs.hut.fi>
Content-Description: 
Content-Disposition: attachment; filename="ip6_tnl_icmp_err.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTI3Ni4xLjE1IC0+IDEuMTI3Ni4y
OC4xDQojCW5ldC9pcHY2L2lwNl90dW5uZWwuYwkxLjYgICAgIC0+IDEuNyAg
ICANCiMNCiMgVGhlIGZvbGxvd2luZyBpcyB0aGUgQml0S2VlcGVyIENoYW5n
ZVNldCBMb2cNCiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0NCiMgMDMvMDkvMDEJdm51b3J2YWxAZHNsLWhraWd3MWE4
Yi5kaWFsLmluZXQuZmkJMS4xMjc2LjI4LjENCiMgRml4IGJ5dGUgb3JkZXIg
b2YgaW5mbyBwYXJhbWV0ZXIgaW4gaXA2aXA2X2VycigpDQojIC0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQojDQpkaWZm
IC1OcnUgYS9uZXQvaXB2Ni9pcDZfdHVubmVsLmMgYi9uZXQvaXB2Ni9pcDZf
dHVubmVsLmMNCi0tLSBhL25ldC9pcHY2L2lwNl90dW5uZWwuYwlNb24gU2Vw
ICAxIDAyOjAyOjU5IDIwMDMNCisrKyBiL25ldC9pcHY2L2lwNl90dW5uZWwu
YwlNb24gU2VwICAxIDAyOjAyOjU5IDIwMDMNCkBAIC00MjEsNyArNDIxLDcg
QEANCiAJCX0NCiAJCXRlbGkgPSBwYXJzZV90bHZfdG5sX2VuY19saW0oc2ti
LCBza2ItPmRhdGEpOw0KIA0KLQkJaWYgKHRlbGkgJiYgdGVsaSA9PSBpbmZv
IC0gMikgew0KKwkJaWYgKHRlbGkgJiYgdGVsaSA9PSBudG9obChpbmZvKSAt
IDIpIHsNCiAJCQl0ZWwgPSAoc3RydWN0IGlwdjZfdGx2X3RubF9lbmNfbGlt
ICopICZza2ItPmRhdGFbdGVsaV07DQogCQkJaWYgKHRlbC0+ZW5jYXBfbGlt
aXQgPT0gMCkgew0KIAkJCQlpZiAobmV0X3JhdGVsaW1pdCgpKQ0KQEAgLTQz
NCwxMCArNDM0LDkgQEANCiAJCX0NCiAJCWJyZWFrOw0KIAljYXNlIElDTVBW
Nl9QS1RfVE9PQklHOg0KLQkJbXR1ID0gaW5mbyAtIG9mZnNldDsNCi0JCWlm
IChtdHUgPD0gSVBWNl9NSU5fTVRVKSB7DQorCQltdHUgPSBudG9obChpbmZv
KSAtIG9mZnNldDsNCisJCWlmIChtdHUgPCBJUFY2X01JTl9NVFUpDQogCQkJ
bXR1ID0gSVBWNl9NSU5fTVRVOw0KLQkJfQ0KIAkJdC0+ZGV2LT5tdHUgPSBt
dHU7DQogDQogCQlpZiAoKGxlbiA9IHNpemVvZiAoKmlwdjZoKSArIGlwdjZo
LT5wYXlsb2FkX2xlbikgPiBtdHUpIHsNCg==
---377318441-713958419-1062372895=:26242--
