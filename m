From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: [PATCH] rtnl_unlock/lock in sch_api.c TRY3
Date: Thu, 31 Mar 2005 23:11:06 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0503312309160.3390@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY="-1646943047-479590719-1112051375=:3229"
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-ID: <Pine.LNX.4.62.0503312309161.3390@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1646943047-479590719-1112051375=:3229
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; FORMAT=flowed
Content-ID: <Pine.LNX.4.62.0503312309162.3390@webhosting.rdsbv.ro>

Hello!

Trying to load a custom module (same for teql but I didn't tried it)
whan the qdisc module is not loaded, makes tc hang.
This is because qdisc_create aquires rtnl_sem and then tries to load a module 
that tries to register_netdev (that tries to aquire the same rtnl_sem).
Applying this patch makes the problem go away.

The patch was tested under 2.6.11.6.

Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>

Please apply.

The patch is a rewrite of Dave's one with small additions (module_put 
in and dev_put out).

Thanks for help goes to Dave, Thomas and Patrick.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
---1646943047-479590719-1112051375=:3229
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=sch_api_rtnl_unlock_lock-try3.patch
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.62.0503312311060.3390@webhosting.rdsbv.ro>
Content-Description: 
Content-Disposition: attachment; filename=sch_api_rtnl_unlock_lock-try3.patch

