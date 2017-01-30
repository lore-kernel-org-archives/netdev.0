From: =?UTF-8?q?Vincent=20Stehl=C3=A9?= <vincent.stehle@laposte.net>
Subject: [PATCH] net: thunderx: avoid dereferencing xcv when NULL
Date: Mon, 30 Jan 2017 15:06:43 +0100
Message-ID: <20170130140643.24182-1-vincent.stehle@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?q?Vincent=20Stehl=C3=A9?= <vincent.stehle@laposte.net>
To: linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

VGhpcyBmaXhlcyB0aGUgZm9sbG93aW5nIHNtYXRjaCBhbmQgY29jY2luZWxsZSB3YXJuaW5nczoK
CiAgZHJpdmVycy9uZXQvZXRoZXJuZXQvY2F2aXVtL3RodW5kZXIvdGh1bmRlcl94Y3YuYzoxMTkg
eGN2X3NldHVwX2xpbmsoKSBlcnJvcjogd2UgcHJldmlvdXNseSBhc3N1bWVkICd4Y3YnIGNvdWxk
IGJlIG51bGwgKHNlZSBsaW5lIDExOCkgW3NtYXRjaF0KICBkcml2ZXJzL25ldC9ldGhlcm5ldC9j
YXZpdW0vdGh1bmRlci90aHVuZGVyX3hjdi5jOjExOToxNi0yMDogRVJST1I6IHhjdiBpcyBOVUxM
IGJ1dCBkZXJlZmVyZW5jZWQuIFtjb2NjaW5lbGxlXQoKRml4ZXM6IDY0NjU4NTlhYmExZTY2YTUg
KCJuZXQ6IHRodW5kZXJ4OiBBZGQgUkdNSUkgaW50ZXJmYWNlIHR5cGUgc3VwcG9ydCIpClNpZ25l
ZC1vZmYtYnk6IFZpbmNlbnQgU3RlaGzDqSA8dmluY2VudC5zdGVobGVAbGFwb3N0ZS5uZXQ+CkNj
OiBTdW5pbCBHb3V0aGFtIDxzZ291dGhhbUBjYXZpdW0uY29tPgotLS0KIGRyaXZlcnMvbmV0L2V0
aGVybmV0L2Nhdml1bS90aHVuZGVyL3RodW5kZXJfeGN2LmMgfCAzICstLQogMSBmaWxlIGNoYW5n
ZWQsIDEgaW5zZXJ0aW9uKCspLCAyIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMv
bmV0L2V0aGVybmV0L2Nhdml1bS90aHVuZGVyL3RodW5kZXJfeGN2LmMgYi9kcml2ZXJzL25ldC9l
dGhlcm5ldC9jYXZpdW0vdGh1bmRlci90aHVuZGVyX3hjdi5jCmluZGV4IDY3YmVmZWRlZjcwOS4u
NTc4YzdmOGYxMWJmIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9jYXZpdW0vdGh1
bmRlci90aHVuZGVyX3hjdi5jCisrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2Nhdml1bS90aHVu
ZGVyL3RodW5kZXJfeGN2LmMKQEAgLTExNiw4ICsxMTYsNyBAQCB2b2lkIHhjdl9zZXR1cF9saW5r
KGJvb2wgbGlua191cCwgaW50IGxpbmtfc3BlZWQpCiAJaW50IHNwZWVkID0gMjsKIAogCWlmICgh
eGN2KSB7Ci0JCWRldl9lcnIoJnhjdi0+cGRldi0+ZGV2LAotCQkJIlhDViBpbml0IG5vdCBkb25l
LCBwcm9iZSBtYXkgaGF2ZSBmYWlsZWRcbiIpOworCQlwcl9lcnIoIlhDViBpbml0IG5vdCBkb25l
LCBwcm9iZSBtYXkgaGF2ZSBmYWlsZWRcbiIpOwogCQlyZXR1cm47CiAJfQogCi0tIAoyLjExLjAK
CgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsaW51eC1h
cm0ta2VybmVsIG1haWxpbmcgbGlzdApsaW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5v
cmcKaHR0cDovL2xpc3RzLmluZnJhZGVhZC5vcmcvbWFpbG1hbi9saXN0aW5mby9saW51eC1hcm0t
a2VybmVsCg==
