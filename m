From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: (5/5+1) Autoconfig link-local addr to IPv6 tunnels
Date: Mon, 1 Sep 2003 17:24:42 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309011709370.29198-200000@rhea.tcs.hut.fi>
References: <20030901035134.2585aa79.davem@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-377318441-1773213307-1062426282=:29198"
Cc: Pekka Savola <pekkas@netcore.fi>, <yoshfuji@linux-ipv6.org>,
   <usagi-core@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030901035134.2585aa79.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---377318441-1773213307-1062426282=:29198
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Mon, 1 Sep 2003, David S. Miller wrote:

> On Mon, 1 Sep 2003 13:48:44 +0300 (EEST)
> Pekka Savola <pekkas@netcore.fi> wrote:
>
> > Well, link-local addresses are used e.g. by routing protocols and such, so
> > having one is probably rather important..
>
> Ok.
>
> > FWIW, on FreeBSD platform they take the link-local address of the first
> > physical interface, and give the exact same link-local address on all of
> > the tunnels, disambiuating them with the scope identifier.  Seems like an
> > OK appaorach too, and guarantees (to the degree of unique MAC addresses)
> > that the addresses of the endpoints do not clash.
>
> Interesting approach...  I'm not particularly picky about how this
> uniqueness issue is solved.

Ok, this incremental patch to my previous addrconf.c patch generates a
link-local address to the IPv6 tunnel device. It first tries to inherit
the EUI64 identifier of some other device and if this fails, uses a
random interface id.

Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

