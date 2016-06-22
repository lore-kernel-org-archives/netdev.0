From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH net-next 01/19] net: hns: bug fix of ge reset sequence
Date: Wed, 22 Jun 2016 09:33:24 +0800
Message-ID: <5769EAE4.2010507@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1466481399-70080-2-git-send-email-Yisen.Zhuang@huawei.com>
 <1466505306.30123.203.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ivecera@redhat.com, andrew@lunn.ch, liguozhu@huawei.com, arnd@arndb.de,
 charles.chenxin@huawei.com, linux-kernel@vger.kernel.org, linuxarm@huawei.com,
 geliangtang@163.com, huangdaode@hisilicon.com, netdev@vger.kernel.org,
 fengguang.wu@intel.com, linux-arm-kernel@lists.infradead.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, <davem@davemloft.net>,
 <salil.mehta@huawei.com>, <yankejian@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1466505306.30123.203.camel@linux.intel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

CgrlnKggMjAxNi82LzIxIDE4OjM1LCBBbmR5IFNoZXZjaGVua28g5YaZ6YGTOgo+IE9uIFR1ZSwg
MjAxNi0wNi0yMSBhdCAxMTo1NiArMDgwMCwgWWlzZW4gWmh1YW5nIHdyb3RlOgo+PiBGcm9tOiBR
aWFucWlhbiBYaWUgPHhpZXFpYW5xaWFuQGh1YXdlaS5jb20+Cj4+Cj4+IFRoZSBiaXQgZmlsZWRz
IG9mIFBQRSByZXNldCByZWdpc3RlciBhcmUgZGlmZmVyZW50IGJldHdlZW4gSE5TIHYxIGFuZAo+
PiBITlMgdjIsIGJ1dCB0aGUgY3VycmVudCBwcm9jZWR1cmUganVzdCBvbmx5IG1hdGNoIEhOUyB2
MS4gSGVyZSBpcyBhCj4+IHBhdGNoIHRvIGZpeCBpdC4KPj4KPj4gU2lnbmVkLW9mZi1ieTogS2Vq
aWFuIFlhbiA8eWFua2VqaWFuQGh1YXdlaS5jb20+Cj4+IFNpZ25lZC1vZmYtYnk6IFFpYW5xaWFu
IFhpZSA8eGllcWlhbnFpYW5AaHVhd2VpLmNvbT4KPj4gU2lnbmVkLW9mZi1ieTogWWlzZW4gWmh1
YW5nIDxZaXNlbi5aaHVhbmdAaHVhd2VpLmNvbT4KPj4gLS0tCj4+ICBkcml2ZXJzL25ldC9ldGhl
cm5ldC9oaXNpbGljb24vaG5zL2huc19kc2FmX21pc2MuYyB8IDYgKysrKystCj4+ICAxIGZpbGUg
Y2hhbmdlZCwgNSBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pCj4+Cj4+IGRpZmYgLS1naXQg
YS9kcml2ZXJzL25ldC9ldGhlcm5ldC9oaXNpbGljb24vaG5zL2huc19kc2FmX21pc2MuYwo+PiBi
L2RyaXZlcnMvbmV0L2V0aGVybmV0L2hpc2lsaWNvbi9obnMvaG5zX2RzYWZfbWlzYy5jCj4+IGlu
ZGV4IDk2Y2I2MjguLjA5ZTYwZDYgMTAwNjQ0Cj4+IC0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0
L2hpc2lsaWNvbi9obnMvaG5zX2RzYWZfbWlzYy5jCj4+ICsrKyBiL2RyaXZlcnMvbmV0L2V0aGVy
bmV0L2hpc2lsaWNvbi9obnMvaG5zX2RzYWZfbWlzYy5jCj4+IEBAIC0yNzEsNyArMjcxLDExIEBA
IHN0YXRpYyB2b2lkIGhuc19kc2FmX2dlX3Nyc3RfYnlfcG9ydChzdHJ1Y3QKPj4gZHNhZl9kZXZp
Y2UgKmRzYWZfZGV2LCB1MzIgcG9ydCwKPj4gIAkJfQo+PiAgCX0gZWxzZSB7Cj4+ICAJCXJlZ192
YWxfMSA9IDB4MTU1NDAgPDwgZHNhZl9kZXYtPnJlc2V0X29mZnNldDsKPj4gLQkJcmVnX3ZhbF8y
ID0gMHgxMDAgPDwgZHNhZl9kZXYtPnJlc2V0X29mZnNldDsKPj4gKwo+PiArCQlpZiAoQUVfSVNf
VkVSMShkc2FmX2Rldi0+ZHNhZl92ZXIpKQo+PiArCQkJcmVnX3ZhbF8yID0gMHgxMDAgPDwgZHNh
Zl9kZXYtPnJlc2V0X29mZnNldDsKPj4gKwkJZWxzZQo+PiArCQkJcmVnX3ZhbF8yID0gMHg0MCA8
PCBkc2FmX2Rldi0+cmVzZXRfb2Zmc2V0Owo+IAo+IHJlZ192YWxfMSA9IDB4MTU1NDA7Cj4gcmVn
X3ZhbF8yID0gQUVfSVNfVkVSMShkc2FmX2Rldi0+ZHNhZl92ZXIpID8gMHgxMDAgOiAweDQwOwo+
IAo+IHJlZ192YWxfMSA8PD0gZHNhZl9kZXYtPnJlc2V0X29mZnNldDsKPiByZWdfdmFsXzIgPDw9
IGRzYWZfZGV2LQoKSSB3aWxsIGZpeCBpdCB3aXRoIGEgbmV3IHBhdGNoLgoKVGhhbmtzLAoKWWlz
ZW4KCj4+IHJlc2V0X29mZnNldDsKPiAKPiAKPj4gIAo+PiAgCQlpZiAoIWRlcmVzZXQpIHsKPj4g
IAkJCWRzYWZfd3JpdGVfc3ViKGRzYWZfZGV2LAo+PiBEU0FGX1NVQl9TQ19HRV9SRVNFVF9SRVEx
X1JFRywKPiAKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwpsaW51eC1hcm0ta2VybmVsIG1haWxpbmcgbGlzdApsaW51eC1hcm0ta2VybmVsQGxpc3RzLmlu
ZnJhZGVhZC5vcmcKaHR0cDovL2xpc3RzLmluZnJhZGVhZC5vcmcvbWFpbG1hbi9saXN0aW5mby9s
aW51eC1hcm0ta2VybmVsCg==
