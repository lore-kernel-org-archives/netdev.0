From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 1/9] net: etherdevice: add address inherit helper
Date: Fri, 30 Aug 2013 18:08:44 +0200
Message-ID: <1377878932-26881-2-git-send-email-bjorn@mork.no>
References: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: devel@driverdev.osuosl.org, Jiri Pirko <jiri@resnulli.us>,
 libertas-dev@lists.infradead.org, Jouni Malinen <j@w1.fi>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 linux-wireless@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>,
 Stephen Hemminger <stephen@networkplumber.org>,
 Forest Bond <forest@alittletooquiet.net>, Patrick McHardy <kaber@trash.net>,
 =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1377878932-26881-1-git-send-email-bjorn@mork.no>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

U29tZSBldGhlcmRldmljZXMgaW5oZXJpdCB0aGVpciBhZGRyZXNzIGZyb20gYSBwYXJlbnQgb3IK
bWFzdGVyIGRldmljZS4gVGhlIGFkZHJfYXNzaWduX3R5cGUgc2hvdWxkIGJlIHVwZGF0ZWQgYWxv
bmcKd2l0aCB0aGUgYWRkcmVzcyBpbiB0aGVzZSBjYXNlcy4gIEFkZGluZyBhIGhlbHBlciBmdW5j
dGlvbgp0byBzaW1wbGlmeSB0aGlzLgoKU2lnbmVkLW9mZi1ieTogQmrDuHJuIE1vcmsgPGJqb3Ju
QG1vcmsubm8+Ci0tLQogaW5jbHVkZS9saW51eC9ldGhlcmRldmljZS5oIHwgICAxNSArKysrKysr
KysrKysrKysKIDEgZmlsZSBjaGFuZ2VkLCAxNSBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEv
aW5jbHVkZS9saW51eC9ldGhlcmRldmljZS5oIGIvaW5jbHVkZS9saW51eC9ldGhlcmRldmljZS5o
CmluZGV4IGM2MjM4NjEuLmQ4YjUxMjQgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvZXRoZXJk
ZXZpY2UuaAorKysgYi9pbmNsdWRlL2xpbnV4L2V0aGVyZGV2aWNlLmgKQEAgLTE5OSw2ICsxOTks
MjEgQEAgc3RhdGljIGlubGluZSB2b2lkIGV0aF9od19hZGRyX3JhbmRvbShzdHJ1Y3QgbmV0X2Rl
dmljZSAqZGV2KQogfQogCiAvKioKKyAqIGV0aF9od19hZGRyX2luaGVyaXQgLSBDb3B5IGRldl9h
ZGRyIGZyb20gYW5vdGhlciBuZXRfZGV2aWNlCisgKiBAZHN0OiBwb2ludGVyIHRvIG5ldF9kZXZp
Y2UgdG8gY29weSBkZXZfYWRkciB0bworICogQHNyYzogcG9pbnRlciB0byBuZXRfZGV2aWNlIHRv
IGNvcHkgZGV2X2FkZHIgZnJvbQorICoKKyAqIENvcHkgdGhlIEV0aGVybmV0IGFkZHJlc3MgZnJv
bSBvbmUgbmV0X2RldmljZSB0byBhbm90aGVyIGFsb25nIHdpdGgKKyAqIHRoZSBhZGRyZXNzIGF0
dHJpYnV0ZXMgKGFkZHJfYXNzaWduX3R5cGUpLgorICovCitzdGF0aWMgaW5saW5lIHZvaWQgZXRo
X2h3X2FkZHJfaW5oZXJpdChzdHJ1Y3QgbmV0X2RldmljZSAqZHN0LAorCQkJCSAgICAgICBzdHJ1
Y3QgbmV0X2RldmljZSAqc3JjKQoreworCWRzdC0+YWRkcl9hc3NpZ25fdHlwZSA9IHNyYy0+YWRk
cl9hc3NpZ25fdHlwZTsKKwltZW1jcHkoZHN0LT5kZXZfYWRkciwgc3JjLT5kZXZfYWRkciwgRVRI
X0FMRU4pOworfQorCisvKioKICAqIGNvbXBhcmVfZXRoZXJfYWRkciAtIENvbXBhcmUgdHdvIEV0
aGVybmV0IGFkZHJlc3NlcwogICogQGFkZHIxOiBQb2ludGVyIHRvIGEgc2l4LWJ5dGUgYXJyYXkg
Y29udGFpbmluZyB0aGUgRXRoZXJuZXQgYWRkcmVzcwogICogQGFkZHIyOiBQb2ludGVyIG90aGVy
IHNpeC1ieXRlIGFycmF5IGNvbnRhaW5pbmcgdGhlIEV0aGVybmV0IGFkZHJlc3MKLS0gCjEuNy4x
MC40CgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXZl
bCBtYWlsaW5nIGxpc3QKZGV2ZWxAbGludXhkcml2ZXJwcm9qZWN0Lm9yZwpodHRwOi8vZHJpdmVy
ZGV2LmxpbnV4ZHJpdmVycHJvamVjdC5vcmcvbWFpbG1hbi9saXN0aW5mby9kcml2ZXJkZXYtZGV2
ZWwK
