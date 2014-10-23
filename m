From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH] igb: don't reuse pages with pfmemalloc
	flag
Date: Thu, 23 Oct 2014 11:52:03 +0400
Message-ID: <4321414050723@webcorp02h.yandex-team.ru>
References: <1413985819-9553-1-git-send-email-klamm@yandex-team.ru>
	<1414002630.2179.0.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Content-Transfer-Encoding: base64
Cc: "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sassmann@kpanic.de" <sassmann@kpanic.de>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"peter.p.waskiewicz.jr@intel.com" <peter.p.waskiewicz.jr@intel.com>,
	"bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"john.ronciak@intel.com" <john.ronciak@intel.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1414002630.2179.0.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

VGhhbmsgeW91IQoKUHJvYmFibHkgd2Ugc2hvdWxkIGFkZCBpdCB0byBzdGFibGUgdHJlZXMgdG9v
PwoKLS0KUmVnYXJkcywKUm9tYW4KCjIyLjEwLjIwMTQsIDIyOjMwLCAiSmVmZiBLaXJzaGVyIiA8
amVmZnJleS50LmtpcnNoZXJAaW50ZWwuY29tPjoKPiBPbiBXZWQsIDIwMTQtMTAtMjIgYXQgMTc6
NTAgKzA0MDAsIFJvbWFuIEd1c2hjaGluIHdyb3RlOgo+PiCaSW5jb21pbmcgcGFja2V0IGlzIGRy
b3BwZWQgc2lsZW50bHkgYnkgc2tfZmlsdGVyKCksIGlmIHRoZSBza2Igd2FzCj4+IJphbGxvY2F0
ZWQgZnJvbSBwZm1lbWFsbG9jIHJlc2VydmVzIGFuZCB0aGUgY29ycmVzcG9uZGluZyBzb2NrZXQg
aXMKPj4gmm5vdCBtYXJrZWQgd2l0aCB0aGUgU09DS19NRU1BTExPQyBmbGFnLgo+Pgo+PiCaSWdi
IGRyaXZlciBhbGxvY2F0ZXMgcGFnZXMgZm9yIERNQSB3aXRoIF9fc2tiX2FsbG9jX3BhZ2UoKSwg
d2hpY2gKPj4gmmNhbGxzIGFsbG9jX3BhZ2VzX25vZGUoKSB3aXRoIHRoZSBfX0dGUF9NRU1BTExP
QyBmbGFnLiBTbywgaW4gY2FzZQo+PiCab2YgT09NIGNvbmRpdGlvbiwgaWdiIGNhbiBnZXQgcGFn
ZXMgd2l0aCBwZm1lbWFsbG9jIGZsYWcgc2V0Lgo+Pgo+PiCaSWYgYW4gaW5jb21pbmcgcGFja2V0
IGhpdHMgdGhlIHBmbWVtYWxsb2MgcGFnZSBhbmQgaXMgbGFyZ2UgZW5vdWdoCj4+IJooc21hbGwg
cGFja2V0cyBhcmUgY29weWluZyBpbnRvIHRoZSBtZW1vcnksIGFsbG9jYXRlZCB3aXRoCj4+IJpu
ZXRkZXZfYWxsb2Nfc2tiX2lwX2FsaWduKCksIHNvIHRoZXkgYXJlIG5vdCBhZmZlY3RlZCksIGl0
IHdpbGwgYmUKPj4gmmRyb3BwZWQuCj4+Cj4+IJpUaGlzIGJlaGF2aW9yIGlzIG9rIHVuZGVyIGhp
Z2ggbWVtb3J5IHByZXNzdXJlLCBidXQgdGhlIHByb2JsZW0gaXMKPj4gmnRoYXQgdGhlIGlnYiBk
cml2ZXIgcmV1c2VzIHRoZXNlIG1hcHBlZCBwYWdlcy4gU28sIHBhY2tldHMgYXJlIHN0aWxsCj4+
IJpkcm9wcGluZyBldmVuIGlmIGFsbCBtZW1vcnkgaXNzdWVzIGFyZSBnb25lIGFuZCB0aGVyZSBp
cyBhIHBsZW50eQo+PiCab2YgZnJlZSBtZW1vcnkuCj4+Cj4+IJpJbiBteSBjYXNlLCBzb21lIFRD
UCBzZXNzaW9ucyBoYW5nIG9uIGEgc21hbGwgcGVyY2VudGFnZSAoPCAwLjElKQo+PiCab2YgbWFj
aGluZXMgZGF5cyBhZnRlciBPT01zLgo+Pgo+PiCaRml4IHRoaXMgYnkgYXZvaWRpbmcgcmV1c2Ug
b2Ygc3VjaCBwYWdlcy4KPj4KPj4gmlNpZ25lZC1vZmYtYnk6IFJvbWFuIEd1c2hjaGluIDxrbGFt
bUB5YW5kZXgtdGVhbS5ydT4KPj4gmi0tLQo+PiCammRyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVs
L2lnYi9pZ2JfbWFpbi5jIHwgNiArKysrKy0KPj4gmpoxIGZpbGUgY2hhbmdlZCwgNSBpbnNlcnRp
b25zKCspLCAxIGRlbGV0aW9uKC0pCj4KPiBUaGFua3MgUm9tYW4sIEkgaGF2ZSBhZGRlZCB5b3Ug
cGF0Y2ggdG8gbXkgcXVldWUuCgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KRTEwMDAtZGV2ZWwgbWFpbGluZyBsaXN0
CkUxMDAwLWRldmVsQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRwczovL2xpc3RzLnNvdXJjZWZv
cmdlLm5ldC9saXN0cy9saXN0aW5mby9lMTAwMC1kZXZlbApUbyBsZWFybiBtb3JlIGFib3V0IElu
dGVsJiMxNzQ7IEV0aGVybmV0LCB2aXNpdCBodHRwOi8vY29tbXVuaXRpZXMuaW50ZWwuY29tL2Nv
bW11bml0eS93aXJlZAo=
