From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH 4/4] drm/i915: Move ioremap_wc tracking onto
 VMA
Date: Thu, 21 Apr 2016 09:27:39 +0200
Message-ID: <20160421072739.GV2510@phenom.ffwll.local>
References: <20160419123028.GI1990@wotan.suse.de>
 <1461069238-31539-1-git-send-email-chris@chris-wilson.co.uk>
 <1461069238-31539-4-git-send-email-chris@chris-wilson.co.uk>
 <20160420091054.GL1990@wotan.suse.de>
 <20160420111730.GL2510@phenom.ffwll.local>
 <20160420212727.GS1990@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Hildenbrand <dahi@linux.vnet.ibm.com>,
 David Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
 intel-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org,
 "Peter Zijlstra \(Intel\)" <peterz@infradead.org>,
 Daniel Vetter <daniel.vetter@intel.com>,
 Dan Williams <dan.j.williams@intel.com>, Yishai Hadas <yishaih@mellanox.com>,
 Ingo Molnar <mingo@kernel.org>, linux-rdma@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20160420212727.GS1990@wotan.suse.de>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

T24gV2VkLCBBcHIgMjAsIDIwMTYgYXQgMTE6Mjc6MjdQTSArMDIwMCwgTHVpcyBSLiBSb2RyaWd1
ZXogd3JvdGU6Cj4gT24gV2VkLCBBcHIgMjAsIDIwMTYgYXQgMDE6MTc6MzBQTSArMDIwMCwgRGFu
aWVsIFZldHRlciB3cm90ZToKPiA+IE9uIFdlZCwgQXByIDIwLCAyMDE2IGF0IDExOjEwOjU0QU0g
KzAyMDAsIEx1aXMgUi4gUm9kcmlndWV6IHdyb3RlOgo+ID4gPiBSZWFzb24gSSBhc2sgaXMgc2lu
Y2UgSSBub3RpY2VkIGEgd2hpbGUgYWdvIGEgbG90IG9mIGRyaXZlcnMKPiA+ID4gd2VyZSB1c2lu
ZyBpbmZvLT5maXguc21lbV9zdGFydCBhbmQgaW5mby0+Zml4LnNtZW1fbGVuIGNvbnNpc3RlbnRs
eQo+ID4gPiBmb3IgdGhlaXIgaW9yZW1hcCdkIGFyZWFzIGl0IG1pZ2h0IG1ha2Ugc2Vuc2UgaW5z
dGVhZCB0byBsZXQgdGhlCj4gPiA+IGludGVybmFsIGZyYW1lYnVmZmVyIChyZWdpc3Rlcl9mcmFt
ZWJ1ZmZlcigpKSBvcHRpb25hbGx5IG1hbmFnZSB0aGUKPiA+ID4gaW9yZW1hcF93YygpIGZvciBk
cml2ZXJzLCBnaXZlbiB0aGF0IHRoaXMgaXMgcHJldHR5IGdlbmVyaWMgc3R1ZmYuCj4gPiAKPiA+
IEFsbCB0aGF0IGxlZ2FjeSBmYmRldiBzdHVmZiBpcyBqdXN0IGZvciBsZWdhY3kgc3VwcG9ydCwg
YW5kIEkgcHJlZmVyIHRvCj4gPiBoYXZlIHRoYXQgYXMgZHVtYiBhcyBwb3NzaWJsZS4gVGhlcmUn
cyBiZWVuIHNvbWUgZGlzY3Vzc2lvbiBldmVuIGFyb3VuZAo+ID4gbGlmdGluZyB0aGUgImtpY2sg
b3V0IGZpcm13YXJlIGZiIGRyaXZlciIgb3V0IG9mIGZiZGV2LCBzaW5jZSB3ZSdkIG5lZWQgaXQK
PiA+IHRvIGhhdmUgYSBzaW1wbGUgZHJtIGRyaXZlciBmb3IgZS5nLiB1ZWZpLgo+ID4gCj4gPiBC
dXQgSSBkZWZpbml0ZWx5IGRvbid0IHdhbnQgYSBsZWdhY3kgaG9ycm9yIHNob3cgbGlrZSBmYmRl
diB0bwo+ID4gYXV0b21hZ2ljYWxseSB0YWtlIGNhcmUgb2YgZGV2aWNlIG1hcHBpbmdzIGZvciBk
cml2ZXJzLgo+IAo+IE1ha2VzIHNlbnNlLCBpdCBhbHNvIHN0aWxsIGJlZ3MgdGhlIHF1ZXN0aW9u
IGlmIG1vcmUgbW9kZXJuIEFQSXMKPiBjb3VsZCBtYW5hZ2UgdGhlIGlvcmVtYXAgZm9yIHlvdS4g
RXZpZGVuY2Ugc2hvd3MgcGVvcGxlIGdldAo+IHNsb3BweSBhbmQgaWYgdGhpbmdzIHdlcmUgZG9u
ZSBpbnRlcm5hbGx5IHdpdGggaGVscGVycyBpdCBtYXkKPiBiZSBlYXNpZXIgdG8gbGF0ZXIgbWFr
ZSBhZGp1c3RtZW50cy4KClJlYWwgZ3B1cyBnZW5lcmFsbHkgaGF2ZSBzbyBtdWNoIG1taW8gc3Bh
Y2UgdGhhdCB5b3Ugd2FudCB0byBpb3JlbWFwIHRoZW0Kb24gZGVtYW5kLiBBdCBsZWFzdCBpZiB5
b3Ugc3RpbGwgY2FyZSBhYm91dCAzMmJpdCBzdXBwb3J0LiBBbmQgb24tZGllIGdwdXMKb24gc29j
cyBvciBzaW1pbGFyIHRlbmQgdG8gbm90IGhhdmUgYW4gbW1pbyByYW5nZSB0byBhY2Nlc3MgdGhl
IGdmeApyZW1hcHBpbmcgcmFuZ2UgYXQgYWxsLCBidXQgaW5zdGVhZCBleHBlY3QgdGhhdCB0byBi
ZSBkb25lIHdpdGggZ3B1CnBhZ2V0YWJsZXMuCgpTbyBhdCBsZWFzdCB3aXRoIGdwdXMgSSBkb24n
dCBzZWUgYSByZWFsIGRlbWFuZCBmb3IgdGhpcywgYW5kIHRoZSBleGlzdGluZwp1c2VycyBhcmUg
bW9zdGx5IG9sZCBmYmRldiBkcml2ZXJzIHRoYXQgcmVhbGx5IG5vIG9uZSBzaG91bGQgYmUgdG91
Y2hpbmcKOy0pCgpDaGVlcnMsIERhbmllbAotLSAKRGFuaWVsIFZldHRlcgpTb2Z0d2FyZSBFbmdp
bmVlciwgSW50ZWwgQ29ycG9yYXRpb24KaHR0cDovL2Jsb2cuZmZ3bGwuY2gKX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KSW50ZWwtZ2Z4IG1haWxpbmcgbGlz
dApJbnRlbC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBzOi8vbGlzdHMuZnJlZWRlc2t0
b3Aub3JnL21haWxtYW4vbGlzdGluZm8vaW50ZWwtZ2Z4Cg==
