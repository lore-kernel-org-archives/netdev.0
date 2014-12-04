From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net] gso: do GSO for local skb with size
	bigger than MTU
Date: Wed, 3 Dec 2014 16:54:36 -0800
Message-ID: <CAEP_g=-y_-=r+BHk3VfzxMNwH=B-26DvQrzQ7gkKG8fDG7Mx3g@mail.gmail.com>
References: <20141202170927.GA9457@casper.infradead.org>
 <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org>
 <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com>
 <20141203090339.GA9299@redhat.com>
 <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
 <20141203183859.GB16447@redhat.com>
 <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com>
 <20141203220244.GA8822@casper.infradead.org>
 <CAEP_g=90nC2HhmBNKh-hKJ5MJ85Z-_ER14roDxMsZAKog+dFhw@mail.gmail.com>
 <20141203230551.GC8822@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Du, Fan" <fan.du-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org" <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20141203230551.GC8822-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

T24gV2VkLCBEZWMgMywgMjAxNCBhdCAzOjA1IFBNLCBUaG9tYXMgR3JhZiA8dGdyYWZAc3V1Zy5j
aD4gd3JvdGU6Cj4gT24gMTIvMDMvMTQgYXQgMDI6NTFwbSwgSmVzc2UgR3Jvc3Mgd3JvdGU6Cj4+
IE15IHByb3Bvc2FsIHdvdWxkIGJlIHNvbWV0aGluZyBsaWtlIHRoaXM6Cj4+ICAqIEZvciBMMiwg
cmVkdWNlIHRoZSBWTSBNVFUgdG8gdGhlIGxvd2VzdCBjb21tb24gZGVub21pbmF0b3Igb24gdGhl
IHNlZ21lbnQuCj4+ICAqIEZvciBMMywgdXNlIHBhdGggTVRVIGRpc2NvdmVyeSBvciBmcmFnbWVu
dCBpbm5lciBwYWNrZXQgKGkuZS4KPj4gbm9ybWFsIHJvdXRpbmcgYmVoYXZpb3IpLgo+PiAgKiBB
cyBhIGxhc3QgcmVzb3J0IChzdWNoIGFzIGlmIHVzaW5nIGFuIG9sZCB2ZXJzaW9uIG9mIHZpcnRp
byBpbiB0aGUKPj4gZ3Vlc3QpLCBmcmFnbWVudCB0aGUgdHVubmVsIHBhY2tldC4KPgo+IFRoYXQn
cyB3aGF0IEkgaGFkIGluIG1pbmQgYXMgd2VsbCBhbHRob3VnaCB1c2luZyBhIGRpZmZlcmVudGlh
dG9yIGJpdAo+IHdoaWNoIGluZGljYXRlcyB0byB0aGUgb3V0cHV0IHBhdGggd2hldGhlciB0aGUg
cGFja2V0IGlzIHRvIGJlCj4gY29uc2lkZXJlZCBzd2l0Y2hlZCBvciByb3V0ZWQgYW5kIHRodXMg
c2VuZCBJQ01Qcy4gVGhlIGJpdCB3b3VsZCBiZSBzZXQKPiBwZXIgZmxvdywgdGh1cyBhbGxvd2lu
ZyBhcmJpdGFyeSBncmFudWxhcml0eSBvZiBiZWhhdmlvdXIuCgpJIGRvbid0IHRoaW5rIHRoYXQg
d2UgYWN0dWFsbHkgbmVlZCBhIGJpdC4gSSB3b3VsZCBleHBlY3QgdGhhdCBJQ01QCmdlbmVyYXRp
b24gdG8gYmUgY291cGxlZCB3aXRoIHJvdXRpbmcgKGFsdGhvdWdoIHRoaXMgcmVxdWlyZXMgYmVp
bmcKYWJsZSB0byBrbm93IHdoYXQgdGhlIHVsdGltYXRlIE1UVSBpcyBhdCB0aGUgdGltZSBvZiBy
b3V0aW5nIHRoZSBpbm5lcgpwYWNrZXQpLiBJZiB0aGF0J3MgdGhlIGNhc2UsIHlvdSBqdXN0IG5l
ZWQgdG8gc3RlZXIgYmV0d2VlbiBMMiBhbmQgTDMKcHJvY2Vzc2luZyBpbiB0aGUgc2FtZSB3YXkg
dGhhdCB5b3Ugd291bGQgdG9kYXkgYW5kIElDTVAgd291bGQganVzdApjb21lIGluIHRoZSByaWdo
dCBjYXNlcy4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
ZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5v
cmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
