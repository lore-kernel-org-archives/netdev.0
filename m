From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V4 0/6] switch to use tx skb array in tun
Date: Fri, 8 Jul 2016 17:14:19 +0800
Message-ID: <577F6EEB.9080908@redhat.com>
References: <CAEfhGixKLfLOj11ERgPhpVB+UXbqxrvkQKgQgn19bDjroO_4dQ@mail.gmail.com>
	<20160708091855-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: kvm@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org, brouer@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>, Craig Gallek <kraigatgoog@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160708091855-mutt-send-email-mst@redhat.com>
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

CgpPbiAyMDE25bm0MDfmnIgwOOaXpSAxNDoxOSwgTWljaGFlbCBTLiBUc2lya2luIHdyb3RlOgo+
IE9uIFdlZCwgSnVsIDA2LCAyMDE2IGF0IDAxOjQ1OjU4UE0gLTA0MDAsIENyYWlnIEdhbGxlayB3
cm90ZToKPj4gPk9uIFRodSwgSnVuIDMwLCAyMDE2IGF0IDI6NDUgQU0sIEphc29uIFdhbmc8amFz
b3dhbmdAcmVkaGF0LmNvbT4gIHdyb3RlOgo+Pj4gPiA+SGkgYWxsOgo+Pj4gPiA+Cj4+PiA+ID5U
aGlzIHNlcmllcyB0cmllcyB0byBzd2l0Y2ggdG8gdXNlIHNrYiBhcnJheSBpbiB0dW4uIFRoaXMg
aXMgdXNlZCB0bwo+Pj4gPiA+ZWxpbWluYXRlIHRoZSBzcGlubG9jayBjb250ZW50aW9uIGJldHdl
ZW4gcHJvZHVjZXIgYW5kIGNvbnN1bWVyLiBUaGUKPj4+ID4gPmNvbnZlcnNpb24gd2FzIHN0cmFp
Z2h0Zm9yd2FyZDoganVzdCBpbnRyb2RjZSBhIHR4IHNrYiBhcnJheSBhbmQgdXNlCj4+PiA+ID5p
dCBpbnN0ZWFkIG9mIHNrX3JlY2VpdmVfcXVldWUuCj4+ID4KPj4gPkknbSBzZWVpbmcgdGhlIHNw
bGF0IGJlbG93IGFmdGVyIHRoaXMgc2VyaWVzLiAgSSdtIHN0aWxsIHdyYXBwaW5nIG15Cj4+ID5o
ZWFkIGFyb3VuZCB0aGlzIGNvZGUsIGJ1dCBpdCBhcHBlYXJzIHRvIGJlIGhhcHBlbmluZyBiZWNh
dXNlIHRoZQo+PiA+dHVuX3N0cnVjdCBwYXNzZWQgaW50byB0dW5fcXVldWVfcmVzaXplIGlzIHVu
aW5pdGlhbGl6ZWQuCj4+ID5TcGVjaWZpY2FsbHksIGl0ZXJhdGlvbiBvdmVyIHRoZSBkaXNhYmxl
ZCBsaXN0X2hlYWQgZmFpbHMgYmVjYXVzZSBwcmV2Cj4+ID49IG5leHQgPSBOVUxMLiAgVGhpcyBz
ZWVtcyB0byBoYXBwZW4gd2hlbiBhIHN0YXJ0dXAgc2NyaXB0IG9uIG15IHRlc3QKPj4gPm1hY2hp
bmUgY2hhbmdlcyB0aGUgcXVldWUgbGVuZ3RoLiAgSSdsbCB0cnkgdG8gZmlndXJlIG91dCB3aGF0
J3MKPj4gPmhhcHBlbmluZywgYnV0IGlmIGl0J3Mgb2J2aW91cyB0byBzb21lb25lIGVsc2UgZnJv
bSB0aGUgc3RhY2ssIHBsZWFzZQo+PiA+bGV0IG1lIGtub3cuCj4gRG9uJ3Qgc2VlIGFueXRoaW5n
IG9idmlvdXMuIEknbSB0cmF2ZWxpbmcsIHdpbGwgbG9vayBhdCBpdCB3aGVuIEknbSBiYWNrCj4g
dW5sZXNzIGl0J3MgZml4ZWQgYnkgdGhlbi4gSmFzb24sIGFueSBpZGVhPwo+CgpMb29rcyBsaWtl
IENyYWlnIGhhcyBwb3N0ZWQgYSBmaXggdG8gdGhpczoKCmh0dHA6Ly9wYXRjaHdvcmsub3psYWJz
Lm9yZy9wYXRjaC82NDU2NDUvCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fClZpcnR1YWxpemF0aW9uIG1haWxpbmcgbGlzdApWaXJ0dWFsaXphdGlvbkBsaXN0
cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcv
bWFpbG1hbi9saXN0aW5mby92aXJ0dWFsaXphdGlvbg==
