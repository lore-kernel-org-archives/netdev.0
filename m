From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 7/9] ucc_geth: use the new fixed PHY helpers
Date: Mon, 19 May 2014 17:56:22 -0700
Message-ID: <1400547384-11363-8-git-send-email-f.fainelli@gmail.com>
References: <1400547384-11363-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Mark Rutland <mark.rutland@arm.com>,
 "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
 Paul Mackerras <paulus@samba.org>, Florian Fainelli <f.fainelli@gmail.com>,
 Claudiu Manoil <claudiu.manoil@freescale.com>,
 Grant Likely <grant.likely@linaro.org>,
 "open list:OPEN FIRMWARE AND..." <devicetree@vger.kernel.org>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Richard Cochran <richardcochran@gmail.com>, Rob Herring <robh+dt@kernel.org>,
 Aida Mynzhasova <aida.mynzhasova@skitlab.ru>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 Randy Dunlap <rdunlap@infradead.org>, open list <linux-kernel@vger.kernel.org>,
 davem@davemlof.net, Vitaly Bordug <vbordug@ru.mvista.com>,
 Kumar Gala <galak@codeaurora.org>,
 "open list:LINUX FOR POWERPC..." <linuxppc-dev@lists.ozlabs.org>,
 "David S.
To: netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1400547384-11363-1-git-send-email-f.fainelli@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

b2ZfcGh5X2Nvbm5lY3RfZml4ZWRfbGluaygpIGlzIGJlY29taW5nIG9ic29sZXRlLCBhbmQgYWxz
byByZXF1aXJlZApwbGF0Zm9ybSBjb2RlIHRvIHJlZ2lzdGVyIHRoZSBmaXhlZCBQSFlzIGF0IHRo
ZSBzcGVjaWZpZWQgYWRkcmVzc2VzIGZvcgp0aG9zZSB0byBiZSB1c2FibGUuIEdldCByaWQgb2Yg
aXQgYW5kIHVzZSB0aGUgbmV3IG9mX3BoeV9pc19maXhlZF9saW5rKCkKcGx1cyBvZl9waHlfcmVn
aXN0ZXJfZml4ZWRfbGluaygpIGhlbHBlcnMgdG8gdHJhbnNpdGlvbiBvdmVyIHRoZSBuZXcKc2No
ZW1lLgoKU2lnbmVkLW9mZi1ieTogRmxvcmlhbiBGYWluZWxsaSA8Zi5mYWluZWxsaUBnbWFpbC5j
b20+Ci0tLQogZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL3VjY19nZXRoLmMgfCAxNCAr
KysrKysrKysrKy0tLQogMSBmaWxlIGNoYW5nZWQsIDExIGluc2VydGlvbnMoKyksIDMgZGVsZXRp
b25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL3VjY19n
ZXRoLmMgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUvdWNjX2dldGguYwppbmRleCBj
ODI5OWMzMWIyMWYuLmZhYjM5ZTI5NTQ0MSAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJu
ZXQvZnJlZXNjYWxlL3VjY19nZXRoLmMKKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNj
YWxlL3VjY19nZXRoLmMKQEAgLTE3MjgsOSArMTcyOCw2IEBAIHN0YXRpYyBpbnQgaW5pdF9waHko
c3RydWN0IG5ldF9kZXZpY2UgKmRldikKIAogCXBoeWRldiA9IG9mX3BoeV9jb25uZWN0KGRldiwg
dWdfaW5mby0+cGh5X25vZGUsICZhZGp1c3RfbGluaywgMCwKIAkJCQlwcml2LT5waHlfaW50ZXJm
YWNlKTsKLQlpZiAoIXBoeWRldikKLQkJcGh5ZGV2ID0gb2ZfcGh5X2Nvbm5lY3RfZml4ZWRfbGlu
ayhkZXYsICZhZGp1c3RfbGluaywKLQkJCQkJCSAgIHByaXYtPnBoeV9pbnRlcmZhY2UpOwogCWlm
ICghcGh5ZGV2KSB7CiAJCWRldl9lcnIoJmRldi0+ZGV2LCAiQ291bGQgbm90IGF0dGFjaCB0byBQ
SFlcbiIpOwogCQlyZXR1cm4gLUVOT0RFVjsKQEAgLTM3OTAsNiArMzc4NywxNyBAQCBzdGF0aWMg
aW50IHVjY19nZXRoX3Byb2JlKHN0cnVjdCBwbGF0Zm9ybV9kZXZpY2UqIG9mZGV2KQogCXVnX2lu
Zm8tPnVmX2luZm8uaXJxID0gaXJxX29mX3BhcnNlX2FuZF9tYXAobnAsIDApOwogCiAJdWdfaW5m
by0+cGh5X25vZGUgPSBvZl9wYXJzZV9waGFuZGxlKG5wLCAicGh5LWhhbmRsZSIsIDApOworCWlm
ICghdWdfaW5mby0+cGh5X25vZGUpIHsKKwkJLyogSW4gdGhlIGNhc2Ugb2YgYSBmaXhlZCBQSFks
IHRoZSBEVCBub2RlIGFzc29jaWF0ZWQKKwkJICogdG8gdGhlIFBIWSBpcyB0aGUgRXRoZXJuZXQg
TUFDIERUIG5vZGUuCisJCSAqLworCQlpZiAob2ZfcGh5X2lzX2ZpeGVkX2xpbmsobnApKSB7CisJ
CQllcnIgPSBvZl9waHlfcmVnaXN0ZXJfZml4ZWRfbGluayhucCk7CisJCQlpZiAoZXJyKQorCQkJ
CXJldHVybiBlcnI7CisJCX0KKwkJdWdfaW5mby0+cGh5X25vZGUgPSBucDsKKwl9CiAKIAkvKiBG
aW5kIHRoZSBUQkkgUEhZIG5vZGUuICBJZiBpdCdzIG5vdCB0aGVyZSwgd2UgZG9uJ3Qgc3VwcG9y
dCBTR01JSSAqLwogCXVnX2luZm8tPnRiaV9ub2RlID0gb2ZfcGFyc2VfcGhhbmRsZShucCwgInRi
aS1oYW5kbGUiLCAwKTsKLS0gCjEuOS4xCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpMaW51eHBwYy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBs
aXN0cy5vemxhYnMub3JnCmh0dHBzOi8vbGlzdHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBw
Yy1kZXY=
