From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH v1 1/3] net: sched: af_packet support for
 direct ring access
Date: Tue, 7 Oct 2014 09:27:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174C5C35@AcuExch.aculab.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
 <CA+FuTSfwTBtZLu7CXh4bPxUtVubOvpCPo+O38BsnSiLdvV_KEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Network Development <netdev@vger.kernel.org>,
	"john.ronciak@intel.com" <john.ronciak@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"danny.zhou@intel.com" <danny.zhou@intel.com>
To: 'Willem de Bruijn' <willemb@google.com>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42305 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752825AbaJGJ2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 05:28:32 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 05392-02 for <netdev@vger.kernel.org>;
 Tue,  7 Oct 2014 10:28:23 +0100 (BST)
In-Reply-To: <CA+FuTSfwTBtZLu7CXh4bPxUtVubOvpCPo+O38BsnSiLdvV_KEA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogV2lsbGVtIGRlIEJydWlqbg0KLi4uDQo+IFdoZW4ga2VlcGluZyB0aGUga2VybmVsIGlu
IHRoZSBsb29wLCBpdCBpcyBwb3NzaWJsZSB0byBkbw0KPiBzb21lIGJhc2ljIHNhbml0eSBjaGVj
a2luZyBhbmQgdHJhbnNwYXJlbnRseSB0cmFuc2xhdGUgYmV0d2Vlbg0KPiB2YWRkciBhbmQgcGFk
ZHIsIGV2ZW4gd2hlbiBleHBvc2luZyB0aGUgaGFyZHdhcmUgZGVzY3JpcHRvcnMNCj4gZGlyZWN0
bHkuDQoNClRoZSBhcHBsaWNhdGlvbiBjb3VsZCBjaGFuZ2UgdGhlIGFkZHJlc3NlcyBhZnRlciB0
aGV5IGhhdmUgYmVlbg0KdmFsaWRhdGVkLCBidXQgYmVmb3JlIHRoZXkgaGF2ZSBiZWVuIHJlYWQg
YnkgdGhlIGRldmljZS4NCg0KPiBUaG91Z2ggYXQgdGhpcyBwb2ludCBpdCBtYXkgYmUganVzdCBh
cyBjaGVhcCB0byBleHBvc2UNCj4gYW4gaWRlYWxpemVkIHZpcnR1YWxpemVkIGRlc2NyaXB0b3Ig
Zm9ybWF0IGFuZCBjb3B5IGZpZWxkcyBiZXR3ZWVuDQo+IHRoYXQgYW5kIGRldmljZSBkZXNjcmlw
dG9ycy4NCg0KVGhhdCBpcyAocHJvYmFibHkpIHRoZSBvbmx5IHNjaGVtZSB0aGF0IHN0b3BzIHRo
ZSBhcHBsaWNhdGlvbg0KYWNjZXNzaW5nIHJhbmRvbSBwYXJ0cyBvZiBwaHlzaWNhbCBtZW1vcnku
DQoNCj4gT25lIGFzc3VtcHRpb24gdW5kZXJseWluZyBleHBvc2luZyB0aGUgaGFyZHdhcmUgZGVz
Y3JpcHRvcnMNCj4gaXMgdGhhdCB0aGV5IGFyZSBxdWlyZSBzaW1pbGFyIGJldHdlZW4gZGV2aWNl
cy4gSG93IHRydWUgaXMgdGhpcw0KPiBpbiB0aGUgY29udGV4dCBvZiBmb3JtYXRzIHRoYXQgc3Bh
biBtdWx0aXBsZSBkZXNjcmlwdG9ycz8NCg0KSSBzdXNwZWN0IHlvdSdkIG5lZWQgdG8gZGVmaW5l
IGNvbXBsZXRlIHJpbmcgZW50cmllcyBmb3IgJ2luaXRpYWwnLA0KJ21pZGRsZScsICdmaW5hbCcg
YW5kICdjb21wbGV0ZScgZnJhZ21lbnRzLCB0b2dldGhlciB3aXRoIHRoZQ0Kb2Zmc2V0cyBhbmQg
ZW5kaWFubmVzcyAoYW5kIHNpemU/KSBvZiB0aGUgYWRkcmVzcyBhbmQgZGF0YSBmaWVsZHMuDQoN
CkFsc28gd2hldGhlciB0aGVyZSBpcyBhIHNwZWNpYWwgJ2xhc3QgZW50cnknIGluIHRoZSByaW5n
Lg0KDQpQYXNzaW5nIGNoZWNrc3VtIG9mZmxvYWQgZmxhZ3MgdGhyb3VnaCBhZGRzIGFuIGV4dHJh
IGxldmVsIG9mIGNvbXBsZXhpdHkuDQoNClJpbmdzIGxpa2UgdGhlIHhoY2kgKGFjdHVhbGx5IFVT
QiwgYnV0IGNvdWxkIGNvbnRhaW4gZXRoZXJuZXQgZGF0YSkNCnJlcXVpcmUgdGhlICdvd25lcicg
Yml0IGJlIHdyaXR0ZW4gb2RkIG9yIGV2ZW4gaW4gYWx0ZXJuYXRpbmcgcGFzc2VzLg0KQWN0dWFs
bHkgbWFwcGluZyBzdXBwb3J0IGZvciB1c2JuZXQgKGVzcGVjaWFsbHkgeGhjaSAtIHVzYjMpIG1p
Z2h0IHNob3cNCnVwIHNvbWUgZGVmaWNpZW5jaWVzIGluIHRoZSBkZWZpbml0aW9uLg0KDQpZb3Ug
YWxzbyBuZWVkIHRvIGtub3cgd2hlbiB0cmFuc21pdHMgaGF2ZSBjb21wbGV0ZWQuDQpUaGlzIG1p
Z2h0IGJlIGFuICdvd25lcicgYml0IGJlaW5nIGNsZWFyZWQsIGJ1dCBjb3VsZCBiZSBzaWduYWxs
ZWQNCmluIGFuIGVudGlyZWx5IGRpZmZlcmVudCB3YXkuDQoNCglEYXZpZA0KDQo=
