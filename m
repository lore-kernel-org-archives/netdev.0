From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/9] gianfar: use the new fixed PHY helpers
Date: Mon, 19 May 2014 17:56:21 -0700
Message-ID: <1400547384-11363-7-git-send-email-f.fainelli@gmail.com>
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
b20+Ci0tLQogZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2dpYW5mYXIuYyB8IDE0ICsr
KysrKysrKysrLS0tCiAxIGZpbGUgY2hhbmdlZCwgMTEgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlv
bnMoLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUvZ2lhbmZh
ci5jIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2dpYW5mYXIuYwppbmRleCBlMmQ0
MjQ3NWIwMDYuLjI4MjY3NDAyN2M5MiAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQv
ZnJlZXNjYWxlL2dpYW5mYXIuYworKysgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUv
Z2lhbmZhci5jCkBAIC04ODksNiArODg5LDE3IEBAIHN0YXRpYyBpbnQgZ2Zhcl9vZl9pbml0KHN0
cnVjdCBwbGF0Zm9ybV9kZXZpY2UgKm9mZGV2LCBzdHJ1Y3QgbmV0X2RldmljZSAqKnBkZXYpCiAK
IAlwcml2LT5waHlfbm9kZSA9IG9mX3BhcnNlX3BoYW5kbGUobnAsICJwaHktaGFuZGxlIiwgMCk7
CiAKKwkvKiBJbiB0aGUgY2FzZSBvZiBhIGZpeGVkIFBIWSwgdGhlIERUIG5vZGUgYXNzb2NpYXRl
ZAorCSAqIHRvIHRoZSBQSFkgaXMgdGhlIEV0aGVybmV0IE1BQyBEVCBub2RlLgorCSAqLworCWlm
IChvZl9waHlfaXNfZml4ZWRfbGluayhucCkpIHsKKwkJZXJyID0gb2ZfcGh5X3JlZ2lzdGVyX2Zp
eGVkX2xpbmsobnApOworCQlpZiAoZXJyKQorCQkJZ290byBlcnJfZ3JwX2luaXQ7CisKKwkJcHJp
di0+cGh5X25vZGUgPSBucDsKKwl9CisKIAkvKiBGaW5kIHRoZSBUQkkgUEhZLiAgSWYgaXQncyBu
b3QgdGhlcmUsIHdlIGRvbid0IHN1cHBvcnQgU0dNSUkgKi8KIAlwcml2LT50Ymlfbm9kZSA9IG9m
X3BhcnNlX3BoYW5kbGUobnAsICJ0YmktaGFuZGxlIiwgMCk7CiAKQEAgLTE2NjAsOSArMTY3MSw2
IEBAIHN0YXRpYyBpbnQgaW5pdF9waHkoc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIAogCXByaXYt
PnBoeWRldiA9IG9mX3BoeV9jb25uZWN0KGRldiwgcHJpdi0+cGh5X25vZGUsICZhZGp1c3RfbGlu
aywgMCwKIAkJCQkgICAgICBpbnRlcmZhY2UpOwotCWlmICghcHJpdi0+cGh5ZGV2KQotCQlwcml2
LT5waHlkZXYgPSBvZl9waHlfY29ubmVjdF9maXhlZF9saW5rKGRldiwgJmFkanVzdF9saW5rLAot
CQkJCQkJCSBpbnRlcmZhY2UpOwogCWlmICghcHJpdi0+cGh5ZGV2KSB7CiAJCWRldl9lcnIoJmRl
di0+ZGV2LCAiY291bGQgbm90IGF0dGFjaCB0byBQSFlcbiIpOwogCQlyZXR1cm4gLUVOT0RFVjsK
LS0gCjEuOS4xCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwpMaW51eHBwYy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMub3Jn
Cmh0dHBzOi8vbGlzdHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBwYy1kZXY=
