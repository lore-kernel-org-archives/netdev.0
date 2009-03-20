From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 1/5] igb: allow tx of pre-formatted vlan tagged
	packets
Date: Fri, 20 Mar 2009 14:28:13 -0700
Message-ID: <9929d2390903201428l69774b8du98acc93940e2ad60@mail.gmail.com>
References: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
	 <20090320152724.GB7395@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	Arthur Jones <Arthur.Jones@riverbed.com>
To: Arthur Jones <ajones@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:8448 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbZCTV2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 17:28:15 -0400
Received: by an-out-0708.google.com with SMTP id d14so918279and.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2009 14:28:13 -0700 (PDT)
In-Reply-To: <20090320152724.GB7395@ajones-laptop.nbttech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gRnJpLCBNYXIgMjAsIDIwMDkgYXQgODoyNyBBTSwgQXJ0aHVyIEpvbmVzIDxham9uZXNAcml2
ZXJiZWQuY29tPiB3cm90ZToKPiBIaSBKZWZmLCAuLi4KPgo+IE9uIEZyaSwgTWFyIDIwLCAyMDA5
IGF0IDAzOjE2OjMxQU0gLTA3MDAsIEplZmYgS2lyc2hlciB3cm90ZToKPj4gwqBbLi4uXQo+Pgo+
PiDCoGRyaXZlcnMvbmV0L2lnYi9pZ2JfbWFpbi5jIHwgwqAgMTEgKysrKysrKysrKysKPj4gwqAx
IGZpbGVzIGNoYW5nZWQsIDExIGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCj4+Cj4+IGRp
ZmYgLS1naXQgYS9kcml2ZXJzL25ldC9pZ2IvaWdiX21haW4uYyBiL2RyaXZlcnMvbmV0L2lnYi9p
Z2JfbWFpbi5jCj4+IGluZGV4IDdjNDQ4MWIuLmMxNGQ1NjkgMTAwNjQ0Cj4+IC0tLSBhL2RyaXZl
cnMvbmV0L2lnYi9pZ2JfbWFpbi5jCj4+ICsrKyBiL2RyaXZlcnMvbmV0L2lnYi9pZ2JfbWFpbi5j
Cj4+IEBAIC0zMDA4LDYgKzMwMDgsMTcgQEAgc3RhdGljIGlubGluZSBib29sIGlnYl90eF9jc3Vt
X2FkdihzdHJ1Y3QgaWdiX2FkYXB0ZXIgKmFkYXB0ZXIsCj4+IMKgIMKgIMKgIMKgIMKgIMKgIMKg
IHR1X2NtZCB8PSAoRTEwMDBfVFhEX0NNRF9ERVhUIHwgRTEwMDBfQURWVFhEX0RUWVBfQ1RYVCk7
Cj4+Cj4+IMKgIMKgIMKgIMKgIMKgIMKgIMKgIGlmIChza2ItPmlwX3N1bW1lZCA9PSBDSEVDS1NV
TV9QQVJUSUFMKSB7Cj4+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgX19iZTE2IHBy
b3RvY29sOwo+PiArCj4+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgaWYgKHNrYi0+
cHJvdG9jb2wgPT0gY3B1X3RvX2JlMTYoRVRIX1BfODAyMVEpKSB7Cj4+ICsgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgY29uc3Qgc3RydWN0IHZsYW5fZXRoaGRyICp2
aGRyID0KPj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCAoY29uc3Qgc3RydWN0IHZsYW5fZXRoaGRyKilza2ItPmRhdGE7Cj4+ICsKPj4g
KyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBwcm90b2NvbCA9IHZo
ZHItPmhfdmxhbl9lbmNhcHN1bGF0ZWRfcHJvdG87Cj4+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgfSBlbHNlIHsKPj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCBwcm90b2NvbCA9IHNrYi0+cHJvdG9jb2w7Cj4+ICsgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgfQo+PiArCj4+IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHN3
aXRjaCAoc2tiLT5wcm90b2NvbCkgewo+IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgXl5eXl5eXl5eXl5eXgo+IFRoaXMgaGFzIHRoZSBzYW1lIG1lcmdlIGVy
cm9yIGFzIHRoZSBlMTAwMGUgdmVyc2lvbiwKPiBpdCBzaG91bGQgYmUganVzdCBwcm90b2NvbCBo
ZXJlLCBub3Qgc2tiLT5wcm90b2NvbC4uLgo+Cj4gQXJ0aHVyCj4gLS0KClNvcnJ5LCB3aGVuIEkg
bWVyZ2VkIHlvdXIgcGF0Y2ggaW50byBteSB0cmVlLCB0aGF0IGlzIHdoZW4gdGhlIG1lcmdlCmVy
cm9yIG9jY3VycmVkLgoKLS0gCkNoZWVycywKSmVmZgo=
