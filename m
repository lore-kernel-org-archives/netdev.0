From: Vineeth Remanan Pillai <vineethp@amazon.com>
Subject: Re: [PATCH v2] xen-netfront: Fix Rx stall during
 network stress and OOM
Date: Wed, 18 Jan 2017 09:02:17 -0800
Message-ID: <79c6ecce-bfcb-ebaa-afd2-05c1d86004d7@amazon.com>
References: <0cb06b48-cb3c-47aa-2ae6-3a70197a5b64@amazon.com>
 <1484330100-3960-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
 <ee87b2e4-de8c-7b9b-c4e5-854ffab2e554@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: kamatam@amazon.com, vineethp@amazon.com, aliguori@amazon.com
To: Juergen Gross <jgross@suse.com>, David Miller <davem@davemloft.net>,
 <boris.ostrovsky@oracle.com>, <xen-devel@lists.xenproject.org>,
 <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <ee87b2e4-de8c-7b9b-c4e5-854ffab2e554@suse.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

Ck9uIDAxLzE1LzIwMTcgMTA6MjQgUE0sIEp1ZXJnZW4gR3Jvc3Mgd3JvdGU6Cj4gT24gMTMvMDEv
MTcgMTg6NTUsIFJlbWFuYW4gUGlsbGFpIHdyb3RlOgo+PiBGcm9tOiBWaW5lZXRoIFJlbWFuYW4g
UGlsbGFpIDx2aW5lZXRocEBhbWF6b24uY29tPgo+Pgo+PiBEdXJpbmcgYW4gT09NIHNjZW5hcmlv
LCByZXF1ZXN0IHNsb3RzIGNvdWxkIG5vdCBiZSBjcmVhdGVkIGFzIHNrYgo+PiBhbGxvY2F0aW9u
IGZhaWxzLiBTbyB0aGUgbmV0YmFjayBjYW5ub3QgcGFzcyBpbiBwYWNrZXRzIGFuZCBuZXRmcm9u
dAo+PiB3cm9uZ2x5IGFzc3VtZXMgdGhhdCB0aGVyZSBpcyBubyBtb3JlIHdvcmsgdG8gYmUgZG9u
ZSBhbmQgaXQgZGlzYWJsZXMKPj4gcG9sbGluZy4gVGhpcyBjYXVzZXMgUnggdG8gc3RhbGwuCj4+
Cj4+IFRoZSBpc3N1ZSBpcyB3aXRoIHRoZSByZXRyeSBsb2dpYyB3aGljaCBzY2hlZHVsZXMgdGhl
IHRpbWVyIGlmIHRoZQo+PiBjcmVhdGVkIHNsb3RzIGFyZSBsZXNzIHRoYW4gTkVUX1JYX1NMT1RT
X01JTi4gVGhlIGNvdW50IG9mIG5ldyByZXF1ZXN0Cj4+IHNsb3RzIHRvIGJlIHB1c2hlZCBhcmUg
Y2FsY3VsYXRlZCBhcyBhIGRpZmZlcmVuY2UgYmV0d2VlbiBuZXcgcmVxX3Byb2QKPj4gYW5kIHJz
cF9jb25zIHdoaWNoIGNvdWxkIGJlIG1vcmUgdGhhbiB0aGUgYWN0dWFsIHNsb3RzLCBpZiB0aGVy
ZSBhcmUKPj4gdW5jb25zdW1lZCByZXNwb25zZXMuCj4+Cj4+IFRoZSBmaXggaXMgdG8gY2FsY3Vs
YXRlIHRoZSBjb3VudCBvZiBuZXdseSBjcmVhdGVkIHNsb3RzIGFzIHRoZQo+PiBkaWZmZXJlbmNl
IGJldHdlZW4gbmV3IHJlcV9wcm9kIGFuZCBvbGQgcmVxX3Byb2QuCj4+Cj4+IFNpZ25lZC1vZmYt
Ynk6IFZpbmVldGggUmVtYW5hbiBQaWxsYWkgPHZpbmVldGhwQGFtYXpvbi5jb20+Cj4gUmV2aWV3
ZWQtYnk6IEp1ZXJnZW4gR3Jvc3MgPGpncm9zc0BzdXNlLmNvbT4KVGhhbmtzIEp1ZXJnZW4uCgpE
YXZpZCwKCkNvdWxkIHlvdSBwbGVhc2UgcGljayB1cCB0aGlzIGNoYW5nZSBmb3IgbmV0LW5leHQg
aWYgdGhlcmUgbm8gbW9yZSAKY29uY2VybnMuLgoKTWFueSBUaGFua3MsClZpbmVldGgKCj4KPgo+
IFRoYW5rcywKPgo+IEp1ZXJnZW4KPgoKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fClhlbi1kZXZlbCBtYWlsaW5nIGxpc3QKWGVuLWRldmVsQGxpc3RzLnhl
bi5vcmcKaHR0cHM6Ly9saXN0cy54ZW4ub3JnL3hlbi1kZXZlbAo=
