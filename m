From: Julian Anastasov <ja@ssi.bg>
Subject: [2.4/2.6] ip_nat_ftp - manip at the right place
Date: Sat, 17 Apr 2004 16:26:09 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404171549360.3263@u.domain.uli>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607745702-453966119-1082208369=:3263"
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: coreteam@netfilter.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607745702-453966119-1082208369=:3263
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

	The attached patch changes the way the ip_nat_ftp helper
manipulates the packets:

- no manips => no fixup
- check the direction, do manip once and at the same time when the
headers are changed

	This is needed mostly for IPVS setups and I hope we do not
create troubles for other setups or FTP software.

	I'm not sure whether proper locking for 'info' is needed,
may be not. Tested for SNAT, DNAT, passive, active.

Regards

--
Julian Anastasov <ja@ssi.bg>
--1607745702-453966119-1082208369=:3263
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="nat_ftp-1.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0404171626090.3263@u.domain.uli>
Content-Description: ip_nat_ftp - change manip
Content-Disposition: attachment; filename="nat_ftp-1.diff"

LS0tIHYyLjYuNS9saW51eC9uZXQvaXB2NC9uZXRmaWx0ZXIvaXBfbmF0X2Z0
cC5jCTIwMDQtMDItMTkgMDA6MTM6MzguMDAwMDAwMDAwICswMjAwDQorKysg
bGludXgvbmV0L2lwdjQvbmV0ZmlsdGVyL2lwX25hdF9mdHAuYwkyMDA0LTA0
LTE3IDExOjQ0OjE0LjQ3MTA3NDY4OCArMDMwMA0KQEAgLTI1MCwxNyArMjUw
LDIzIEBADQogCXVuc2lnbmVkIGludCBkYXRhbGVuOw0KIAlpbnQgZGlyOw0K
IAlzdHJ1Y3QgaXBfY3RfZnRwX2V4cGVjdCAqY3RfZnRwX2luZm87DQorCWlu
dCBpLCBkb19tYW5pcCA9IDA7DQogDQogCWlmICghZXhwKQ0KIAkJREVCVUdQ
KCJpcF9uYXRfZnRwOiBubyBleHAhISIpOw0KIA0KIAljdF9mdHBfaW5mbyA9
ICZleHAtPmhlbHAuZXhwX2Z0cF9pbmZvOw0KIA0KLQkvKiBPbmx5IG1hbmds
ZSB0aGluZ3Mgb25jZTogb3JpZ2luYWwgZGlyZWN0aW9uIGluIFBPU1RfUk9V
VElORw0KLQkgICBhbmQgcmVwbHkgZGlyZWN0aW9uIG9uIFBSRV9ST1VUSU5H
LiAqLw0KKwkvKiBPbmx5IG1hbmdsZSB0aGluZ3Mgb25jZTogZm9yIHRoZSBm
aXJzdCBtYW5pcCBpbiB0aGlzIGRpcmVjdGlvbi4gKi8NCiAJZGlyID0gQ1RJ
TkZPMkRJUihjdGluZm8pOw0KLQlpZiAoISgoaG9va251bSA9PSBORl9JUF9Q
T1NUX1JPVVRJTkcgJiYgZGlyID09IElQX0NUX0RJUl9PUklHSU5BTCkNCi0J
ICAgICAgfHwgKGhvb2tudW0gPT0gTkZfSVBfUFJFX1JPVVRJTkcgJiYgZGly
ID09IElQX0NUX0RJUl9SRVBMWSkpKSB7DQorCWZvciAoaSA9IDA7IGkgPCBp
bmZvLT5udW1fbWFuaXBzOyBpKyspIHsNCisJCWlmIChpbmZvLT5tYW5pcHNb
aV0uZGlyZWN0aW9uID09IGRpcikgew0KKwkJCWlmIChpbmZvLT5tYW5pcHNb
aV0uaG9va251bSA9PSBob29rbnVtKQ0KKwkJCQlkb19tYW5pcCA9IDE7DQor
CQkJYnJlYWs7DQorCQl9DQorCX0NCisJaWYgKCFkb19tYW5pcCkgew0KIAkJ
REVCVUdQKCJuYXRfZnRwOiBOb3QgdG91Y2hpbmcgZGlyICVzIGF0IGhvb2sg
JXNcbiIsDQogCQkgICAgICAgZGlyID09IElQX0NUX0RJUl9PUklHSU5BTCA/
ICJPUklHIiA6ICJSRVBMWSIsDQogCQkgICAgICAgaG9va251bSA9PSBORl9J
UF9QT1NUX1JPVVRJTkcgPyAiUE9TVFJPVVRJTkciDQo=

--1607745702-453966119-1082208369=:3263--
