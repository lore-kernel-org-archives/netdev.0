From: jamal <hadi@cyberus.ca>
Subject: SIOCADDMULTI for unicast broken
Date: Fri, 3 Jan 2003 16:46:40 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030103164001.S48623@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-1640597484-1041630400=:48623"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Donald Becker <becker@scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--0-1640597484-1041630400=:48623
Content-Type: TEXT/PLAIN; charset=US-ASCII


Some programs require ability to accept packets destined to certain
MAC addresses (in addition to their own).
Example Jerome Ettienes vrrpd (http://w3.arobas.net/~jetienne/vrrpd/)

The trick is to add unicast addresses via SIOCADDMULTI and accept those
packets when they make their way up the stack.
I think this used to work, no? Donald, any history/comments behind
this?
Patch attahced, not very well tested but looks safe.

cheers,
jamal
--0-1640597484-1041630400=:48623
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="eth_type_trans.fix"
Content-Transfer-Encoding: BASE64
Content-ID: <20030103164640.K48623@shell.cyberus.ca>
Content-Description: 
Content-Disposition: attachment; filename="eth_type_trans.fix"

LS0tIG5ldC9ldGhlcm5ldC9ldGguYwkyMDAzLzAxLzAzIDE4OjIwOjQ5CTEu
MQ0KKysrIG5ldC9ldGhlcm5ldC9ldGguYwkyMDAzLzAxLzAzIDE4OjIyOjA1
DQpAQCAtMTQ4LDYgKzE0OCwzMCBAQA0KIAlyZXR1cm4gMDsNCiB9DQogDQor
dm9pZCBjaGVja19tY2FzdF9saXN0KHN0cnVjdCBza19idWZmICpza2IsIHN0
cnVjdCBuZXRfZGV2aWNlICpkZXYpDQorew0KKwlzdHJ1Y3QgZGV2X21jX2xp
c3QgKmRtaTsNCisJc3RydWN0IGV0aGhkciAqZXRoOw0KKwkJCSAgICAgICAg
DQorCWlmIChza2ItPnBrdF90eXBlICE9IFBBQ0tFVF9PVEhFUkhPU1QpDQor
CQlyZXR1cm47DQorDQorCWV0aCA9IHNrYi0+bWFjLmV0aGVybmV0Ow0KKw0K
KwkvKiBtYXkgbm90IGJlIG5lY2Vzc2FyeSB0byBiaF9sb2NrIC0gZml4IGxh
dGVyIC0gSkhTICovDQorCXNwaW5fbG9ja19iaCgmZGV2LT54bWl0X2xvY2sp
Ow0KKw0KKwlmb3IgKGRtaSA9IGRldi0+bWNfbGlzdDsgZG1pICE9IE5VTEw7
IGRtaSA9IGRtaS0+bmV4dCkgew0KKwkJaWYgKG1lbWNtcChkbWktPmRtaV9h
ZGRyLCBldGgtPmhfZGVzdCwgZGV2LT5hZGRyX2xlbikgPT0gMA0KKwkJICAg
ICYmIGRtaS0+ZG1pX2FkZHJsZW4gPT0gZGV2LT5hZGRyX2xlbikgeyANCisJ
CQlza2ItPnBrdF90eXBlID0gUEFDS0VUX0hPU1Q7DQorCQkJCWJyZWFrOw0K
KwkJfQ0KKwl9DQorDQorCXNwaW5fdW5sb2NrX2JoKCZkZXYtPnhtaXRfbG9j
ayk7DQorfQ0KKw0KIA0KIC8qDQogICoJRGV0ZXJtaW5lIHRoZSBwYWNrZXQn
cyBwcm90b2NvbCBJRC4gVGhlIHJ1bGUgaGVyZSBpcyB0aGF0IHdlIA0KQEAg
LTE4Miw4ICsyMDYsMTQgQEANCiAJIA0KIAllbHNlIGlmKDEgLypkZXYtPmZs
YWdzJklGRl9QUk9NSVNDKi8pDQogCXsNCi0JCWlmKG1lbWNtcChldGgtPmhf
ZGVzdCxkZXYtPmRldl9hZGRyLCBFVEhfQUxFTikpDQotCQkJc2tiLT5wa3Rf
dHlwZT1QQUNLRVRfT1RIRVJIT1NUOw0KKwkJaWYobWVtY21wKGV0aC0+aF9k
ZXN0LGRldi0+ZGV2X2FkZHIsIEVUSF9BTEVOKSkgew0KKwkJCXNrYi0+cGt0
X3R5cGUgPSBQQUNLRVRfT1RIRVJIT1NUOw0KKwkJCS8qIHdlIG92ZXJyaWRl
IFBBQ0tFVF9PVEhFUkhPU1QgaWYgTUFDIGFwcGVhcnMNCisJCQkgKiBpbiBv
dXIgbWNhc3QgbGlzdCBhbGxvd3MgdG8gaGF2ZSBzZXZlcmFsIA0KKwkJCSAq
IGFsbG93ZWQgTUFDcyBmb3IgcmVjZWl2ZXMgYWRkZWQgdmlhIA0KKwkJCSAq
IFNJT0NBRERNVUxUSSBvbiB0aGUgZGV2aWNlKi8NCisJCQljaGVja19tY2Fz
dF9saXN0KHNrYixkZXYpOw0KKwkJfQ0KIAl9DQogCQ0KIAlpZiAobnRvaHMo
ZXRoLT5oX3Byb3RvKSA+PSAxNTM2KQ0K

--0-1640597484-1041630400=:48623--