LS0tIGxpbnV4LTIuNi9uZXQvc2NoZWQvc2NoX2FwaS5jLm9yaWcJMjAwNS0w
My0yOSAwMToyMDoxOC4wMDAwMDAwMDAgKzAzMDANCisrKyBsaW51eC0yLjYv
bmV0L3NjaGVkL3NjaF9hcGkuYwkyMDA1LTAzLTMxIDIyOjQ0OjQxLjAwMDAw
MDAwMCArMDMwMA0KQEAgLTQwNiwxMSArNDA2LDI5IEBAIHFkaXNjX2NyZWF0
ZShzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCB1MzINCiANCiAJb3BzID0gcWRp
c2NfbG9va3VwX29wcyhraW5kKTsNCiAjaWZkZWYgQ09ORklHX0tNT0QNCi0J
aWYgKG9wcz09TlVMTCAmJiB0Y2FbVENBX0tJTkQtMV0gIT0gTlVMTCkgew0K
KwlpZiAob3BzID09IE5VTEwgJiYga2luZCAhPSBOVUxMKSB7DQogCQljaGFy
IG5hbWVbSUZOQU1TSVpdOw0KIAkJaWYgKHJ0YXR0cl9zdHJsY3B5KG5hbWUs
IGtpbmQsIElGTkFNU0laKSA8IElGTkFNU0laKSB7DQorCQkJLyogV2UgZHJv
cHBlZCB0aGUgUlROTCBzZW1hcGhvcmUgaW4gb3JkZXIgdG8NCisJCQkgKiBw
ZXJmb3JtIHRoZSBtb2R1bGUgbG9hZC4gIFNvLCBldmVuIGlmIHdlDQorCQkJ
ICogc3VjY2VlZGVkIGluIGxvYWRpbmcgdGhlIG1vZHVsZSB3ZSBoYXZlIHRv
DQorCQkJICogdGVsbCB0aGUgY2FsbGVyIHRvIHJlcGxheSB0aGUgcmVxdWVz
dC4gIFdlDQorCQkJICogaW5kaWNhdGUgdGhpcyB1c2luZyAtRUFHQUlOLg0K
KwkJCSAqIFdlIHJlcGxheSB0aGUgcmVxdWVzdCBiZWNhdXNlIHRoZSBkZXZp
Y2UgbWF5DQorCQkJICogZ28gYXdheSBpbiB0aGUgbWVhbiB0aW1lLg0KKwkJ
CSAqLw0KKwkJCXJ0bmxfdW5sb2NrKCk7DQogCQkJcmVxdWVzdF9tb2R1bGUo
InNjaF8lcyIsIG5hbWUpOw0KKwkJCXJ0bmxfbG9jaygpOw0KIAkJCW9wcyA9
IHFkaXNjX2xvb2t1cF9vcHMoa2luZCk7DQorCQkJaWYgKG9wcyAhPSBOVUxM
KSB7DQorCQkJCS8qIFdlIHdpbGwgdHJ5IGFnYWluIHFkaXNjX2xvb2t1cF9v
cHMsDQorCQkJCSAqIHNvIGRvbid0IGtlZXAgYSByZWZlcmVuY2UuDQorCQkJ
CSAqLw0KKwkJCQltb2R1bGVfcHV0KG9wcy0+b3duZXIpOw0KKwkJCQllcnIg
PSAtRUFHQUlOOw0KKwkJCQlnb3RvIGVycl9vdXQ7DQorCQkJfQ0KIAkJfQ0K
IAl9DQogI2VuZGlmDQpAQCAtNjA2LDE0ICs2MjQsMjAgQEAgc3RhdGljIGlu
dCB0Y19nZXRfcWRpc2Moc3RydWN0IHNrX2J1ZmYgKg0KIA0KIHN0YXRpYyBp
bnQgdGNfbW9kaWZ5X3FkaXNjKHN0cnVjdCBza19idWZmICpza2IsIHN0cnVj
dCBubG1zZ2hkciAqbiwgdm9pZCAqYXJnKQ0KIHsNCi0Jc3RydWN0IHRjbXNn
ICp0Y20gPSBOTE1TR19EQVRBKG4pOw0KLQlzdHJ1Y3QgcnRhdHRyICoqdGNh
ID0gYXJnOw0KKwlzdHJ1Y3QgdGNtc2cgKnRjbTsNCisJc3RydWN0IHJ0YXR0
ciAqKnRjYTsNCiAJc3RydWN0IG5ldF9kZXZpY2UgKmRldjsNCi0JdTMyIGNs
aWQgPSB0Y20tPnRjbV9wYXJlbnQ7DQotCXN0cnVjdCBRZGlzYyAqcSA9IE5V
TEw7DQotCXN0cnVjdCBRZGlzYyAqcCA9IE5VTEw7DQorCXUzMiBjbGlkOw0K
KwlzdHJ1Y3QgUWRpc2MgKnEsICpwOw0KIAlpbnQgZXJyOw0KIA0KKwlyZXBs
YXk6DQorCS8qIFJlaW5pdCwganVzdCBpbiBjYXNlIHNvbWV0aGluZyB0b3Vj
aGVzIHRoaXMuICovDQorCXRjbSA9IE5MTVNHX0RBVEEobik7DQorCXRjYSA9
IGFyZzsNCisJY2xpZCA9IHRjbS0+dGNtX3BhcmVudDsNCisJcSA9IHAgPSBO
VUxMOw0KKw0KIAlpZiAoKGRldiA9IF9fZGV2X2dldF9ieV9pbmRleCh0Y20t
PnRjbV9pZmluZGV4KSkgPT0gTlVMTCkNCiAJCXJldHVybiAtRU5PREVWOw0K
IA0KQEAgLTcwNyw4ICs3MzEsMTEgQEAgY3JlYXRlX25fZ3JhZnQ6DQogCQlx
ID0gcWRpc2NfY3JlYXRlKGRldiwgdGNtLT50Y21fcGFyZW50LCB0Y2EsICZl
cnIpOw0KICAgICAgICAgZWxzZQ0KIAkJcSA9IHFkaXNjX2NyZWF0ZShkZXYs
IHRjbS0+dGNtX2hhbmRsZSwgdGNhLCAmZXJyKTsNCi0JaWYgKHEgPT0gTlVM
TCkNCisJaWYgKHEgPT0gTlVMTCkgew0KKwkJaWYgKGVyciA9PSAtRUFHQUlO
KQ0KKwkJCWdvdG8gcmVwbGF5Ow0KIAkJcmV0dXJuIGVycjsNCisJfQ0KIA0K
IGdyYWZ0Og0KIAlpZiAoMSkgew0K

---1646943047-479590719-1112051375=:3229--