---377318441-1773213307-1062426282=:29198
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ip6_tnl_autoconf.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0309011724420.29198@rhea.tcs.hut.fi>
Content-Description: 
Content-Disposition: attachment; filename="ip6_tnl_autoconf.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTI5MSAgLT4gMS4xMjkyIA0KIwkg
bmV0L2lwdjYvYWRkcmNvbmYuYwkxLjY0ICAgIC0+IDEuNjUgICANCiMNCiMg
VGhlIGZvbGxvd2luZyBpcyB0aGUgQml0S2VlcGVyIENoYW5nZVNldCBMb2cN
CiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0NCiMgMDMvMDkvMDEJdm51b3J2YWxAYW1iZXIuaHV0Lm1lZGlhcG9saS5j
b20JMS4xMjkyDQojIEF1dG9jb25maWd1cmUgYSBsaW5rLWxvY2FsIGFkZHJl
c3MgdG8gYWxsIElQdjYgdHVubmVsIGRldmljZXMNCiMgLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCiMNCmRpZmYgLU5y
dSBhL25ldC9pcHY2L2FkZHJjb25mLmMgYi9uZXQvaXB2Ni9hZGRyY29uZi5j
DQotLS0gYS9uZXQvaXB2Ni9hZGRyY29uZi5jCU1vbiBTZXAgIDEgMTY6NTY6
MzkgMjAwMw0KKysrIGIvbmV0L2lwdjYvYWRkcmNvbmYuYwlNb24gU2VwICAx
IDE2OjU2OjM5IDIwMDMNCkBAIC0xODIwLDYgKzE4MjAsMzkgQEANCiANCiAN
CiAjaWYgZGVmaW5lZChDT05GSUdfSVBWNl9UVU5ORUwpIHx8IGRlZmluZWQo
Q09ORklHX0lQVjZfVFVOTkVMX01PRFVMRSkNCisNCisvKiANCisgKiBBdXRv
Y29uZmlndXJlIHR1bm5lbCB3aXRoIGEgbGluay1sb2NhbCBhZGRyZXNzIHNv
IHJvdXRpbmcgcHJvdG9jb2xzLA0KKyAqIERIQ1B2NiwgTUxEIGV0Yy4gY2Fu
IGJlIHJ1biBvdmVyIHRoZSB2aXJ0dWFsIGxpbmsgDQorICovDQorDQorc3Rh
dGljIHZvaWQgaXA2X3RubF9hZGRfbGlua2xvY2FsKHN0cnVjdCBpbmV0Nl9k
ZXYgKmlkZXYpDQorew0KKwlzdHJ1Y3QgaW42X2FkZHIgYWRkcjsNCisJc3Ry
dWN0IG5ldF9kZXZpY2UgKmRldjsgDQorCUFTU0VSVF9SVE5MKCk7DQorDQor
CW1lbXNldCgmYWRkciwgMCwgc2l6ZW9mKHN0cnVjdCBpbjZfYWRkcikpOw0K
KwlhZGRyLnM2X2FkZHIzMlswXSA9IGh0b25sKDB4RkU4MDAwMDApOw0KKw0K
KwkvKiB0cnkgdG8gaW5oZXJpdCBFVUk2NCBmcm9tIGFub3RoZXIgZGV2aWNl
ICovDQorCWZvciAoZGV2ID0gZGV2X2Jhc2U7IGRldjsgZGV2ID0gZGV2LT5u
ZXh0KSB7DQorCQlpZiAoIWlwdjZfZ2VuZXJhdGVfZXVpNjQoYWRkci5zNl9h
ZGRyICsgOCwgZGV2KSkgew0KKwkJCWFkZHJjb25mX2FkZF9saW5rbG9jYWwo
aWRldiwgJmFkZHIpOw0KKwkJCXJldHVybjsNCisJCX0NCisJfQ0KKyNpZmRl
ZiBDT05GSUdfSVBWNl9QUklWQUNZDQorCS8qIGVsc2UgdHJ5IHRvIGdlbmVy
YXRlIGEgcmFuZG9tIGlkZW50aWZpZXIgKi8NCisJaWYgKCFfX2lwdjZfcmVn
ZW5fcm5kaWQoaWRldikpIHsNCisJCW1lbWNweShhZGRyLnM2X2FkZHIgKyA4
LCBpZGV2LT5ybmRpZCwgOCk7DQorCQlhZGRyY29uZl9hZGRfbGlua2xvY2Fs
KGlkZXYsICZhZGRyKTsNCisJCXJldHVybjsNCisJfQ0KKyNlbmRpZg0KKwlw
cmludGsoS0VSTl9ERUJVRyAiaW5pdCBpcDYtaXA2OiBhZGRfbGlua2xvY2Fs
IGZhaWxlZFxuIik7DQorfQ0KKw0KIHN0YXRpYyB2b2lkIGFkZHJjb25mX2lw
Nl90bmxfY29uZmlnKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpDQogew0KIAlz
dHJ1Y3QgaW5ldDZfZGV2ICppZGV2Ow0KQEAgLTE4MzAsNiArMTg2Myw4IEBA
DQogCQlwcmludGsoS0VSTl9ERUJVRyAiaW5pdCBpcDYtaXA2OiBmaW5kX2Rl
diBmYWlsZWRcbiIpOw0KIAkJcmV0dXJuOw0KIAl9DQorCWlwNl90bmxfYWRk
X2xpbmtsb2NhbChpZGV2KTsNCisJYWRkcmNvbmZfYWRkX21yb3V0ZShkZXYp
Ow0KIH0NCiAjZW5kaWYNCiANCkBAIC0yMTM1LDYgKzIxNzAsNyBAQA0KIA0K
IAlpZiAoaWZwLT5pZGV2LT5jbmYuZm9yd2FyZGluZyA9PSAwICYmDQogCSAg
ICAoZGV2LT5mbGFncyZJRkZfTE9PUEJBQ0spID09IDAgJiYNCisJICAgIGRl
di0+dHlwZSAhPSBBUlBIUkRfVFVOTkVMNiAmJg0KIAkgICAgKGlwdjZfYWRk
cl90eXBlKCZpZnAtPmFkZHIpICYgSVBWNl9BRERSX0xJTktMT0NBTCkpIHsN
CiAJCXN0cnVjdCBpbjZfYWRkciBhbGxfcm91dGVyczsNCiANCg==
---377318441-1773213307-1062426282=:29198--
