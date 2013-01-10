From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: [Xen-devel] xen-netback notify DomU to send ARP.
Date: Thu, 10 Jan 2013 15:00:15 +0800
Message-ID: <50EE66FF.2020802@oracle.com>
References: <50EC099D.6020407@oracle.com> <50EC297A02000078000B3BB5@nat28.tlf.novell.com> <1357652541.7989.179.camel@zakaz.uk.xensource.com> <50EC3DFD.8060206@oracle.com> <1357660834.12649.103.camel@dagon.hellion.org.uk> <50ED1EB3.3080605@oracle.com> <50ED4F1D02000078000B3F87@nat28.tlf.novell.com> <50ED6255.7020006@oracle.com> <50ED825802000078000B4113@nat28.tlf.novell.com> <50ED8ED3.8010007@163.com> <50ED9E6502000078000B4220@nat28.tlf.novell.com> <50ED950A.6010203@163.com> <50EDA80002000078000B427B@nat28.tlf.novell.com> <50EDA624.1010008@163.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020303050809000304010502"
Cc: Jan Beulich <JBeulich@suse.com>, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25678 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174Ab3AJHAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 02:00:40 -0500
In-Reply-To: <50EDA624.1010008@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020303050809000304010502
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

The patch main to fix the below circumstance:
Bonding  run in Active-Backup mode.
Out PC --> switcher
             port A --> eth0 --> bond0 --> xenbr0 --> netbackend --> DomU
             port B -- eth1 /
Or

Out PC (R)--> switcher A --> eth0 --> bond0 --> xenbr0 --> netbackend 
--> DomU
             \ switcher B -- eth1 /

When Switcher Port A (active port) don't reach, or switcher A don't reach,
the surroundings will changed to the below circumstance.
Out PC --> switcher
             port A -X- eth0 -- bond0 -- xenbr0 -- netbackend -- DomU
             port B -- eth1 /
Or

Out PC (R)--> switcher A -X- eth0 -- bond0 -- xenbr0 -- netbackend -- DomU
             \ switcher B -- eth1 /

So, the former traffic will be unreachable before find the correct path 
(by sending
ARP request).

So, the patch is main to found the bonding change event, and gratutious 
ARP initialtivly
to out PC find the correct path.

the correct path should be the below circumstance:
Out PC --> switcher
             port A -X- eth0 --> bond0 --> xenbr0 --> netbackend --> DomU
             port B --> eth1 /
Or

Out PC (R)--> switcher A -X- eth0 --> bond0 --> xenbr0 --> netbackend 
--> DomU
             \ switcher B --> eth1 /

Thanks,
Jason

--------------020303050809000304010502
Content-Type: text/plain; charset=gb18030;
 name="0001-xen-netback-notify-frontend-to-send-gratuitous-ARP.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename*0="0001-xen-netback-notify-frontend-to-send-gratuitous-ARP.patc";
 filename*1="h"

