From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: [PATCH] rtnl_unlock/lock in sch_api.c TRY2
Date: Tue, 29 Mar 2005 02:09:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0503290206500.3229@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1646943047-479590719-1112051375=:3229"
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1646943047-479590719-1112051375=:3229
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

Hello!

Trying to load a custom module (same for teql but I didn't tried it)
whan the qdisc module is not loaded, makes tc hang.
This is because qdisc_create aquires rtnl_sem and then tries to load a 
module that tries to register_netdev (that tries to aquire the same 
rtnl_sem).
Applying this patch makes the problem go away.

The patch was tested.

Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>

Please apply.

The patch is a rewrite of Dave's one with a small addition (module_put).

Thanks for help goes to Dave, Thomas and Patrick.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
---1646943047-479590719-1112051375=:3229
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=rt_unlock_in_sch_api-try2.patch
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.62.0503290209350.3229@webhosting.rdsbv.ro>
Content-Description: 
Content-Disposition: attachment; filename=rt_unlock_in_sch_api-try2.patch

LS0tIGxpbnV4LTIuNi4xMS42L25ldC9zY2hlZC9zY2hfYXBpLmMub3JpZwky
MDA1LTAzLTI5IDAxOjIwOjE4LjAwMDAwMDAwMCArMDMwMA0KKysrIGxpbnV4
LTIuNi4xMS42L25ldC9zY2hlZC9zY2hfYXBpLmMJMjAwNS0wMy0yOSAwMTo0
MDo1Ny4wMDAwMDAwMDAgKzAzMDANCkBAIC00MDYsMTEgKzQwNiwyNCBAQCBx
ZGlzY19jcmVhdGUoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgdTMyDQogDQog
CW9wcyA9IHFkaXNjX2xvb2t1cF9vcHMoa2luZCk7DQogI2lmZGVmIENPTkZJ
R19LTU9EDQotCWlmIChvcHM9PU5VTEwgJiYgdGNhW1RDQV9LSU5ELTFdICE9
IE5VTEwpIHsNCisJaWYgKG9wcz09TlVMTCAmJiBraW5kICE9IE5VTEwpIHsN
CiAJCWNoYXIgbmFtZVtJRk5BTVNJWl07DQogCQlpZiAocnRhdHRyX3N0cmxj
cHkobmFtZSwga2luZCwgSUZOQU1TSVopIDwgSUZOQU1TSVopIHsNCisJCQkv
KiBXZSBkcm9wcGVkIHRoZSBSVE5MIHNlbWFwaG9yZSBpbiBvcmRlciB0bw0K
KwkJCSAqIHBlcmZvcm0gdGhlIG1vZHVsZSBsb2FkLiAgU28sIGV2ZW4gaWYg
d2UNCisJCQkgKiBzdWNjZWVkZWQgaW4gbG9hZGluZyB0aGUgbW9kdWxlIHdl
IGhhdmUgdG8NCisJCQkgKiB0ZWxsIHRoZSBjYWxsZXIgdG8gcmVwbGF5IHRo
ZSByZXF1ZXN0LiAgV2UNCisJCQkgKiBpbmRpY2F0ZSB0aGlzIHVzaW5nIC1F
QUdBSU4uDQorCQkJICovDQorCQkJcnRubF91bmxvY2soKTsNCiAJCQlyZXF1
ZXN0X21vZHVsZSgic2NoXyVzIiwgbmFtZSk7DQorCQkJcnRubF9sb2NrKCk7
DQogCQkJb3BzID0gcWRpc2NfbG9va3VwX29wcyhraW5kKTsNCisJCQlpZiAo
b3BzICE9IE5VTEwpIHsNCisJCQkJbW9kdWxlX3B1dChvcHMtPm93bmVyKTsN
CisJCQkJZXJyID0gLUVBR0FJTjsNCisJCQkJZ290byBlcnJfb3V0Ow0KKwkJ
CX0NCiAJCX0NCiAJfQ0KICNlbmRpZg0KQEAgLTYwNiwxNCArNjE5LDE5IEBA
IHN0YXRpYyBpbnQgdGNfZ2V0X3FkaXNjKHN0cnVjdCBza19idWZmICoNCiAN
CiBzdGF0aWMgaW50IHRjX21vZGlmeV9xZGlzYyhzdHJ1Y3Qgc2tfYnVmZiAq
c2tiLCBzdHJ1Y3Qgbmxtc2doZHIgKm4sIHZvaWQgKmFyZykNCiB7DQotCXN0
cnVjdCB0Y21zZyAqdGNtID0gTkxNU0dfREFUQShuKTsNCi0Jc3RydWN0IHJ0
YXR0ciAqKnRjYSA9IGFyZzsNCisJc3RydWN0IHRjbXNnICp0Y207DQorCXN0
cnVjdCBydGF0dHIgKip0Y2E7DQogCXN0cnVjdCBuZXRfZGV2aWNlICpkZXY7
DQotCXUzMiBjbGlkID0gdGNtLT50Y21fcGFyZW50Ow0KLQlzdHJ1Y3QgUWRp
c2MgKnEgPSBOVUxMOw0KLQlzdHJ1Y3QgUWRpc2MgKnAgPSBOVUxMOw0KKwl1
MzIgY2xpZDsNCisJc3RydWN0IFFkaXNjICpxLCAqcDsNCiAJaW50IGVycjsN
CiANCisJcmVwbGF5Og0KKwl0Y20gPSBOTE1TR19EQVRBKG4pOw0KKwl0Y2Eg
PSBhcmc7DQorCWNsaWQgPSB0Y20tPnRjbV9wYXJlbnQ7DQorCXEgPSBwID0g
TlVMTDsNCisNCiAJaWYgKChkZXYgPSBfX2Rldl9nZXRfYnlfaW5kZXgodGNt
LT50Y21faWZpbmRleCkpID09IE5VTEwpDQogCQlyZXR1cm4gLUVOT0RFVjsN
CiANCkBAIC03MDcsOCArNzI1LDE0IEBAIGNyZWF0ZV9uX2dyYWZ0Og0KIAkJ
cSA9IHFkaXNjX2NyZWF0ZShkZXYsIHRjbS0+dGNtX3BhcmVudCwgdGNhLCAm
ZXJyKTsNCiAgICAgICAgIGVsc2UNCiAJCXEgPSBxZGlzY19jcmVhdGUoZGV2
LCB0Y20tPnRjbV9oYW5kbGUsIHRjYSwgJmVycik7DQotCWlmIChxID09IE5V
TEwpDQorCWlmIChxID09IE5VTEwpIHsNCisJCWlmIChlcnIgPT0gLUVBR0FJ
Tikgew0KKwkJCS8qIFJlcGxheSB0aGUgcmVxdWVzdCAqLw0KKwkJCWRldl9w
dXQoZGV2KTsNCisJCQlnb3RvIHJlcGxheTsNCisJCX0NCiAJCXJldHVybiBl
cnI7DQorCX0NCiANCiBncmFmdDoNCiAJaWYgKDEpIHsNCg==

---1646943047-479590719-1112051375=:3229--
