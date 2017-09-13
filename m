From: Josef Bacik <jbacik@fb.com>
Subject: Re: 319554f284dd ("inet: don't use sk_v6_rcv_saddr directly") causes
 bind port regression
Date: Wed, 13 Sep 2017 20:11:09 +0000
Message-ID: <A6639B92-6A9F-419D-B6F4-3ED134F000B4@fb.com>
References: <1a8ef376-387e-e0fc-7362-e1fd2c2c45d3@redhat.com>
        <AF16C126-99CA-401A-B803-AA05CDFBFF93@fb.com>
        <588f3795-931e-7779-4ec7-5fe7d4437927@redhat.com>
        <EF55EF02-AD40-4F06-8C07-4F9F4221BFE6@fb.com>,<20170913154750.100881c0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Laura Abbott <labbott@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Cole Robinson <crobinso@redhat.com>
To: Chuck Ebbert <cebbert.lkml@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170913154750.100881c0@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQo+IE9uIFNlcCAxMywgMjAxNywgYXQgMTI6NDYgUE0sIENodWNrIEViYmVydCA8Y2ViYmVydC5s
a21sQGdtYWlsLmNvbT4gd3JvdGU6DQo+IA0KPiBPbiBXZWQsIDEzIFNlcCAyMDE3IDE3OjI4OjI1
ICswMDAwDQo+IEpvc2VmIEJhY2lrIDxqYmFjaWtAZmIuY29tPiB3cm90ZToNCj4gDQo+PiBTb3Jy
eSBJIHRob3VnaHQgSSBoYWQgbWFkZSB0aGlzIG90aGVyIGZpeCwgY2FuIHlvdSBhcHBseSB0aGlz
IG9uIHRvcA0KPj4gb2YgdGhlIG90aGVyIG9uZSBhbmQgdHJ5IHRoYXQ/ICBJIGhhdmUgbW9yZSB0
aGluZ3MgdG8gdHJ5IGlmIHRoaXMNCj4+IGRvZXNu4oCZdCB3b3JrLCBzb3JyeSB5b3UgYXJlIHBs
YXlpbmcgZ28gYmV0d2VlbiwgYnV0IEkgd2FudCB0byBtYWtlDQo+PiBzdXJlIEkga25vdyBfd2hp
Y2hfIGZpeCBhY3R1YWxseSBmaXhlcyB0aGUgcHJvYmxlbSwgYW5kIHRoZW4gY2xlYW4gdXANCj4+
IGluIGZvbGxvd3VwIHBhdGNoZXMuICBUaGFua3MsDQo+PiANCj4+IEpvc2VmDQo+PiANCj4+IE9u
IDkvMTMvMTcsIDg6NDUgQU0sICJMYXVyYSBBYmJvdHQiIDxsYWJib3R0QHJlZGhhdC5jb20+IHdy
b3RlOg0KPj4gDQo+PiBPbiAwOS8xMi8yMDE3IDA0OjEyIFBNLCBKb3NlZiBCYWNpayB3cm90ZToN
Cj4+PiBGaXJzdCBJ4oCZbSBzdXBlciBzb3JyeSBmb3IgdGhlIHRvcCBwb3N0LCBJ4oCZbSBhdCBw
bHVtYmVycyBhbmQgSQ0KPj4+IGZvcmdvdCB0byB1cGxvYWQgbXkgbXV0dHJjIHRvIG15IG5ldyBj
bG91ZCBpbnN0YW5jZSwgc28gSeKAmW0gc2NyZXdlZA0KPj4+IHVzaW5nIG91dGxvb2suDQo+Pj4g
DQo+Pj4gSSBoYXZlIGEgY29tcGxldGVseSB1bnRlc3RlZCwgdW5jb21waWxlZCBwYXRjaCB0aGF0
IEkgdGhpbmsgd2lsbA0KPj4+IGZpeCB0aGUgcHJvYmxlbSwgd291bGQgeW91IG1pbmQgZ2l2aW5n
IGl0IGEgZ28/ICBUaGFua3MsDQo+Pj4gDQo+Pj4gSm9zZWYgIA0KPj4gDQo+PiBUaGFua3MgZm9y
IHRoZSBxdWljayB0dXJuYXJvdW5kLiBVbmZvcnR1bmF0ZWx5LCB0aGUgcHJvYmxlbSBpcyBzdGls
bA0KPj4gcmVwcm9kdWNpYmxlIGFjY29yZGluZyB0byB0aGUgcmVwb3J0ZXIuDQo+PiANCj4+IFRo
YW5rcywNCj4+IExhdXJhDQo+IA0KPiBJIGFtIGNvbmZ1c2VkIGJ5IHRoZSBwYXRjaCB0aGF0IG9y
aWdpbmFsbHkgY2F1c2VkIHRoaXM6DQo+IA0KPiAgICAgICAgaWYgKHNrLT5za19mYW1pbHkgPT0g
QUZfSU5FVDYpDQo+ICAgICAgICAgICAgICAgIHJldHVybiBpcHY2X3Jjdl9zYWRkcl9lcXVhbCgm
c2stPnNrX3Y2X3Jjdl9zYWRkciwNCj4gLSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAmc2syLT5za192Nl9yY3Zfc2FkZHIsDQo+ICsgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgaW5ldDZfcmN2X3NhZGRyKHNrMiksDQo+ICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBzay0+c2tfcmN2X3NhZGRyLA0KPiAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgc2syLT5za19yY3Zfc2Fk
ZHIsDQo+IA0KPiBTaG91bGRuJ3QgdGhlIGZpcnN0IGFyZ3VtZW50IGFsc28gYmUgY2hhbmdlZCB0
byB1c2UgaW5ldDZfcmN2X3NhZGRyKCk/DQoNCk5vIHdlIGtub3cgc2sgaXMgSVB2NiBzbyBpdCdz
IGFscmlnaHQgdG8gdXNlIGRpcmVjdGx5LiAgVGhhbmtzLA0KDQpKb3NlZg0K
