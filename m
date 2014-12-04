From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net] gso: do GSO for local skb with size
	bigger than MTU
Date: Thu, 4 Dec 2014 12:17:07 +0200
Message-ID: <20141204101707.GB17122@redhat.com>
References: <20141201135225.GA16814@casper.infradead.org>
 <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org>
 <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org>
 <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com>
 <20141203090339.GA9299@redhat.com>
 <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
 <20141203183859.GB16447@redhat.com> <547F5CC2.8000908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Du, Fan" <fan.du-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org" <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Rick Jones <rick.jones2-VXdhtT5mjnY@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <547F5CC2.8000908-VXdhtT5mjnY@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

T24gV2VkLCBEZWMgMDMsIDIwMTQgYXQgMTA6NTY6MDJBTSAtMDgwMCwgUmljayBKb25lcyB3cm90
ZToKPiBUcnlpbmcgdG8gImZha2Utb3V0IiBhbiBJQ01QIG1lc3NhZ2UgdG8gcGFwZXItb3ZlciAi
ZGV2aWNlcyIgaW4gdGhlICJtaWRkbGUiCj4gb2Ygc2FtZSBMYXllcjIgbmV0d29yayBoYXZpbmcg
ZGlmZmVyZW50IE1UVXMgZnJvbSB0aGUgZW5kcyBnb2VzIGJhY2sgdG8gYXQKPiBsZWFzdCB0aGUg
ZGF5cyB3aGVuIHBlb3BsZSBzdGFydGVkIGpvaW5pbmcgRkRESSBuZXR3b3JrcyB0byBFdGhlcm5l
dAo+IG5ldHdvcmtzIHdpdGggYnJpZGdlcyByYXRoZXIgdGhhbiByb3V0ZXJzLiAgUGVyaGFwcyBi
YWNrIGV2ZW4gZnVydGhlci4gIEl0Cj4gaGFkIHByb2JsZW1zIHRoZW0gKGluY2x1ZGluZyBub3Qg
YWxsIHRyYWZmaWMgYmVpbmcgSVApLCBJIGRvdWJ0IHRvZGF5IHdvdWxkCj4gYmUgYW55IGRpZmZl
cmVudC4KPiAKPiBBbGwgZGV2aWNlcyBpbiBhIExheWVyMiBuZXR3b3JrIG11c3QgaGF2ZSB0aGUg
c2FtZSBNVFUuICgqKQo+IAo+IFRoZSBvbmx5IGV4Y2VwdGlvbiB0byB0aGF0IHdoaWNoIGRvZXMg
bm90IGxlYWQgb25lIGRvd24gYSByYXRob2xlIGlzIHRoYXQKPiB5b3UgY2FuIGhhdmUgdGhlIE1U
VSBhdCB0aGUgImVkZ2VzIiBvZiB0aGUgTGF5ZXIgMiBuZXR3b3JrIGJlIHNtYWxsZXIgdGhhbgo+
IHRoZSBNVFUgaW4gdGhlICJtaWRkbGUuIiAgQW5kIHRoZW4gb25seSBpZiB0aGUgbWlkZGxlICJu
ZXZlciIgdHJpZXMgdG8gdGFsawo+IGl0c2VsZiB0byB0aGUgZWRnZXMgZGlyZWN0bHkuCj4gCj4g
cmljayBqb25lcwo+IAo+ICgqKSBPciBhdCBsZWFzdCBhbnkgY29tbXVuaWNhdGluZyBkZXZpY2Ug
bXVzdCBiZSBrZXB0IGlnbm9yYW50IG9mIHdoYXQgb25lCj4gZG9lcyB0byBoYXZlIGEgc21hbGxl
ciBNVFUgaW4gdGhlcmUgc29tZXdoZXJlLgoKV2hhdCBJJ3ZlIGJlZW4gcG9pbnRpbmcgb3V0IGlz
IHRoYXQganVzdCBiZWNhdXNlIHNvbWV0aGluZyBpcyB3aXRoaW4gYSBWTSwKd2UgY2FuJ3QgYXNz
dW1lIGl0J3MgYW4gZWRnZS4KCi0tIApNU1QKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0
dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
