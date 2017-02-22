From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Wed, 22 Feb 2017 17:58:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE6DBFD@AcuExch.aculab.com>
References: <20170213195858.5215-1-edumazet@google.com>
 <20170213195858.5215-9-edumazet@google.com>
 <1487780558.9415.81.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UcXhy3V_iSYFCWqPzdu77v=3-4FEXSyZEiUcB=Y_wGnVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        "Saeed Mahameed" <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:53029 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932705AbdBVR6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 12:58:33 -0500
In-Reply-To: <CAKgT0UcXhy3V_iSYFCWqPzdu77v=3-4FEXSyZEiUcB=Y_wGnVw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZGVyIER1eWNrDQo+IFNlbnQ6IDIyIEZlYnJ1YXJ5IDIwMTcgMTc6MjQNCi4u
Lg0KPiBTbyB0aGVyZSBpcyBhIHByb2JsZW0gdGhhdCBpcyBiZWluZyBvdmVybG9va2VkIGhlcmUu
ICBUaGF0IGlzIHRoZSBjb3N0DQo+IG9mIHRoZSBETUEgbWFwL3VubWFwIGNhbGxzLiAgVGhlIHBy
b2JsZW0gaXMgbWFueSBQb3dlclBDIHN5c3RlbXMgaGF2ZQ0KPiBhbiBJT01NVSB0aGF0IHlvdSBo
YXZlIHRvIHdvcmsgYXJvdW5kLCBhbmQgdGhhdCBJT01NVSBjb21lcyBhdCBhIGhlYXZ5DQo+IGNv
c3QgZm9yIGV2ZXJ5IG1hcC91bm1hcCBjYWxsLiAgU28gdW5sZXNzIHlvdSBhcmUgc2F5aW5nIHlv
dSB3YW4gdG8NCj4gc2V0dXAgYSBoeWJyaWQgYmV0d2VlbiB0aGUgbWx4NSBhbmQgdGhpcyBhcHBy
b2FjaCB3aGVyZSB3ZSBoYXZlIGEgcGFnZQ0KPiBjYWNoZSB0aGF0IHRoZXNlIGFsbCBmYWxsIGJh
Y2sgaW50byB5b3Ugd2lsbCB0YWtlIGEgaGVhdnkgY29zdCBmb3INCj4gaGF2aW5nIHRvIG1hcCBh
bmQgdW5tYXAgcGFnZXMuDQouLg0KDQpJIGNhbid0IGhlbHAgZmVlbGluZyB0aGF0IHlvdSBuZWVk
IHRvIGxvb2sgYXQgaG93IHRvIGdldCB0aGUgaW9tbXUNCmNvZGUgdG8gcmV1c2UgcGFnZXMsIHJh
dGhlciB0aGUgZXRoZXJuZXQgZHJpdmVyLg0KTWF5YmUgc29tZXRoaW5nIGxpa2U6DQoNCjEpIFRo
ZSBkcml2ZXIgcmVxdWVzdHMgYSBtYXBwZWQgcmVjZWl2ZSBidWZmZXIgZnJvbSB0aGUgaW9tbXUu
DQpUaGlzIG1pZ2h0IGdpdmUgaXQgbWVtb3J5IHRoYXQgaXMgYWxyZWFkeSBtYXBwZWQgYnV0IG5v
dCBpbiB1c2UuDQoNCjIpIFdoZW4gdGhlIHJlY2VpdmUgY29tcGxldGVzIHRoZSBkcml2ZXIgdGVs
bHMgdGhlIGlvbW11IHRoZSBtYXBwaW5nDQppcyBubyBsb25nZXIgbmVlZGVkLiBUaGUgaW9tbXUg
aXMgbm90ICh5ZXQpIGNoYW5nZWQuDQoNCjMpIFdoZW4gdGhlIHNrYiBpcyBmcmVlZCB0aGUgaW9t
bXUgaXMgdG9sZCB0aGF0IHRoZSBidWZmZXIgY2FuIGJlIGZyZWVkLg0KDQo0KSBBdCAoMSksIGlm
IHRoZSBkcml2ZXIgaXMgdXNpbmcgdG9vIG11Y2ggaW9tbXUgcmVzb3VyY2UgdGhlbiB0aGUgbWFw
cGluZw0KZm9yIGNvbXBsZXRlZCByZWNlaXZlcyBjYW4gYmUgcmVtb3ZlZCB0byBmcmVlIHVwIGlv
bW11IHNwYWNlLg0KDQpQcm9iYWJseSBub3QgYXMgc2ltcGxlIGFzIGl0IGxvb2tzIDotKQ0KDQoJ
RGF2aWQNCg0K
