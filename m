From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.12-rc5 9/9] tg3: Fix bug in tg3_load_firmware_cpu
Date: Thu, 26 May 2005 11:00:11 -0700
Message-ID: <1117130411.3744.61.camel@rh4>
References: <1117128795.3744.22.camel@rh4>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=-AMuu51w9sS0rynMEQ8qb"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <1117128795.3744.22.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-AMuu51w9sS0rynMEQ8qb
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Add tg3_nvram_lock() and tg3_nvram_unlock() calls around tg3_halt_cpu().
It is possible that the bootcode may be loading code from nvram during
this call and stopping the cpu without getting the lock may cause
uncompleted nvram data to be left in the nvram data register. Subsequent
calls to read/write nvram data will fail.

Signed-off-by: Michael Chan <mchan@broadcom.com>

--=-AMuu51w9sS0rynMEQ8qb
Content-Disposition: attachment;
 filename=tg3-d9.patch
Content-Type: text/x-patch;
 charset=utf-8;
 name=tg3-d9.patch
Content-Transfer-Encoding: base64

ZGlmZiAtTnJ1IGQ4L2RyaXZlcnMvbmV0L3RnMy5jIGQ5L2RyaXZlcnMvbmV0L3RnMy5jDQotLS0g
ZDgvZHJpdmVycy9uZXQvdGczLmMJMjAwNS0wNS0yNSAxMjo1OTo0Ni4wMDAwMDAwMDAgLTA3MDAN
CisrKyBkOS9kcml2ZXJzL25ldC90ZzMuYwkyMDA1LTA1LTI1IDEyOjU5OjU1LjAwMDAwMDAwMCAt
MDcwMA0KQEAgLTQzNzAsNyArNDM3MCwxMiBAQA0KIAkgKi8NCiAJdHAtPnRnM19mbGFncyB8PSBU
RzNfRkxBR19QQ0lYX1RBUkdFVF9IV0JVRzsNCiANCisJLyogSXQgaXMgcG9zc2libGUgdGhhdCBi
b290Y29kZSBpcyBzdGlsbCBsb2FkaW5nIGF0IHRoaXMgcG9pbnQuDQorCSAqIEdldCB0aGUgbnZy
YW0gbG9jayBmaXJzdCBiZWZvcmUgaGFsdGluZyB0aGUgY3B1Lg0KKwkgKi8NCisJdGczX252cmFt
X2xvY2sodHApOw0KIAllcnIgPSB0ZzNfaGFsdF9jcHUodHAsIGNwdV9iYXNlKTsNCisJdGczX252
cmFtX3VubG9jayh0cCk7DQogCWlmIChlcnIpDQogCQlnb3RvIG91dDsNCiANCg==


--=-AMuu51w9sS0rynMEQ8qb--
