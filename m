From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Sun, 26 Sep 2004 09:15:58 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0409260857510.1151@u.domain.uli>
References: <Pine.LNX.4.58.0409252249150.1175@u.domain.uli>
 <20040925201425.16fbcb6c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607745702-509301932-1096179358=:1151"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040925201425.16fbcb6c.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607745702-509301932-1096179358=:1151
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

On Sat, 25 Sep 2004, David S. Miller wrote:

> 2) The fib_alias list is not meant at all to be sorted by TOS
>    value. Within a TOS it _is_ sorted by priority.  This was
>    intentional, and I believe your changes assume I meant to
>    keep the "aliases ordered by TOS" property.  I did not.

	But it still needs one exception: the entries with TOS 0
must be at tail to allow fn_hash_lookup to match by TOS. With
random TOS insertion this is not guaranteed, the entries with
TOS=0 (wildcard) will match before the others.

	So, I fixed it to allow the TOS subchains to be
in any order but always before the subchain with TOS 0.

> Please give test cases when posting fixes of this nature.
> I wouldn't have to guess about #2 if you gave a bunch of
> "ip route foo" commands that gave behavior you think is
> incorrect.

	ok, I'm attaching 3 files: new diff, test script to add/del
entries in custom table and its output in another file (after
applying the patch). I'm using:

./rt.sh start
./rt.sh stop

Regards

--
Julian Anastasov <ja@ssi.bg>
--1607745702-509301932-1096179358=:1151
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="fib_ins2.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0409260915580.1151@u.domain.uli>
Content-Description: fib_alias insertion fixes
Content-Disposition: attachment; filename="fib_ins2.diff"

ZGlmZiAtdXIgdjIuNi45LXJjMi1iazEwL2xpbnV4L25ldC9pcHY0L2ZpYl9o
YXNoLmMgbGludXgvbmV0L2lwdjQvZmliX2hhc2guYw0KLS0tIHYyLjYuOS1y
YzItYmsxMC9saW51eC9uZXQvaXB2NC9maWJfaGFzaC5jCTIwMDQtMDktMjYg
MDg6NTY6MTkuMDAwMDAwMDAwICswMzAwDQorKysgbGludXgvbmV0L2lwdjQv
ZmliX2hhc2guYwkyMDA0LTA5LTI2IDA4OjU2OjMzLjMxMzc3MDM0NCArMDMw
MA0KQEAgLTQzMyw2ICs0MzMsNyBAQA0KIA0KIC8qIFJldHVybiB0aGUgZmly
c3QgZmliIGFsaWFzIG1hdGNoaW5nIFRPUyB3aXRoDQogICogcHJpb3JpdHkg
bGVzcyB0aGFuIG9yIGVxdWFsIHRvIFBSSU8uDQorICogQWxzbywgY29udHJv
bCB0aGUgb3JkZXJpbmcgYnkgVE9TOiBrZWVwIHRoZSBlbnRyaWVzIHdpdGgg
VE9TPTAgYXQgdGFpbC4NCiAgKi8NCiBzdGF0aWMgc3RydWN0IGZpYl9hbGlh
cyAqZmliX2ZpbmRfYWxpYXMoc3RydWN0IGZpYl9ub2RlICpmbiwgdTggdG9z
LCB1MzIgcHJpbykNCiB7DQpAQCAtNDQzLDEyICs0NDQsMTYgQEANCiAJCXBy
ZXZfZmEgPSBOVUxMOw0KIAkJbGlzdF9mb3JfZWFjaF9lbnRyeShmYSwgaGVh
ZCwgZmFfbGlzdCkgew0KIAkJCWlmIChmYS0+ZmFfdG9zICE9IHRvcykNCi0J
CQkJY29udGludWU7DQorCQkJew0KKwkJCQlpZiAoIXByZXZfZmEgJiYgZmEt
PmZhX3RvcykNCisJCQkJCWNvbnRpbnVlOw0KKwkJCQkvKiBTdG9wIGF0IFRP
UyAwIG9yIGFmdGVyIGVudHJpZXMgZnJvbSBvdXIgVE9TICovDQorCQkJCXJl
dHVybiBmYTsNCisJCQl9DQogCQkJcHJldl9mYSA9IGZhOw0KIAkJCWlmIChw
cmlvIDw9IGZhLT5mYV9pbmZvLT5maWJfcHJpb3JpdHkpDQotCQkJCWJyZWFr
Ow0KKwkJCQlyZXR1cm4gZmE7DQogCQl9DQotCQlyZXR1cm4gcHJldl9mYTsN
CiAJfQ0KIAlyZXR1cm4gTlVMTDsNCiB9DQpAQCAtNTA1LDcgKzUxMCw3IEBA
DQogCSAqIGFuZCB3ZSBuZWVkIHRvIGFsbG9jYXRlIGEgbmV3IG9uZSBvZiB0
aG9zZSBhcyB3ZWxsLg0KIAkgKi8NCiANCi0JaWYgKGZhICYmDQorCWlmIChm
YSAmJiBmYS0+ZmFfdG9zID09IHRvcyAmJg0KIAkgICAgZmEtPmZhX2luZm8t
PmZpYl9wcmlvcml0eSA9PSBmaS0+ZmliX3ByaW9yaXR5KSB7DQogCQlzdHJ1
Y3QgZmliX2FsaWFzICpmYV9vcmlnOw0KIA0KQEAgLTU4Niw3ICs1OTEsNyBA
QA0KIAl3cml0ZV9sb2NrX2JoKCZmaWJfaGFzaF9sb2NrKTsNCiAJaWYgKG5l
d19mKQ0KIAkJZmliX2luc2VydF9ub2RlKGZ6LCBuZXdfZik7DQotCWxpc3Rf
YWRkKCZuZXdfZmEtPmZhX2xpc3QsDQorCWxpc3RfYWRkX3RhaWwoJm5ld19m
YS0+ZmFfbGlzdCwNCiAJCSAoZmEgPyAmZmEtPmZhX2xpc3QgOiAmZi0+Zm5f
YWxpYXMpKTsNCiAJd3JpdGVfdW5sb2NrX2JoKCZmaWJfaGFzaF9sb2NrKTsN
CiANCg==