RnJvbSBjZDVhMzNmOTEzN2E2MGYyN2MyYThjNmM3N2E1MjBkMmRmMzU2YzdhIE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBKYXNvbiBMdWFuIDxqaWFuaGFpLmx1YW5Ab3JhY2xl
LmNvbT4KRGF0ZTogRnJpLCAyOCBEZWMgMjAxMiAxNTo0MzowNiArMDgwMApTdWJqZWN0OiBb
UEFUQ0hdIHhlbi1uZXRiYWNrIG5vdGlmeSBmcm9udGVuZCB0byBzZW5kIGdyYXR1aXRvdXMg
QVJQLgoKSW4gdGhlIHJlYWwgbmV0d29yayBlbnZpcm9ubWVudCwgc29tZSBjYXVzZSB3aWxs
IGxlYWQKdG8gQWN0aXZlLUJhY2t1cCBtb2RlIGJvbmRpbmcgY2hvc2UgbmV3IGFjdGl2ZWQg
cG9ydC4KQWZ0ZXIgdGhhdCwgdGhlIHRyZmZpYywgZGVzdGluYXRlZCB0byBEb21VIGJ5IGlu
YWN0aXZlZApwb3J0IChmb3JtZXIgYWN0aXZlZCBwb3J0KSwgd2lsbCBiZSB1bnJlYWNoYWJs
ZSBhdCBub3cuCkRvbVUgc2hvdWxkIHNlbmQgZ3JhdHV0aW91cyBBUlAgaW5pdGlhbHRpdmx5
IHRvIGZpbmQgdGhlCm5ldyBjb3JyZWN0ZWQgcGF0aC4KCkJ5IG5ldGJhY2sncyBDb25uZWN0
ZWQtPkNvbm5lY3RlZCB0cmFuc2l0aW9uLCBmcm9udGVuZAp3aWxsIHdhdGNoIHRoZSBjaGFu
Z2UsIGFuZCBzZW5kIGdyYXR1aXRvdXMgQVJQLgoKU2lnbmVkLW9mZi1ieTogSmFzb24gTHVh
biA8amlhbmhhaS5sdWFuQG9yYWNsZS5jb20+Ci0tLQogZHJpdmVycy9uZXQveGVuLW5ldGJh
Y2sveGVuYnVzLmMgfCAgIDY4ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrCiAxIGZpbGVzIGNoYW5nZWQsIDY4IGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0p
CgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQveGVuLW5ldGJhY2sveGVuYnVzLmMgYi9kcml2
ZXJzL25ldC94ZW4tbmV0YmFjay94ZW5idXMuYwppbmRleCA0MTAwMThjLi5lYmVhNjgzIDEw
MDY0NAotLS0gYS9kcml2ZXJzL25ldC94ZW4tbmV0YmFjay94ZW5idXMuYworKysgYi9kcml2
ZXJzL25ldC94ZW4tbmV0YmFjay94ZW5idXMuYwpAQCAtMjYsNiArMjYsNyBAQCBzdHJ1Y3Qg
YmFja2VuZF9pbmZvIHsKIAlzdHJ1Y3QgeGVudmlmICp2aWY7CiAJZW51bSB4ZW5idXNfc3Rh
dGUgZnJvbnRlbmRfc3RhdGU7CiAJc3RydWN0IHhlbmJ1c193YXRjaCBob3RwbHVnX3N0YXR1
c193YXRjaDsKKwlzdHJ1Y3Qgbm90aWZpZXJfYmxvY2sgdmlmX25vdGlmaWVyOwogCXU4IGhh
dmVfaG90cGx1Z19zdGF0dXNfd2F0Y2g6MTsKIH07CiAKQEAgLTM0LDExICszNSw3NCBAQCBz
dGF0aWMgdm9pZCBjb25uZWN0KHN0cnVjdCBiYWNrZW5kX2luZm8gKik7CiBzdGF0aWMgdm9p
ZCBiYWNrZW5kX2NyZWF0ZV94ZW52aWYoc3RydWN0IGJhY2tlbmRfaW5mbyAqYmUpOwogc3Rh
dGljIHZvaWQgdW5yZWdpc3Rlcl9ob3RwbHVnX3N0YXR1c193YXRjaChzdHJ1Y3QgYmFja2Vu
ZF9pbmZvICpiZSk7CiAKKy8qCisgKiBCeSBDb25uZWN0ZWQtPkNvbm5lY3RlZCB0cmFuc2l0
aW9uLCBuZXRmcm9udCB3aWxsIHdhdGNoIHRoZSBjaGFuZ2UgYW5kCisgKiBzZW5kIGdyYXR1
aXRvdXMgQVJQLgorICovCitzdGF0aWMgdm9pZCBub3RpZnlfZnJvbnRfYXJwaW5nKHN0cnVj
dCB4ZW5idXNfZGV2aWNlICpkZXYpCit7CisJc3RydWN0IHhlbmJ1c190cmFuc2FjdGlvbiB4
YnQ7CisJaW50IGVycjsKKworCWlmICh4ZW5idXNfcmVhZF9kcml2ZXJfc3RhdGUoZGV2LT5u
b2RlbmFtZSkgIT0gWGVuYnVzU3RhdGVDb25uZWN0ZWQpCisJCXJldHVybjsKKworYWdhaW46
CisJZXJyID0geGVuYnVzX3RyYW5zYWN0aW9uX3N0YXJ0KCZ4YnQpOworCWlmIChlcnIpIHsK
KwkJcHJfZm10KCJFcnJvciBzdGFydGluZyB0cmFuc2FjdGlvbiIpOworCQlyZXR1cm47CisJ
fQorCisJZXJyID0geGVuYnVzX3ByaW50Zih4YnQsIGRldi0+bm9kZW5hbWUsICJzdGF0ZSIs
ICIlZCIsIGRldi0+c3RhdGUpOworCWlmIChlcnIpIHsKKwkJcHJfZm10KCJFcnJvciB3cml0
aW5nIHRoZSBzdGF0ZSIpOworCQlnb3RvIGFib3J0OworCX0KKworCWVyciA9IHhlbmJ1c190
cmFuc2FjdGlvbl9lbmQoeGJ0LCAwKTsKKwlpZiAoZXJyID09IC1FQUdBSU4pCisJCWdvdG8g
YWdhaW47CisJaWYgKGVycikKKwkJcHJfZm10KCJFcnJvciBlbmRpbmcgdHJhbnNhY3Rpb24i
KTsKKworCXJldHVybjsKK2Fib3J0OgorCXhlbmJ1c190cmFuc2FjdGlvbl9lbmQoeGJ0LCAx
KTsKK30KKworI2RlZmluZSBuYl90b19iYWNrZW5kKG5iKSBjb250YWluZXJfb2YobmIsIHN0
cnVjdCBiYWNrZW5kX2luZm8sIHZpZl9ub3RpZmllcikKKy8qKgorICogV2hlbiBuZXR3b3Jr
IGNvbmRpdGlvbiBvZiB2aWYgY2hhbmdlLCBub3RpZnkgdGhlIGZyb250ZW5kLgorICovCitz
dGF0aWMgaW50IG5ldGJhY2tfbmV0ZGV2X2V2ZW50KHN0cnVjdCBub3RpZmllcl9ibG9jayAq
dGhpcywKKwkJCQl1bnNpZ25lZCBsb25nIGV2ZW50LCB2b2lkICpwdHIpCit7CisJc3RydWN0
IG5ldF9kZXZpY2UgKmV2ZW50X2RldiA9IHB0cjsKKwlzdHJ1Y3QgYmFja2VuZF9pbmZvICpi
ZSA9IG5iX3RvX2JhY2tlbmQodGhpcyk7CisKKwlwcl9kZWJ1ZygiZXZlbnRfZGV2OiAlcywg
ZXZlbnQ6ICVseFxuIiwKKwkJIGV2ZW50X2RldiA/IGV2ZW50X2Rldi0+bmFtZSA6ICJOb25l
IiwgZXZlbnQpOworCisJaWYgKCFiZS0+dmlmKQorCQlyZXR1cm4gTk9USUZZX0RPTkU7CisK
Kwlzd2l0Y2ggKGV2ZW50KSB7CisJY2FzZSBORVRERVZfTk9USUZZX1BFRVJTOgorCQkvKiBO
b3RpZnkgZnJvbnRlbmQgdG8gU2VuZCBncmF0dWl0b3VzIEFSUCAqLworCQlub3RpZnlfZnJv
bnRfYXJwaW5nKGJlLT5kZXYpOworCQlicmVhazsKKwl9CisKKwlyZXR1cm4gTk9USUZZX0RP
TkU7Cit9CisKIHN0YXRpYyBpbnQgbmV0YmFja19yZW1vdmUoc3RydWN0IHhlbmJ1c19kZXZp
Y2UgKmRldikKIHsKIAlzdHJ1Y3QgYmFja2VuZF9pbmZvICpiZSA9IGRldl9nZXRfZHJ2ZGF0
YSgmZGV2LT5kZXYpOwogCiAJdW5yZWdpc3Rlcl9ob3RwbHVnX3N0YXR1c193YXRjaChiZSk7
CisJdW5yZWdpc3Rlcl9uZXRkZXZpY2Vfbm90aWZpZXIoJmJlLT52aWZfbm90aWZpZXIpOwog
CWlmIChiZS0+dmlmKSB7CiAJCWtvYmplY3RfdWV2ZW50KCZkZXYtPmRldi5rb2JqLCBLT0JK
X09GRkxJTkUpOwogCQl4ZW5idXNfcm0oWEJUX05JTCwgZGV2LT5ub2RlbmFtZSwgImhvdHBs
dWctc3RhdHVzIik7CkBAIC0xMjksNiArMTkzLDEwIEBAIHN0YXRpYyBpbnQgbmV0YmFja19w
cm9iZShzdHJ1Y3QgeGVuYnVzX2RldmljZSAqZGV2LAogCS8qIFRoaXMga2lja3MgaG90cGx1
ZyBzY3JpcHRzLCBzbyBkbyBpdCBpbW1lZGlhdGVseS4gKi8KIAliYWNrZW5kX2NyZWF0ZV94
ZW52aWYoYmUpOwogCisJLyogUmVnaXN0ZXIgRnJvbnRlbmQgRXZlbnQgTm90aWZ5ICovCisJ
YmUtPnZpZl9ub3RpZmllci5ub3RpZmllcl9jYWxsID0gbmV0YmFja19uZXRkZXZfZXZlbnQ7
CisJcmVnaXN0ZXJfbmV0ZGV2aWNlX25vdGlmaWVyKCZiZS0+dmlmX25vdGlmaWVyKTsKKwog
CXJldHVybiAwOwogCiBhYm9ydF90cmFuc2FjdGlvbjoKLS0gCjEuNy42LjUKCg==
--------------020303050809000304010502--
