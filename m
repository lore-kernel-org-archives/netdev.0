From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 7/8] vhost_net: try batch dequing from skb array
Date: Thu, 30 Mar 2017 00:47:33 +0300
Message-ID: <20170330004654-mutt-send-email-mst@kernel.org>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
	<1490069087-4783-8-git-send-email-jasowang@redhat.com>
	<20170322155111-mutt-send-email-mst@kernel.org>
	<f41bb12f-10d6-9fb2-1cd2-76e3e9460aff@redhat.com>
	<bf511f4a-b1d0-d732-a01e-9cd4b8ae6817@redhat.com>
	<674632255.8752546.1490784387956.JavaMail.zimbra@redhat.com>
	<cea3d380-389e-d258-915a-3d4f60232535@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Pankaj Gupta <pagupta@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cea3d380-389e-d258-915a-3d4f60232535@redhat.com>
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

T24gV2VkLCBNYXIgMjksIDIwMTcgYXQgMDY6NTM6MjdQTSArMDgwMCwgSmFzb24gV2FuZyB3cm90
ZToKPiAKPiAKPiBPbiAyMDE35bm0MDPmnIgyOeaXpSAxODo0NiwgUGFua2FqIEd1cHRhIHdyb3Rl
Ogo+ID4gSGkgSmFzb24sCj4gPiAKPiA+ID4gT24gMjAxN+W5tDAz5pyIMjPml6UgMTM6MzQsIEph
c29uIFdhbmcgd3JvdGU6Cj4gPiA+ID4gCj4gPiA+ID4gPiA+ICt7Cj4gPiA+ID4gPiA+ICsgICAg
aWYgKHJ2cS0+cmggIT0gcnZxLT5ydCkKPiA+ID4gPiA+ID4gKyAgICAgICAgZ290byBvdXQ7Cj4g
PiA+ID4gPiA+ICsKPiA+ID4gPiA+ID4gKyAgICBydnEtPnJoID0gcnZxLT5ydCA9IDA7Cj4gPiA+
ID4gPiA+ICsgICAgcnZxLT5ydCA9IHNrYl9hcnJheV9jb25zdW1lX2JhdGNoZWRfYmgocnZxLT5y
eF9hcnJheSwgcnZxLT5yeHEsCj4gPiA+ID4gPiA+ICsgICAgICAgICAgICAgICAgICAgICAgICBW
SE9TVF9SWF9CQVRDSCk7Cj4gPiA+ID4gPiBBIGNvbW1lbnQgZXhwbGFpbmluZyB3aHkgaXMgaXMg
LWJoIHdvdWxkIGJlIGhlbHBmdWwuCj4gPiA+ID4gT2suCj4gPiA+ID4gCj4gPiA+ID4gVGhhbmtz
Cj4gPiA+IFJldGhpbmsgYWJvdXQgdGhpcy4gSXQgbG9va3MgbGlrZSAtYmggaXMgbm90IG5lZWRl
ZCBpbiB0aGlzIGNhc2Ugc2luY2UKPiA+ID4gbm8gY29uc3VtZXIgcnVuIGluIGJoLgo+ID4gSW4g
dGhhdCBjYXNlIGRvIHdlIG5lZWQgb3RoZXIgdmFyaWFudHMgb2YgInB0cl9yaW5nX2NvbnN1bWVf
YmF0Y2hlZF8qKCkiIGZ1bmN0aW9ucy4KPiA+IEFyZSB3ZSBwbGFubmluZyB0byB1c2UgdGhlbSBp
biBmdXR1cmU/Cj4gCj4gSSB0aGluayB3ZSdkIGJldHRlciBrZWVwIHRoZW0sIHNpbmNlIGl0IHNl
cnZlcyBhcyBoZWxwZXJzLiBZb3UgY2FuIHNlZSB0aGF0Cj4gbm90IGFsbCB0aGUgaGVscGVycyBp
biBwdHJfcmluZyBoYXMgcmVhbCB1c2VycywgYnV0IHRoZXkgd2VyZSBwcmVwYXJlZCBmb3IKPiB0
aGUgZnV0dXJlIHVzZS4KPiAKPiBUaGFua3MKCk1ha2VzIHNlbnNlIGZvciBiYXNpYyBidWlsZGlu
ZyBibG9ja3MgYnV0IEknbSBub3Qgc3VyZSB3ZQpuZWVkIHRvIGRvIGl0IGZvciBhbGwgQVBJcy4K
Cgo+ID4gCj4gPiA+IFRoYW5rcwo+ID4gPiAKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KVmlydHVhbGl6YXRpb24gbWFpbGluZyBsaXN0ClZpcnR1YWxpemF0
aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0
aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3ZpcnR1YWxpemF0aW9u
