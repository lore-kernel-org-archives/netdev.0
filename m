From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xen-netfront: Fix Rx stall during
 network stress and OOM
Date: Wed, 18 Jan 2017 15:08:39 -0500 (EST)
Message-ID: <20170118.150839.1789577551975200722.davem@davemloft.net>
References: <1484330100-3960-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
 <ee87b2e4-de8c-7b9b-c4e5-854ffab2e554@suse.com>
 <79c6ecce-bfcb-ebaa-afd2-05c1d86004d7@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: jgross@suse.com, netdev@vger.kernel.org, kamatam@amazon.com,
 linux-kernel@vger.kernel.org, aliguori@amazon.com,
 xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com
To: vineethp@amazon.com
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <79c6ecce-bfcb-ebaa-afd2-05c1d86004d7@amazon.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

RnJvbTogVmluZWV0aCBSZW1hbmFuIFBpbGxhaSA8dmluZWV0aHBAYW1hem9uLmNvbT4KRGF0ZTog
V2VkLCAxOCBKYW4gMjAxNyAwOTowMjoxNyAtMDgwMAoKPiAKPiBPbiAwMS8xNS8yMDE3IDEwOjI0
IFBNLCBKdWVyZ2VuIEdyb3NzIHdyb3RlOgo+PiBPbiAxMy8wMS8xNyAxODo1NSwgUmVtYW5hbiBQ
aWxsYWkgd3JvdGU6Cj4+PiBGcm9tOiBWaW5lZXRoIFJlbWFuYW4gUGlsbGFpIDx2aW5lZXRocEBh
bWF6b24uY29tPgo+Pj4KPj4+IER1cmluZyBhbiBPT00gc2NlbmFyaW8sIHJlcXVlc3Qgc2xvdHMg
Y291bGQgbm90IGJlIGNyZWF0ZWQgYXMgc2tiCj4+PiBhbGxvY2F0aW9uIGZhaWxzLiBTbyB0aGUg
bmV0YmFjayBjYW5ub3QgcGFzcyBpbiBwYWNrZXRzIGFuZCBuZXRmcm9udAo+Pj4gd3JvbmdseSBh
c3N1bWVzIHRoYXQgdGhlcmUgaXMgbm8gbW9yZSB3b3JrIHRvIGJlIGRvbmUgYW5kIGl0IGRpc2Fi
bGVzCj4+PiBwb2xsaW5nLiBUaGlzIGNhdXNlcyBSeCB0byBzdGFsbC4KPj4+Cj4+PiBUaGUgaXNz
dWUgaXMgd2l0aCB0aGUgcmV0cnkgbG9naWMgd2hpY2ggc2NoZWR1bGVzIHRoZSB0aW1lciBpZiB0
aGUKPj4+IGNyZWF0ZWQgc2xvdHMgYXJlIGxlc3MgdGhhbiBORVRfUlhfU0xPVFNfTUlOLiBUaGUg
Y291bnQgb2YgbmV3IHJlcXVlc3QKPj4+IHNsb3RzIHRvIGJlIHB1c2hlZCBhcmUgY2FsY3VsYXRl
ZCBhcyBhIGRpZmZlcmVuY2UgYmV0d2VlbiBuZXcgcmVxX3Byb2QKPj4+IGFuZCByc3BfY29ucyB3
aGljaCBjb3VsZCBiZSBtb3JlIHRoYW4gdGhlIGFjdHVhbCBzbG90cywgaWYgdGhlcmUgYXJlCj4+
PiB1bmNvbnN1bWVkIHJlc3BvbnNlcy4KPj4+Cj4+PiBUaGUgZml4IGlzIHRvIGNhbGN1bGF0ZSB0
aGUgY291bnQgb2YgbmV3bHkgY3JlYXRlZCBzbG90cyBhcyB0aGUKPj4+IGRpZmZlcmVuY2UgYmV0
d2VlbiBuZXcgcmVxX3Byb2QgYW5kIG9sZCByZXFfcHJvZC4KPj4+Cj4+PiBTaWduZWQtb2ZmLWJ5
OiBWaW5lZXRoIFJlbWFuYW4gUGlsbGFpIDx2aW5lZXRocEBhbWF6b24uY29tPgo+PiBSZXZpZXdl
ZC1ieTogSnVlcmdlbiBHcm9zcyA8amdyb3NzQHN1c2UuY29tPgo+IFRoYW5rcyBKdWVyZ2VuLgo+
IAo+IERhdmlkLAo+IAo+IENvdWxkIHlvdSBwbGVhc2UgcGljayB1cCB0aGlzIGNoYW5nZSBmb3Ig
bmV0LW5leHQgaWYgdGhlcmUgbm8gbW9yZQo+IGNvbmNlcm5zLi4KCldoeSB3b3VsZCBJIHBpY2sg
dXAgInRoaXMgY2hhbmdlIiwgaWYgdGhlIGF1dGhvciBvZiB0aGUgcGF0Y2ggaGFzCnN0YXRlZCB0
aGF0IGhlIHdpbGwgcmVzdWJtaXQgdGhlIGNoYW5nZSBpbXBsZW1lbnRlZCBkaWZmZXJlbnRseSBi
YXNlZAp1cG9uIG15IGZlZWRiYWNrPwoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KWGVuLWRldmVsIG1haWxpbmcgbGlzdApYZW4tZGV2ZWxAbGlzdHMueGVu
Lm9yZwpodHRwczovL2xpc3RzLnhlbi5vcmcveGVuLWRldmVsCg==
