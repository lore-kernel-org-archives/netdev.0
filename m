From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/9] net: bcmgenet: use the new fixed PHY helpers
Date: Mon, 19 May 2014 17:56:18 -0700
Message-ID: <1400547384-11363-4-git-send-email-f.fainelli@gmail.com>
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
b20+Ci0tLQogZHJpdmVycy9uZXQvZXRoZXJuZXQvYnJvYWRjb20vZ2VuZXQvYmNtbWlpLmMgfCAy
MSArKysrKysrKysrKysrLS0tLS0tLS0KIDEgZmlsZSBjaGFuZ2VkLCAxMyBpbnNlcnRpb25zKCsp
LCA4IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2Jyb2Fk
Y29tL2dlbmV0L2JjbW1paS5jIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvYnJvYWRjb20vZ2VuZXQv
YmNtbWlpLmMKaW5kZXggNDYwODY3M2JlYWZmLi5hZGQ4ZDg1OTYwODQgMTAwNjQ0Ci0tLSBhL2Ry
aXZlcnMvbmV0L2V0aGVybmV0L2Jyb2FkY29tL2dlbmV0L2JjbW1paS5jCisrKyBiL2RyaXZlcnMv
bmV0L2V0aGVybmV0L2Jyb2FkY29tL2dlbmV0L2JjbW1paS5jCkBAIC0yOTgsNiArMjk4LDcgQEAg
aW50IGJjbWdlbmV0X21paV9jb25maWcoc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIHN0YXRpYyBp
bnQgYmNtZ2VuZXRfbWlpX3Byb2JlKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpCiB7CiAJc3RydWN0
IGJjbWdlbmV0X3ByaXYgKnByaXYgPSBuZXRkZXZfcHJpdihkZXYpOworCXN0cnVjdCBkZXZpY2Vf
bm9kZSAqZG4gPSBwcml2LT5wZGV2LT5kZXYub2Zfbm9kZTsKIAlzdHJ1Y3QgcGh5X2RldmljZSAq
cGh5ZGV2OwogCXVuc2lnbmVkIGludCBwaHlfZmxhZ3M7CiAJaW50IHJldDsKQEAgLTMwNywxNSAr
MzA4LDE5IEBAIHN0YXRpYyBpbnQgYmNtZ2VuZXRfbWlpX3Byb2JlKHN0cnVjdCBuZXRfZGV2aWNl
ICpkZXYpCiAJCXJldHVybiAwOwogCX0KIAotCWlmIChwcml2LT5waHlfZG4pCi0JCXBoeWRldiA9
IG9mX3BoeV9jb25uZWN0KGRldiwgcHJpdi0+cGh5X2RuLAotCQkJCQliY21nZW5ldF9taWlfc2V0
dXAsIDAsCi0JCQkJCXByaXYtPnBoeV9pbnRlcmZhY2UpOwotCWVsc2UKLQkJcGh5ZGV2ID0gb2Zf
cGh5X2Nvbm5lY3RfZml4ZWRfbGluayhkZXYsCi0JCQkJCWJjbWdlbmV0X21paV9zZXR1cCwKLQkJ
CQkJcHJpdi0+cGh5X2ludGVyZmFjZSk7CisJLyogSW4gdGhlIGNhc2Ugb2YgYSBmaXhlZCBQSFks
IHRoZSBEVCBub2RlIGFzc29jaWF0ZWQKKwkgKiB0byB0aGUgUEhZIGlzIHRoZSBFdGhlcm5ldCBN
QUMgRFQgbm9kZS4KKwkgKi8KKwlpZiAob2ZfcGh5X2lzX2ZpeGVkX2xpbmsoZG4pKSB7CisJCXJl
dCA9IG9mX3BoeV9yZWdpc3Rlcl9maXhlZF9saW5rKGRuKTsKKwkJaWYgKHJldCkKKwkJCXJldHVy
biByZXQ7CisKKwkJcHJpdi0+cGh5X2RuID0gZG47CisJfQogCisJcGh5ZGV2ID0gb2ZfcGh5X2Nv
bm5lY3QoZGV2LCBwcml2LT5waHlfZG4sIGJjbWdlbmV0X21paV9zZXR1cCwgMCwKKwkJCQlwcml2
LT5waHlfaW50ZXJmYWNlKTsKIAlpZiAoIXBoeWRldikgewogCQlwcl9lcnIoImNvdWxkIG5vdCBh
dHRhY2ggdG8gUEhZXG4iKTsKIAkJcmV0dXJuIC1FTk9ERVY7Ci0tIAoxLjkuMQoKX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMtZGV2IG1haWxp
bmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xpc3RzLm96bGFi
cy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2
