From: Kyeong Yoo <Kyeong.Yoo@alliedtelesis.co.nz>
Subject: [net-next PATCH v2] net_sched: dsmark: use qdisc_dequeue_peeked()
Date: Thu, 3 Mar 2016 10:25:19 +0000
Message-ID: <1457000719.30212.3.camel@kyeongy-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:47939 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755836AbcCCKZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 05:25:32 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id E8352806A7
	for <netdev@vger.kernel.org>; Thu,  3 Mar 2016 23:25:20 +1300 (NZDT)
Content-Language: en-US
Content-ID: <58A90E86D4B5B640A5845C081AF87987@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGhpcyBmaXggaXMgZm9yIGRzbWFyayBzaW1pbGFyIHRvIGNvbW1pdCAzNTU3NjE5ZjBmNmY3NDk2
ZWQ0NTNkNDgyNWUyNDkNCigibmV0X3NjaGVkOiBwcmlvOiB1c2UgcWRpc2NfZGVxdWV1ZV9wZWVr
ZWQiKQ0KYW5kIG1ha2VzIHVzZSBvZiBxZGlzY19kZXF1ZXVlX3BlZWtlZCgpIGluc3RlYWQgb2Yg
ZGlyZWN0IGRlcXVldWUoKSBjYWxsLg0KDQpGaXJzdCB0aW1lLCB3cnIgcGVla3MgZHNtYXJrLCB3
aGljaCB3aWxsIHRoZW4gcGVlayBpbnRvIHNmcS4NCnNmcSBkZXF1ZXVlcyBhbiBza2IgYW5kIGl0
J3Mgc3RvcmVkIGluIHNjaC0+Z3NvX3NrYi4NCk5leHQgdGltZSwgd3JyIHRyaWVzIHRvIGRlcXVl
dWUgZnJvbSBkc21hcmssIHdoaWNoIHdpbGwgY2FsbCBzZnEgZGVxdWV1ZQ0KZGlyZWN0bHkuIFRo
aXMgcmVzdWx0cyBza2lwcGluZyB0aGUgcHJldmlvdXNseSBwZWVrZWQgc2tiLg0KDQpTbyBjaGFu
Z2VkIGRzbWFyayBkZXF1ZXVlIHRvIGNhbGwgcWRpc2NfZGVxdWV1ZV9wZWVrZWQoKSBpbnN0ZWFk
IHRvIHVzZQ0KcGVla2VkIHNrYiBpZiBleGlzdHMuDQoNClNpZ25lZC1vZmYtYnk6IEt5ZW9uZyBZ
b28gPGt5ZW9uZy55b29AYWxsaWVkdGVsZXNpcy5jby5uej4NCg0KZGlmZiAtLWdpdCBhL25ldC9z
Y2hlZC9zY2hfZHNtYXJrLmMgYi9uZXQvc2NoZWQvc2NoX2RzbWFyay5jDQppbmRleCBmMzU3ZjM0
Li5iMjA0NDcyIDEwMDY0NA0KLS0tIGEvbmV0L3NjaGVkL3NjaF9kc21hcmsuYw0KKysrIGIvbmV0
L3NjaGVkL3NjaF9kc21hcmsuYw0KQEAgLTI4MSw3ICsyODEsNyBAQCBzdGF0aWMgc3RydWN0IHNr
X2J1ZmYgKmRzbWFya19kZXF1ZXVlKHN0cnVjdCBRZGlzYyAqc2NoKQ0KIA0KIAlwcl9kZWJ1Zygi
JXMoc2NoICVwLFtxZGlzYyAlcF0pXG4iLCBfX2Z1bmNfXywgc2NoLCBwKTsNCiANCi0Jc2tiID0g
cC0+cS0+b3BzLT5kZXF1ZXVlKHAtPnEpOw0KKwlza2IgPSBxZGlzY19kZXF1ZXVlX3BlZWtlZChw
LT5xKTsNCiAJaWYgKHNrYiA9PSBOVUxMKQ0KIAkJcmV0dXJuIE5VTEw7DQoNCg==
