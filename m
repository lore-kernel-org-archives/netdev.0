From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V4 0/6] switch to use tx skb array in tun
Date: Fri, 1 Jul 2016 14:04:01 +0800
Message-ID: <577607D1.9070307@redhat.com>
References: <1467269136-8082-1-git-send-email-jasowang@redhat.com>
	<20160630184242-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: kvm@vger.kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, brouer@redhat.com,
	davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160630184242-mutt-send-email-mst@redhat.com>
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

CgpPbiAyMDE25bm0MDbmnIgzMOaXpSAyMzo0NSwgTWljaGFlbCBTLiBUc2lya2luIHdyb3RlOgo+
IE9uIFRodSwgSnVuIDMwLCAyMDE2IGF0IDAyOjQ1OjMwUE0gKzA4MDAsIEphc29uIFdhbmcgd3Jv
dGU6Cj4+ID5IaSBhbGw6Cj4+ID4KPj4gPlRoaXMgc2VyaWVzIHRyaWVzIHRvIHN3aXRjaCB0byB1
c2Ugc2tiIGFycmF5IGluIHR1bi4gVGhpcyBpcyB1c2VkIHRvCj4+ID5lbGltaW5hdGUgdGhlIHNw
aW5sb2NrIGNvbnRlbnRpb24gYmV0d2VlbiBwcm9kdWNlciBhbmQgY29uc3VtZXIuIFRoZQo+PiA+
Y29udmVyc2lvbiB3YXMgc3RyYWlnaHRmb3J3YXJkOiBqdXN0IGludHJvZGNlIGEgdHggc2tiIGFy
cmF5IGFuZCB1c2UKPj4gPml0IGluc3RlYWQgb2Ygc2tfcmVjZWl2ZV9xdWV1ZS4KPj4gPgo+PiA+
QSBtaW5vciBpc3N1ZSBpcyB0byBrZWVwIHRoZSB0eF9xdWV1ZV9sZW4gYmVoYXZpb3VyLCBzaW5j
ZSB0dW4gdXNlZCB0bwo+PiA+dXNlIGl0IGZvciB0aGUgbGVuZ3RoIG9mIHNrX3JlY2VpdmVfcXVl
dWUuIFRoaXMgaXMgZG9uZSB0aHJvdWdoOgo+PiA+Cj4+ID4tIGFkZCB0aGUgYWJpbGl0eSB0byBy
ZXNpemUgbXVsdGlwbGUgcmluZ3MgYXQgb25jZSB0byBhdm9pZCBoYW5kbGluZwo+PiA+ICAgcGFy
dGlhbCByZXNpemUgZmFpbHVyZSBmb3IgbXV0aXBsZSByaW5ncy4KPj4gPi0gYWRkIHRoZSBzdXBw
b3J0IGZvciB6ZXJvIGxlbmd0aCByaW5nLgo+PiA+LSBpbnRyb2R1Y2UgYSBub3RpZmllciB3aGlj
aCB3YXMgdHJpZ2dlcmVkIHdoZW4gdHhfcXVldWVfbGVuIHdhcwo+PiA+ICAgY2hhbmdlZCBmb3Ig
YSBuZXRkZXYuCj4+ID4tIHJlc2l6ZSBhbGwgcXVldWVzIGR1cmluZyB0aGUgdHhfcXVldWVfbGVu
IGNoYW5naW5nLgo+PiA+Cj4+ID5UZXN0cyBzaG93cyBhYm91dCAxNSUgaW1wcm92ZW1lbnQgb24g
Z3Vlc3QgcnggcHBzOgo+PiA+Cj4+ID5CZWZvcmU6IH4xMzAwMDAwcHBzCj4+ID5BZnRlciA6IH4x
NTAwMDAwcHBzCj4gQWNrZWQtYnk6IE1pY2hhZWwgUy4gVHNpcmtpbjxtc3RAcmVkaGF0LmNvbT4K
Pgo+IEFja2VkLWZyb20tYWx0aXR1ZGU6IDM0Njk3IGZlZXQuCgpXb3csIHRoYW5rcyBhIGxvdCEK
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KVmlydHVhbGl6
YXRpb24gbWFpbGluZyBsaXN0ClZpcnR1YWxpemF0aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24u
b3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3Zp
cnR1YWxpemF0aW9u
