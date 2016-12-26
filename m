From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net 3/9] virtio-net: fix page miscount during XDP
	linearizing
Date: Mon, 26 Dec 2016 10:30:10 +0800
Message-ID: <42cb7705-748a-f385-f5cd-e124e0f6e8e0@redhat.com>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
	<1482503852-12438-4-git-send-email-jasowang@redhat.com>
	<585D48A7.3040701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: john.r.fastabend@intel.com
To: John Fastabend <john.fastabend@gmail.com>, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <585D48A7.3040701@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

CgpPbiAyMDE25bm0MTLmnIgyM+aXpSAyMzo1NCwgSm9obiBGYXN0YWJlbmQgd3JvdGU6Cj4gT24g
MTYtMTItMjMgMDY6MzcgQU0sIEphc29uIFdhbmcgd3JvdGU6Cj4+IFdlIGRvbid0IHB1dCBwYWdl
IGR1cmluZyBsaW5lYXJpemluZywgdGhlIHdvdWxkIGNhdXNlIGxlYWtpbmcgd2hlbgo+PiB4bWl0
IHRocm91Z2ggWERQX1RYIG9yIHRoZSBwYWNrZXQgZXhjZWVkcyBQQUdFX1NJWkUuIEZpeCB0aGVt
IGJ5Cj4+IHB1dCBwYWdlIGFjY29yZGluZ2x5LiBBbHNvIGRlY3JlYXNlIHRoZSBudW1iZXIgb2Yg
YnVmZmVycyBkdXJpbmcKPj4gbGluZWFyaXppbmcgdG8gbWFrZSBzdXJlIGNhbGxlciBjYW4gZnJl
ZSBidWZmZXJzIGNvcnJlY3RseSB3aGVuIHBhY2tldAo+PiBleGNlZWRzIFBBR0VfU0laRS4gV2l0
aCB0aGlzIHBhdGNoLCB3ZSB3b24ndCBnZXQgT09NIGFmdGVyIGxpbmVhcml6ZQo+PiBodWdlIG51
bWJlciBvZiBwYWNrZXRzLgo+Pgo+PiBDYzogSm9obiBGYXN0YWJlbmQgPGpvaG4uci5mYXN0YWJl
bmRAaW50ZWwuY29tPgo+PiBTaWduZWQtb2ZmLWJ5OiBKYXNvbiBXYW5nIDxqYXNvd2FuZ0ByZWRo
YXQuY29tPgo+PiAtLS0KPiBUaGFua3MhIGxvb2tzIGdvb2QuIEJ5IHRoZSB3YXkgZG8geW91IGhh
cHBlbiB0byBoYXZlIGFueSBhY3R1YWwKPiBjb25maWd1cmF0aW9uIHdoZXJlIHRoaXMgcGF0aCBp
cyBoaXQ/IEkgb2J2aW91c2x5IGRpZG4ndCB0ZXN0IHRoaXMKPiB2ZXJ5IGxvbmcgb3RoZXIgdGhh
biBhIHF1aWNrIHRlc3Qgd2l0aCBteSBoYWNrZWQgdmhvc3QgZHJpdmVyLgo+Cj4gQWNrZWQtYnk6
IEpvaG4gRmFzdGFiZW5kIDxqb2huLnIuZmFzdGFiZW5kQGludGVsLmNvbT4KClllcywgSSBoYXZl
LiBKdXN0IGluY3JlYXNlIHRoZSBNVFUgYWJvdmUgMTUwMCBmb3IgYm90aCB2aXJ0aW8gYW5kIHRh
cCAKYW5kIHByb2R1Y2Ugc29tZSB0cmFmZmljIHdpdGggc2l6ZSB3aGljaCB3aWxsIGxlYWQgdW5k
ZXJlc3RpbWF0ZWQgb2YgcnhidWYuCgpUaGFua3MKX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX18KVmlydHVhbGl6YXRpb24gbWFpbGluZyBsaXN0ClZpcnR1YWxp
emF0aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3Vu
ZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3ZpcnR1YWxpemF0aW9u