--1607745702-509301932-1096179358=:1151
Content-Type: APPLICATION/x-sh; name="rt.sh"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0409260915581.1151@u.domain.uli>
Content-Description: test script
Content-Disposition: attachment; filename="rt.sh"

IyEgL2Jpbi9zaAoKdGFibGU9MTAwCmRldj1ldGgwCmtleT0xLjEuMS4xCm5o
MT0idmlhIDE5Mi4xNjguMTU5LjIgZGV2ICRkZXYgdGFibGUgJHRhYmxlIgpu
aDI9InZpYSAxOTIuMTY4LjE1OS4zIGRldiAkZGV2IHRhYmxlICR0YWJsZSIK
aXBhPSJpcCByb3V0ZSBhcHBlbmQgJGtleSIKaXBwPSJpcCByb3V0ZSBwcmVw
ZW5kICRrZXkiCmlwZD0iaXAgcm91dGUgZGVsZXRlICRrZXkgdGFibGUgJHRh
YmxlIgoKaWYgWyAiJDEiID0gInN0YXJ0IiBdCnRoZW4KCSMgYXBwZW5kCgkk
aXBhICRuaDEgbWV0cmljIDEKCSRpcGEgJG5oMiBtZXRyaWMgMQoJJGlwYSAk
bmgxCgkkaXBhICRuaDIKCSRpcGEgJG5oMSBtZXRyaWMgMwoJJGlwYSAkbmgx
IG1ldHJpYyA0CgkkaXBhICRuaDIgbWV0cmljIDIKCSRpcGEgJG5oMiBtZXRy
aWMgMwoJJGlwYSAkbmgyIG1ldHJpYyA0CgoJIyBhcHBlbmQgJiB0b3MKCSRp
cGEgJG5oMSBtZXRyaWMgMSB0b3MgMHgxMAoJJGlwYSAkbmgyIG1ldHJpYyAx
IHRvcyAweDIwCgkkaXBhICRuaDIgbWV0cmljIDEgdG9zIDB4MTAKCgkjIHBy
ZXBlbmQKCSRpcHAgJG5oMSBtZXRyaWMgMgoJJGlwcCAkbmgxIG1ldHJpYyAx
IHRvcyAweDIwCmVsc2UKCXdoaWxlICRpcGQ7IGRvIDo7ZG9uZQoJd2hpbGUg
JGlwZCB0b3MgMHgyMDsgZG8gOjtkb25lCgl3aGlsZSAkaXBkIHRvcyAweDEw
OyBkbyA6O2RvbmUKZmkKCg==

--1607745702-509301932-1096179358=:1151
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="rt.out"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0409260915582.1151@u.domain.uli>
Content-Description: the desired output
Content-Disposition: attachment; filename="rt.out"

MS4xLjEuMSB0b3MgMHgxMCB2aWEgMTkyLjE2OC4xNTkuMiBkZXYgZXRoMCAg
bWV0cmljIDEgDQoxLjEuMS4xIHRvcyAweDEwIHZpYSAxOTIuMTY4LjE1OS4z
IGRldiBldGgwICBtZXRyaWMgMSANCjEuMS4xLjEgdG9zIDB4MjAgdmlhIDE5
Mi4xNjguMTU5LjIgZGV2IGV0aDAgIG1ldHJpYyAxIA0KMS4xLjEuMSB0b3Mg
MHgyMCB2aWEgMTkyLjE2OC4xNTkuMyBkZXYgZXRoMCAgbWV0cmljIDEgDQox
LjEuMS4xIHZpYSAxOTIuMTY4LjE1OS4yIGRldiBldGgwIA0KMS4xLjEuMSB2
aWEgMTkyLjE2OC4xNTkuMyBkZXYgZXRoMCANCjEuMS4xLjEgdmlhIDE5Mi4x
NjguMTU5LjIgZGV2IGV0aDAgIG1ldHJpYyAxIA0KMS4xLjEuMSB2aWEgMTky
LjE2OC4xNTkuMyBkZXYgZXRoMCAgbWV0cmljIDEgDQoxLjEuMS4xIHZpYSAx
OTIuMTY4LjE1OS4yIGRldiBldGgwICBtZXRyaWMgMiANCjEuMS4xLjEgdmlh
IDE5Mi4xNjguMTU5LjMgZGV2IGV0aDAgIG1ldHJpYyAyIA0KMS4xLjEuMSB2
aWEgMTkyLjE2OC4xNTkuMiBkZXYgZXRoMCAgbWV0cmljIDMgDQoxLjEuMS4x
IHZpYSAxOTIuMTY4LjE1OS4zIGRldiBldGgwICBtZXRyaWMgMyANCjEuMS4x
LjEgdmlhIDE5Mi4xNjguMTU5LjIgZGV2IGV0aDAgIG1ldHJpYyA0IA0KMS4x
LjEuMSB2aWEgMTkyLjE2OC4xNTkuMyBkZXYgZXRoMCAgbWV0cmljIDQgDQo=

--1607745702-509301932-1096179358=:1151--
