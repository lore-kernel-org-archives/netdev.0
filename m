From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net-next 06/11] ptp: e1000e: use helpers for converting
 ns to timespec.
Date: Tue, 31 Mar 2015 21:10:36 +0000
Message-ID: <1427836236.16312.28.camel@intel.com>
References: <cover.1427835485.git.richardcochran@gmail.com>
	 <051364a3a57d36200f652f4d8e1c9bfc4edf3254.1427835485.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"baolin.wang@linaro.org" <baolin.wang@linaro.org>,
	"b45643@freescale.com" <b45643@freescale.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"sonic.zhang@analog.com" <sonic.zhang@analog.com>,
	"rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"sony.chacko@qlogic.com" <sony.chacko@qlogic.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"arnd@linaro.org" <arnd@linaro.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"prashant@broadcom.com" <prashant@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>
To: "richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <051364a3a57d36200f652f4d8e1c9bfc4edf3254.1427835485.git.richardcochran@gmail.com>
Content-Language: en-US
Content-ID: <A60CB9EE00D6454295101E771C917BB0@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDE1LTAzLTMxIGF0IDIzOjA4ICswMjAwLCBSaWNoYXJkIENvY2hyYW4gd3JvdGU6
DQo+IFRoaXMgcGF0Y2ggY2hhbmdlcyB0aGUgZHJpdmVyIHRvIHVzZSBuc190b190aW1lc3BlYzY0
KCkgaW5zdGVhZCBvZg0KPiBvcGVuIGNvZGluZyB0aGUgc2FtZSBsb2dpYy4NCj4gDQo+IENvbXBp
bGUgdGVzdGVkIG9ubHkuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBSaWNoYXJkIENvY2hyYW4gPHJp
Y2hhcmRjb2NocmFuQGdtYWlsLmNvbT4NCj4gLS0tDQo+ICBkcml2ZXJzL25ldC9ldGhlcm5ldC9p
bnRlbC9lMTAwMGUvcHRwLmMgfCAgICA0ICstLS0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2Vy
dGlvbigrKSwgMyBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9l
dGhlcm5ldC9pbnRlbC9lMTAwMGUvcHRwLmMgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9l
MTAwMGUvcHRwLmMNCj4gaW5kZXggYjc0N2EzZS4uZDIyNzJhZCAxMDA2NDQNCj4gLS0tIGEvZHJp
dmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvZTEwMDBlL3B0cC5jDQo+ICsrKyBiL2RyaXZlcnMvbmV0
L2V0aGVybmV0L2ludGVsL2UxMDAwZS9wdHAuYw0KPiBAQCAtMTExLDE1ICsxMTEsMTMgQEAgc3Rh
dGljIGludCBlMTAwMGVfcGhjX2dldHRpbWUoc3RydWN0IHB0cF9jbG9ja19pbmZvICpwdHAsIHN0
cnVjdCB0aW1lc3BlYzY0ICp0cykNCj4gIAlzdHJ1Y3QgZTEwMDBfYWRhcHRlciAqYWRhcHRlciA9
IGNvbnRhaW5lcl9vZihwdHAsIHN0cnVjdCBlMTAwMF9hZGFwdGVyLA0KPiAgCQkJCQkJICAgICBw
dHBfY2xvY2tfaW5mbyk7DQo+ICAJdW5zaWduZWQgbG9uZyBmbGFnczsNCj4gLQl1MzIgcmVtYWlu
ZGVyOw0KPiAgCXU2NCBuczsNCj4gIA0KPiAgCXNwaW5fbG9ja19pcnFzYXZlKCZhZGFwdGVyLT5z
eXN0aW1fbG9jaywgZmxhZ3MpOw0KPiAgCW5zID0gdGltZWNvdW50ZXJfcmVhZCgmYWRhcHRlci0+
dGMpOw0KPiAgCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmFkYXB0ZXItPnN5c3RpbV9sb2NrLCBm
bGFncyk7DQo+ICANCj4gLQl0cy0+dHZfc2VjID0gZGl2X3U2NF9yZW0obnMsIE5TRUNfUEVSX1NF
QywgJnJlbWFpbmRlcik7DQo+IC0JdHMtPnR2X25zZWMgPSByZW1haW5kZXI7DQo+ICsJKnRzID0g
bnNfdG9fdGltZXNwZWM2NChucyk7DQo+ICANCj4gIAlyZXR1cm4gMDsNCj4gIH0NCg0KDQpBY2tl
ZC1ieTogSmFjb2IgS2VsbGVyIDxqYWNvYi5lLmtlbGxlckBpbnRlbC5jb20+DQo=
