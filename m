From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/9] fs_enet: use the new fixed PHY helpers
Date: Mon, 19 May 2014 17:56:20 -0700
Message-ID: <1400547384-11363-6-git-send-email-f.fainelli@gmail.com>
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
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1400547384-11363-1-git-send-email-f.fainelli@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

b2ZfcGh5X2Nvbm5lY3RfZml4ZWRfbGluaygpIGlzIGJlY29taW5nIG9ic29sZXRlLCBhbmQgYWxz
byByZXF1aXJlZApwbGF0Zm9ybSBjb2RlIHRvIHJlZ2lzdGVyIHRoZSBmaXhlZCBQSFlzIGF0IHRo
ZSBzcGVjaWZpZWQgYWRkcmVzc2VzIGZvcgp0aG9zZSB0byBiZSB1c2FibGUuIEdldCByaWQgb2Yg
aXQgYW5kIHVzZSB0aGUgbmV3IG9mX3BoeV9pc19maXhlZF9saW5rKCkKcGx1cyBvZl9waHlfcmVn
aXN0ZXJfZml4ZWRfbGluaygpIGhlbHBlcnMgdG8gdHJhbnNpdGlvbiBvdmVyIHRoZSBuZXcKc2No
ZW1lLgoKU2lnbmVkLW9mZi1ieTogRmxvcmlhbiBGYWluZWxsaSA8Zi5mYWluZWxsaUBnbWFpbC5j
b20+Ci0tLQogZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZzX2VuZXQvZnNfZW5ldC1t
YWluLmMgfCAxNiArKysrKysrKystLS0tLS0tCiAxIGZpbGUgY2hhbmdlZCwgOSBpbnNlcnRpb25z
KCspLCA3IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2Zy
ZWVzY2FsZS9mc19lbmV0L2ZzX2VuZXQtbWFpbi5jIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJl
ZXNjYWxlL2ZzX2VuZXQvZnNfZW5ldC1tYWluLmMKaW5kZXggZGM4MGRiNDFkNmIzLi5kNjAyNzEx
ZTAwZTkgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9mc19lbmV0
L2ZzX2VuZXQtbWFpbi5jCisrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9mc19l
bmV0L2ZzX2VuZXQtbWFpbi5jCkBAIC03OTIsMTAgKzc5Miw2IEBAIHN0YXRpYyBpbnQgZnNfaW5p
dF9waHkoc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIAlwaHlkZXYgPSBvZl9waHlfY29ubmVjdChk
ZXYsIGZlcC0+ZnBpLT5waHlfbm9kZSwgJmZzX2FkanVzdF9saW5rLCAwLAogCQkJCWlmYWNlKTsK
IAlpZiAoIXBoeWRldikgewotCQlwaHlkZXYgPSBvZl9waHlfY29ubmVjdF9maXhlZF9saW5rKGRl
diwgJmZzX2FkanVzdF9saW5rLAotCQkJCQkJICAgaWZhY2UpOwotCX0KLQlpZiAoIXBoeWRldikg
ewogCQlkZXZfZXJyKCZkZXYtPmRldiwgIkNvdWxkIG5vdCBhdHRhY2ggdG8gUEhZXG4iKTsKIAkJ
cmV0dXJuIC1FTk9ERVY7CiAJfQpAQCAtMTAyOSw5ICsxMDI1LDE1IEBAIHN0YXRpYyBpbnQgZnNf
ZW5ldF9wcm9iZShzdHJ1Y3QgcGxhdGZvcm1fZGV2aWNlICpvZmRldikKIAlmcGktPnVzZV9uYXBp
ID0gMTsKIAlmcGktPm5hcGlfd2VpZ2h0ID0gMTc7CiAJZnBpLT5waHlfbm9kZSA9IG9mX3BhcnNl
X3BoYW5kbGUob2ZkZXYtPmRldi5vZl9ub2RlLCAicGh5LWhhbmRsZSIsIDApOwotCWlmICgoIWZw
aS0+cGh5X25vZGUpICYmICghb2ZfZ2V0X3Byb3BlcnR5KG9mZGV2LT5kZXYub2Zfbm9kZSwgImZp
eGVkLWxpbmsiLAotCQkJCQkJICBOVUxMKSkpCi0JCWdvdG8gb3V0X2ZyZWVfZnBpOworCWlmICgh
ZnBpLT5waHlfbm9kZSkgeworCQlpZiAob2ZfcGh5X2lzX2ZpeGVkX2xpbmsob2ZkZXYtPmRldi5v
Zl9ub2RlKSkgeworCQkJZXJyID0gb2ZfcGh5X3JlZ2lzdGVyX2ZpeGVkX2xpbmsob2ZkZXYtPmRl
di5vZl9ub2RlKTsKKwkJCWlmIChlcnIpCisJCQkJZ290byBvdXRfZnJlZV9mcGk7CisKKwkJCWZw
aS0+cGh5X25vZGUgPSBvZmRldi0+ZGV2Lm9mX25vZGU7CisJCX0KKwl9CiAKIAlpZiAob2ZfZGV2
aWNlX2lzX2NvbXBhdGlibGUob2ZkZXYtPmRldi5vZl9ub2RlLCAiZnNsLG1wYzUxMjUtZmVjIikp
IHsKIAkJcGh5X2Nvbm5lY3Rpb25fdHlwZSA9IG9mX2dldF9wcm9wZXJ0eShvZmRldi0+ZGV2Lm9m
X25vZGUsCi0tIAoxLjkuMQoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX18KTGludXhwcGMtZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3ps
YWJzLm9yZwpodHRwczovL2xpc3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2
