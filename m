From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH v2 1/2] net: af_packet support for direct ring
 access in user space
Date: Tue, 13 Jan 2015 17:15:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC6BA5@AcuExch.aculab.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32>
 <1421152510.13626.22.camel@stressinduktion.org>
 <54B51BEC.2040809@redhat.com> <54B538C1.6000500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"danny.zhou@intel.com" <danny.zhou@intel.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"john.ronciak@intel.com" <john.ronciak@intel.com>,
	"brouer@redhat.com" <brouer@redhat.com>
To: 'John Fastabend' <john.fastabend@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:63786 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbbAMRQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:16:58 -0500
In-Reply-To: <54B538C1.6000500@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSm9obiBGYXN0YWJlbmQNCj4gT24gMDEvMTMvMjAxNSAwNToyMSBBTSwgRGFuaWVsIEJv
cmttYW5uIHdyb3RlOg0KPiA+IE9uIDAxLzEzLzIwMTUgMDE6MzUgUE0sIEhhbm5lcyBGcmVkZXJp
YyBTb3dhIHdyb3RlOg0KPiA+PiBPbiBNbywgMjAxNS0wMS0xMiBhdCAyMDozNSAtMDgwMCwgSm9o
biBGYXN0YWJlbmQgd3JvdGU6DQo+ID4gLi4uDQo+ID4+PiArLyogc2V0c29ja29wdCB0YWtlcyBh
ZGRyLCBzaXplICxkaXJlY3Rpb24gcGFyYW1ldG5lciwgZ2V0c29ja29wdCB0YWtlcw0KPiA+Pj4g
KyAqIGlvdmEsIHNpemUsIGRpcmVjdGlvbi4NCj4gPj4+ICsgKiAqLw0KPiA+Pj4gK3N0cnVjdCB0
cGFja2V0X2RtYV9tZW1fcmVnaW9uIHsNCj4gPj4+ICsgICAgdm9pZCAqYWRkcjsgICAgICAgIC8q
IHVzZXJzcGFjZSB2aXJ0dWFsIGFkZHJlc3MgKi8NCj4gPj4+ICsgICAgX191NjQgcGh5c19hZGRy
OyAgICAvKiBwaHlzaWNhbCBhZGRyZXNzICovDQo+ID4+PiArICAgIF9fdTY0IGlvdmE7ICAgICAg
ICAvKiBJTyB2aXJ0dWFsIGFkZHJlc3MgdXNlZCBmb3IgRE1BICovDQo+ID4+PiArICAgIHVuc2ln
bmVkIGxvbmcgc2l6ZTsgICAgLyogc2l6ZSBvZiByZWdpb24gKi8NCj4gPj4+ICsgICAgaW50IGRp
cmVjdGlvbjsgICAgICAgIC8qIGRtYSBkYXRhIGRpcmVjdGlvbiAqLw0KPiA+Pj4gK307DQo+ID4+
DQo+ID4+IEhhdmUgeW91IHRlc3RlZCB0aGlzIHdpdGggd2l0aCAzMiBiaXQgdXNlciBzcGFjZSBh
bmQgMzIgYml0IGtlcm5lbCwgdG9vPw0KPiA+PiBJIGRvbid0IGhhdmUgYW55IHByb2JsZW0gd2l0
aCBvbmx5IHN1cHBvcnRpbmcgNjQgYml0IGtlcm5lbHMgZm9yIHRoaXMNCj4gPj4gZmVhdHVyZSwg
YnV0IGxvb2tpbmcgdGhyb3VnaCB0aGUgY29kZSBJIHdvbmRlciBpZiB3ZSBoYW5kbGUgdGhlIF9f
dTY0DQo+ID4+IGFkZHJlc3NlcyBjb3JyZWN0bHkgaW4gYWxsIHNpdHVhdGlvbnMuDQo+IA0KPiBX
ZSBzdGlsbCBuZWVkIHRvIHRlc3QvaW1wbGVtZW50IHRoaXMgSSdtIGdvaW5nIHRvIGd1ZXNzIHRo
ZXJlIGlzIHNvbWUNCj4gbW9yZSB3b3JrIG5lZWRlZCBmb3IgdGhpcyB0byB3b3JrIGNvcnJlY3Rs
eS4NCg0KSG93IGFib3V0IHNvbWV0aGluZyBsaWtlOg0KDQpzdHJ1Y3QgdHBhY2tldF9kbWFfbWVt
X3JlZ2lvbiB7DQogICAgX191NjQgYWRkcjsgICAgICAgIC8qIHVzZXJzcGFjZSB2aXJ0dWFsIGFk
ZHJlc3MgKi8NCiAgICBfX3U2NCBwaHlzX2FkZHI7ICAgIC8qIHBoeXNpY2FsIGFkZHJlc3MgKi8N
CiAgICBfX3U2NCBpb3ZhOyAgICAgICAgLyogSU8gdmlydHVhbCBhZGRyZXNzIHVzZWQgZm9yIERN
QSAqLw0KICAgIF9fdTY0IHNpemU7ICAgIC8qIHNpemUgb2YgcmVnaW9uICovDQogICAgaW50IGRp
cmVjdGlvbjsgICAgICAgIC8qIGRtYSBkYXRhIGRpcmVjdGlvbiAqLw0KfSBhbGlnbmVkKDgpOw0K
DQpTbyB0aGF0IGl0IGlzIGluZGVwZW5kYW50IG9mIDMyLzY0IGJpdHMuDQpJdCBpcyBhIHNoYW1l
IHRoYXQgZ2NjIGhhcyBubyB3YXkgb2YgZGVmaW5pbmcgYSA2NGJpdCAndm9pZCAqJyBvbiAzMmJp
dCBzeXN0ZW1zLg0KWW91IGNhbiB1c2UgYSB1bmlvbiwgYnV0IHlvdSBzdGlsbCBuZWVkIHRvIHpl
cm8gZXh0ZW5kIHRoZSB2YWx1ZSBvbiBMRSAod29yc2Ugb24gQkUpLg0KDQoJRGF2aWQNCg0KDQo=
