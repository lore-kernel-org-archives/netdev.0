From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPV6: Fix bugs in ip6ip6_tnl_xmit()
Date: Tue, 5 Aug 2003 16:42:32 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308051530560.30970-200000@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0308011353520.16201-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-377318441-99616309-1060088089=:30970"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <Pine.LNX.4.44.0308011353520.16201-100000@rhea.tcs.hut.fi>
Content-ID: <Pine.LNX.4.44.0308051637520.31172@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---377318441-99616309-1060088089=:30970
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.44.0308051637521.31172@rhea.tcs.hut.fi>

Hi,

There were two bugs in ip6ip6_tnl_xmit() which are fixed in this patch
(made against Linux 2.6.0-test2 + cset 1.1612):

- ip6_tunnel must give its own getfrag function to ip6_append_data()
- fix dst leakage when encapsulated packet too big

Please apply!

Thanks,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

---377318441-99616309-1060088089=:30970
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ip6_tnl_xmit.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0308051642320.31172@rhea.tcs.hut.fi>
Content-Description: 
Content-Disposition: attachment; filename="ip6_tnl_xmit.patch"

ZGlmZiAtTnVyIC0tZXhjbHVkZT1SQ1MgLS1leGNsdWRlPUNWUyAtLWV4Y2x1
ZGU9U0NDUyAtLWV4Y2x1ZGU9Qml0S2VlcGVyIC0tZXhjbHVkZT1DaGFuZ2VT
ZXQgbGludXgtMi41Lk9MRC9uZXQvaXB2Ni9pcDZfdHVubmVsLmMgbGludXgt
Mi41L25ldC9pcHY2L2lwNl90dW5uZWwuYw0KLS0tIGxpbnV4LTIuNS5PTEQv
bmV0L2lwdjYvaXA2X3R1bm5lbC5jCVR1ZSBBdWcgIDUgMTU6MTU6MDcgMjAw
Mw0KKysrIGxpbnV4LTIuNS9uZXQvaXB2Ni9pcDZfdHVubmVsLmMJVHVlIEF1
ZyAgNSAxNTo0NTo0MSAyMDAzDQpAQCAtNjIxLDYgKzYyMSwxNCBAQA0KIAly
ZXR1cm4gb3B0Ow0KIH0NCiANCitzdGF0aWMgaW50IA0KK2lwNmlwNl9nZXRm
cmFnKHZvaWQgKmZyb20sIGNoYXIgKnRvLCBpbnQgb2Zmc2V0LCBpbnQgbGVu
LCBpbnQgb2RkLCANCisJCXN0cnVjdCBza19idWZmICpza2IpDQorew0KKwlt
ZW1jcHkodG8sIChjaGFyICopIGZyb20gKyBvZmZzZXQsIGxlbik7DQorCXJl
dHVybiAwOw0KK30NCisNCiAvKioNCiAgKiBpcDZpcDZfdG5sX2FkZHJfY29u
ZmxpY3QgLSBjb21wYXJlIHBhY2tldCBhZGRyZXNzZXMgdG8gdHVubmVsJ3Mg
b3duDQogICogICBAdDogdGhlIG91dGdvaW5nIHR1bm5lbCBkZXZpY2UNCkBA
IC03NTUsOSArNzYzLDkgQEANCiAJfQ0KIAlpZiAoc2tiLT5sZW4gPiBtdHUp
IHsNCiAJCWljbXB2Nl9zZW5kKHNrYiwgSUNNUFY2X1BLVF9UT09CSUcsIDAs
IG10dSwgZGV2KTsNCi0JCWdvdG8gdHhfZXJyX29wdF9yZWxlYXNlOw0KKwkJ
Z290byB0eF9lcnJfZHN0X3JlbGVhc2U7DQogCX0NCi0JZXJyID0gaXA2X2Fw
cGVuZF9kYXRhKHNrLCBpcF9nZW5lcmljX2dldGZyYWcsIHNrYi0+bmgucmF3
LCBza2ItPmxlbiwgMCwNCisJZXJyID0gaXA2X2FwcGVuZF9kYXRhKHNrLCBp
cDZpcDZfZ2V0ZnJhZywgc2tiLT5uaC5yYXcsIHNrYi0+bGVuLCAwLA0KIAkJ
CSAgICAgIHQtPnBhcm1zLmhvcF9saW1pdCwgb3B0LCAmZmwsIA0KIAkJCSAg
ICAgIChzdHJ1Y3QgcnQ2X2luZm8gKilkc3QsIE1TR19ET05UV0FJVCk7DQog
DQpAQCAtNzg1LDcgKzc5Myw2IEBADQogCXJldHVybiAwOw0KIHR4X2Vycl9k
c3RfcmVsZWFzZToNCiAJZHN0X3JlbGVhc2UoZHN0KTsNCi10eF9lcnJfb3B0
X3JlbGVhc2U6DQogCWlmIChvcHQgJiYgb3B0ICE9IG9yaWdfb3B0KQ0KIAkJ
c29ja19rZnJlZV9zKHNrLCBvcHQsIG9wdC0+dG90X2xlbik7DQogdHhfZXJy
X2ZyZWVfZmxfbGJsOg0KZGlmZiAtTnVyIC0tZXhjbHVkZT1SQ1MgLS1leGNs
dWRlPUNWUyAtLWV4Y2x1ZGU9U0NDUyAtLWV4Y2x1ZGU9Qml0S2VlcGVyIC0t
ZXhjbHVkZT1DaGFuZ2VTZXQgbGludXgtMi41Lk9MRC9uZXQvbmV0c3ltcy5j
IGxpbnV4LTIuNS9uZXQvbmV0c3ltcy5jDQotLS0gbGludXgtMi41Lk9MRC9u
ZXQvbmV0c3ltcy5jCVR1ZSBBdWcgIDUgMTU6MTU6MDMgMjAwMw0KKysrIGxp
bnV4LTIuNS9uZXQvbmV0c3ltcy5jCVR1ZSBBdWcgIDUgMTM6NTg6MzQgMjAw
Mw0KQEAgLTQ4MiwxMCArNDgyLDggQEANCiBFWFBPUlRfU1lNQk9MKHN5c2N0
bF9tYXhfc3luX2JhY2tsb2cpOw0KICNlbmRpZg0KIA0KLSNlbmRpZg0KLQ0K
LSNpZiBkZWZpbmVkIChDT05GSUdfSVBWNl9NT0RVTEUpIHx8IGRlZmluZWQg
KENPTkZJR19JUF9TQ1RQX01PRFVMRSkgfHwgZGVmaW5lZCAoQ09ORklHX0lQ
VjZfVFVOTkVMX01PRFVMRSkNCiBFWFBPUlRfU1lNQk9MKGlwX2dlbmVyaWNf
Z2V0ZnJhZyk7DQorDQogI2VuZGlmDQogDQogRVhQT1JUX1NZTUJPTCh0Y3Bf
cmVhZF9zb2NrKTsNCg==
---377318441-99616309-1060088089=:30970--
