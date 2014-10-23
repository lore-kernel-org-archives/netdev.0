From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATHC] net: napi_reuse_skb() should check
	pfmemalloc
Date: Thu, 23 Oct 2014 17:49:30 +0400
Message-ID: <1131414072170@webcorp02e.yandex-team.ru>
References: <1413985819-9553-1-git-send-email-klamm@yandex-team.ru>
	<1413992737.9031.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<1811414063272@webcorp02e.yandex-team.ru>
	<1414071030.2094.46.camel@edumazet-glaptop2.roam.corp.google.com>
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
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1414071030.2094.46.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

U2lnbmVkLW9mZi1ieTogUm9tYW4gR3VzaGNoaW4gPGtsYW1tQHlhbmRleC10ZWFtLnJ1PgoKLS0K
QGtsYW1tCgoKMjMuMTAuMjAxNCwgMTc6MzAsICJFcmljIER1bWF6ZXQiIDxlcmljLmR1bWF6ZXRA
Z21haWwuY29tPjoKPiBGcm9tOiBFcmljIER1bWF6ZXQgPGVkdW1hemV0QGdvb2dsZS5jb20+Cj4K
PiBEbyBub3QgcmV1c2Ugc2tiIGlmIGl0IHdhcyBwZm1lbWFsbG9jIHRhaW50ZWQsIG90aGVyd2lz
ZQo+IGZ1dHVyZSBmcmFtZSBtaWdodCBiZSBkcm9wcGVkIGFueXdheS4KPgo+IFNpZ25lZC1vZmYt
Ynk6IEVyaWMgRHVtYXpldCA8ZWR1bWF6ZXRAZ29vZ2xlLmNvbT4KPiAtLS0KPiCabmV0L2NvcmUv
ZGV2LmMgfCCampo0ICsrKysKPiCaMSBmaWxlIGNoYW5nZWQsIDQgaW5zZXJ0aW9ucygrKQo+Cj4g
ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2Rldi5jIGIvbmV0L2NvcmUvZGV2LmMKPiBpbmRleCBiNzkz
ZTM1MjFhMzYuLjk0NWJiZDAwMTM1OSAxMDA2NDQKPiAtLS0gYS9uZXQvY29yZS9kZXYuYwo+ICsr
KyBiL25ldC9jb3JlL2Rldi5jCj4gQEAgLTQxNTcsNiArNDE1NywxMCBAQCBFWFBPUlRfU1lNQk9M
KG5hcGlfZ3JvX3JlY2VpdmUpOwo+Cj4gmnN0YXRpYyB2b2lkIG5hcGlfcmV1c2Vfc2tiKHN0cnVj
dCBuYXBpX3N0cnVjdCAqbmFwaSwgc3RydWN0IHNrX2J1ZmYgKnNrYikKPiCaewo+ICsgaWYgKHVu
bGlrZWx5KHNrYi0+cGZtZW1hbGxvYykpIHsKPiArIGNvbnN1bWVfc2tiKHNrYik7Cj4gKyByZXR1
cm47Cj4gKyB9Cj4gmpqampqampqaX19za2JfcHVsbChza2IsIHNrYl9oZWFkbGVuKHNrYikpOwo+
IJqampqampqami8qIHJlc3RvcmUgdGhlIHJlc2VydmUgd2UgaGFkIGFmdGVyIG5ldGRldl9hbGxv
Y19za2JfaXBfYWxpZ24oKSAqLwo+IJqampqampqamnNrYl9yZXNlcnZlKHNrYiwgTkVUX1NLQl9Q
QUQgKyBORVRfSVBfQUxJR04gLSBza2JfaGVhZHJvb20oc2tiKSk7CgotLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KRTEw
MDAtZGV2ZWwgbWFpbGluZyBsaXN0CkUxMDAwLWRldmVsQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApo
dHRwczovL2xpc3RzLnNvdXJjZWZvcmdlLm5ldC9saXN0cy9saXN0aW5mby9lMTAwMC1kZXZlbApU
byBsZWFybiBtb3JlIGFib3V0IEludGVsJiMxNzQ7IEV0aGVybmV0LCB2aXNpdCBodHRwOi8vY29t
bXVuaXRpZXMuaW50ZWwuY29tL2NvbW11bml0eS93aXJlZAo=
