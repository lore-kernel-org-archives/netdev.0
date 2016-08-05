From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC V2 PATCH 17/25] net/netpolicy: introduce
 netpolicy_pick_queue
Date: Fri, 5 Aug 2016 13:55:47 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07712C237BE@SHSMSX103.ccr.corp.intel.com>
References: <1470339389-8542-1-git-send-email-kan.liang@intel.com>
 <1470339389-8542-18-git-send-email-kan.liang@intel.com>
 <CALx6S37NbXVh-vS=Vxrm_8qhhOsOkPy-+hLTUGk=E57yKBkCyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	John Stultz <john.stultz@linaro.org>,
	Alex Duyck <aduyck@mirantis.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Decotigny <decot@googlers.com>,
	Florian Westphal <fw@strlen.de>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"rdunlap@infradead.org" <rdunlap@infradead.org>,
	C
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALx6S37NbXVh-vS=Vxrm_8qhhOsOkPy-+hLTUGk=E57yKBkCyQ@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gDQo+IE9uIFRodSwgQXVnIDQsIDIwMTYgYXQgMTI6MzYgUE0sICA8a2FuLmxpYW5nQGlu
dGVsLmNvbT4gd3JvdGU6DQo+ID4gRnJvbTogS2FuIExpYW5nIDxrYW4ubGlhbmdAaW50ZWwuY29t
Pg0KPiA+DQo+ID4gVG8gYWNoaWV2ZSBiZXR0ZXIgbmV0d29yayBwZXJmb3JtYW5jZSwgdGhlIGtl
eSBzdGVwIGlzIHRvIGRpc3RyaWJ1dGUNCj4gPiB0aGUgcGFja2V0cyB0byBkZWRpY2F0ZWQgcXVl
dWVzIGFjY29yZGluZyB0byBwb2xpY3kgYW5kIHN5c3RlbSBydW4NCj4gPiB0aW1lIHN0YXR1cy4N
Cj4gPg0KPiA+IFRoaXMgcGF0Y2ggcHJvdmlkZXMgYW4gaW50ZXJmYWNlIHdoaWNoIGNhbiByZXR1
cm4gdGhlIHByb3BlciBkZWRpY2F0ZWQNCj4gPiBxdWV1ZSBmb3Igc29ja2V0L3Rhc2suIFRoZW4g
dGhlIHBhY2tldHMgb2YgdGhlIHNvY2tldC90YXNrIHdpbGwgYmUNCj4gPiByZWRpcmVjdCB0byB0
aGUgZGVkaWNhdGVkIHF1ZXVlIGZvciBiZXR0ZXIgbmV0d29yayBwZXJmb3JtYW5jZS4NCj4gPg0K
PiA+IEZvciBzZWxlY3RpbmcgdGhlIHByb3BlciBxdWV1ZSwgY3VycmVudGx5IGl0IHVzZXMgcm91
bmQtcm9iaW4NCj4gPiBhbGdvcml0aG0gdG8gZmluZCB0aGUgYXZhaWxhYmxlIG9iamVjdCBmcm9t
IHRoZSBnaXZlbiBwb2xpY3kgb2JqZWN0DQo+ID4gbGlzdC4gVGhlIGFsZ29yaXRobSBpcyBnb29k
IGVub3VnaCBmb3Igbm93LiBCdXQgaXQgY291bGQgYmUgaW1wcm92ZWQNCj4gPiBieSBzb21lIGFk
YXB0aXZlIGFsZ29yaXRobSBsYXRlci4NCj4gPg0KPiBTZXJpb3VzbHk/IFlvdSB3YW50IHRvIGFs
bCBvZiB0aGlzIGNvZGUgc28gd2UgcmV2ZXJ0IHRvIFRYIHF1ZXVlIHNlbGVjdGlvbiBieQ0KPiBy
b3VuZCByb2Jpbj8NCj4gDQoNCkkgYWdyZWUgdGhhdCB0aGUgcm91bmQgcm9iaW4gaXMgbm90IGFu
IG9wdGltYWwgYWxnb3JpdGhtLg0KRm9yIHRoaXMgc2VyaWVzLCB3ZSBpbnRlbmRzIHRvIHByb3Zp
ZGUgYSBnZW5lcmljIGluZnJhc3RydWN0dXJlIGZvciByZXZpZXcuDQpGb3IgdGhlIGFsZ29yaXRo
bSBwYXJ0cywgaXQncyBhbHJlYWR5IGluIG91ciBUT0RPIGxpc3QuIFdlIHdpbGwgcmVwbGFjZSBp
dCBsYXRlci4NCg0KVGhhbmtzLA0KS2FuDQoNCg==
