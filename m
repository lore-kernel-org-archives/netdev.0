From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: [Bug 9750] [patch 2.6.25 v2] dev: avoid a race that triggers assertion failure
Date: Tue, 12 Feb 2008 23:06:41 -0800 (PST)
Message-ID: <127401.85852.qm@web52006.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-1239753522-1202886401=:85852"
To: bugme-daemon@bugzilla.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52006.mail.re2.yahoo.com ([206.190.49.253]:44200 "HELO
	web52006.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751824AbYBMHGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 02:06:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0-1239753522-1202886401=:85852
Content-Type: text/plain; charset=us-ascii

From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

There is a race in Linux kernel file net/core/dev.c, function dev_close.
The function calls function dev_deactivate, which calls function
dev_watchdog_down that deletes the watchdog timer. However, after that, a
driver can call netif_carrier_ok, which calls function
__netdev_watchdog_up that can add the watchdog timer again. Function
unregister_netdevice calls function dev_shutdown that traps the bug
!timer_pending(&dev->watchdog_timer). Moving dev_deactivate after
netif_running() has been cleared prevents function netif_carrier_on
from calling __netdev_watchdog_up and adding the watchdog timer again.

Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

---





      ____________________________________________________________________________________
Never miss a thing.  Make Yahoo your home page. 
http://www.yahoo.com/r/hs
--0-1239753522-1202886401=:85852
Content-Type: application/octet-stream; name="=?utf-8?q?patch?="
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="=?utf-8?q?patch?="

RnJvbTogTWF0dGkgTGlubmFudnVvcmkgPG1hdHRpbGlubmFudnVvcmlAeWFo
b28uY29tPgoKVGhlcmUgaXMgYSByYWNlIGluIExpbnV4IGtlcm5lbCBmaWxl
IG5ldC9jb3JlL2Rldi5jLCBmdW5jdGlvbiBkZXZfY2xvc2UuClRoZSBmdW5j
dGlvbiBjYWxscyBmdW5jdGlvbiBkZXZfZGVhY3RpdmF0ZSwgd2hpY2ggY2Fs
bHMgZnVuY3Rpb24KZGV2X3dhdGNoZG9nX2Rvd24gdGhhdCBkZWxldGVzIHRo
ZSB3YXRjaGRvZyB0aW1lci4gSG93ZXZlciwgYWZ0ZXIgdGhhdCwgYQpkcml2
ZXIgY2FuIGNhbGwgbmV0aWZfY2Fycmllcl9vaywgd2hpY2ggY2FsbHMgZnVu
Y3Rpb24KX19uZXRkZXZfd2F0Y2hkb2dfdXAgdGhhdCBjYW4gYWRkIHRoZSB3
YXRjaGRvZyB0aW1lciBhZ2Fpbi4gRnVuY3Rpb24KdW5yZWdpc3Rlcl9uZXRk
ZXZpY2UgY2FsbHMgZnVuY3Rpb24gZGV2X3NodXRkb3duIHRoYXQgdHJhcHMg
dGhlIGJ1ZwohdGltZXJfcGVuZGluZygmZGV2LT53YXRjaGRvZ190aW1lciku
IE1vdmluZyBkZXZfZGVhY3RpdmF0ZSBhZnRlcgpuZXRpZl9ydW5uaW5nKCkg
aGFzIGJlZW4gY2xlYXJlZCBwcmV2ZW50cyBmdW5jdGlvbiBuZXRpZl9jYXJy
aWVyX29uCmZyb20gY2FsbGluZyBfX25ldGRldl93YXRjaGRvZ191cCBhbmQg
YWRkaW5nIHRoZSB3YXRjaGRvZyB0aW1lciBhZ2Fpbi4KClNpZ25lZC1vZmYt
Ynk6IE1hdHRpIExpbm5hbnZ1b3JpIDxtYXR0aWxpbm5hbnZ1b3JpQHlhaG9v
LmNvbT4KCi0tLQoKLS0tIGxpbnV4LTIuNi4yNS9uZXQvY29yZS9kZXYuYwky
MDA4LTAyLTEyIDEyOjM3OjUxLjIwNjgzMzAwMCArMDIwMAorKysgYi9uZXQv
Y29yZS9kZXYuYwkyMDA4LTAyLTEzIDA5OjAxOjI1LjY5NzU5MjkwMCArMDIw
MApAQCAtMTA3MSw4ICsxMDcxLDYgQEAgaW50IGRldl9jbG9zZShzdHJ1Y3Qg
bmV0X2RldmljZSAqZGV2KQogCSAqLwogCWNhbGxfbmV0ZGV2aWNlX25vdGlm
aWVycyhORVRERVZfR09JTkdfRE9XTiwgZGV2KTsKIAotCWRldl9kZWFjdGl2
YXRlKGRldik7Ci0KIAljbGVhcl9iaXQoX19MSU5LX1NUQVRFX1NUQVJULCAm
ZGV2LT5zdGF0ZSk7CiAKIAkvKiBTeW5jaHJvbml6ZSB0byBzY2hlZHVsZWQg
cG9sbC4gV2UgY2Fubm90IHRvdWNoIHBvbGwgbGlzdCwKQEAgLTEwODMsNiAr
MTA4MSw4IEBAIGludCBkZXZfY2xvc2Uoc3RydWN0IG5ldF9kZXZpY2UgKmRl
dikKIAkgKi8KIAlzbXBfbWJfX2FmdGVyX2NsZWFyX2JpdCgpOyAvKiBDb21t
aXQgbmV0aWZfcnVubmluZygpLiAqLwogCisJZGV2X2RlYWN0aXZhdGUoZGV2
KTsKKwogCS8qCiAJICoJQ2FsbCB0aGUgZGV2aWNlIHNwZWNpZmljIGNsb3Nl
LiBUaGlzIGNhbm5vdCBmYWlsLgogCSAqCU9ubHkgaWYgZGV2aWNlIGlzIFVQ
Cg==

--0-1239753522-1202886401=:85852--
