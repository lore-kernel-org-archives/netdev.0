From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH net-next 16/19] net: hns: fix bug that alloc skb fail lead
 to port unavailable
Date: Wed, 22 Jun 2016 09:41:43 +0800
Message-ID: <5769ECD7.8080303@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1466481399-70080-17-git-send-email-Yisen.Zhuang@huawei.com>
 <097b1147-3587-9579-0f94-f42be130773c@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ivecera@redhat.com, andrew@lunn.ch, fengguang.wu@intel.com,
 liguozhu@huawei.com, arnd@arndb.de, charles.chenxin@huawei.com,
 linux-kernel@vger.kernel.org, linuxarm@huawei.com, geliangtang@163.com,
 huangdaode@hisilicon.com, netdev@vger.kernel.org,
 andriy.shevchenko@linux.intel.com, linux-arm-kernel@lists.infradead.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 <davem@davemloft.net>, <salil.mehta@huawei.com>, <yankejian@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <097b1147-3587-9579-0f94-f42be130773c@cogentembedded.com>
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

CgrlnKggMjAxNi82LzIxIDIxOjI1LCBTZXJnZWkgU2h0eWx5b3Yg5YaZ6YGTOgo+IEhlbGxvLgo+
IAo+IE9uIDYvMjEvMjAxNiA2OjU2IEFNLCBZaXNlbiBaaHVhbmcgd3JvdGU6Cj4gCj4+IEZyb206
IEp1biBIZSA8aGphdDIwMDVAaHVhd2VpLmNvbT4KPj4KPj4gV2hlbiBobnNfbmljX3BvbGxfcnhf
c2tiIGFsbG9jIHNrYiBmYWlsLCBpdCB3aWxsIGJyZWFrIHJlY2VpdmUgY3ljbGUgYW5kCj4+IHJl
YWQgbmV3IGZiZF9udW0gdG8gc3RhcnQgbmV3IHJlY2VpdmUgY3ljbGUuIEl0IHJlY29tcHV0ZXMg
Y3ljbGUgbnVtIGlzCj4+IGZiZF9udW0gbWludXMgY2xlYW5fY291bnQsIGFjdHVhbGx5IHRoaXMg
Y3ljbGUgbnVtIGlzIHRvbyBiaWcgYmVjYXVzZQo+PiBpdCBkcm9wIG91dCByZWNlaXZlIGN5Y2xl
LiBJdCBicmluZ3MgYWJvdXQgdGhlIHBvcnQgdW5hdmFpbGFibGUuCj4+Cj4+IFNvIHdlIHdpbGwg
Z290byBvdXQgd2hlbiBhbGxvYyBza2IgZmFpbCB0byBmaXggdGhpcyBidWcuCj4+Cj4+IFNpZ25l
ZC1vZmYtYnk6IEp1biBIZSA8aGphdDIwMDVAaHVhd2VpLmNvbT4KPj4gU2lnbmVkLW9mZi1ieTog
RGluZyBUaWFuaG9uZyA8ZGluZ3RpYW5ob25nQGh1YXdlaS5jb20+Cj4+IFNpZ25lZC1vZmYtYnk6
IFlpc2VuIFpodWFuZyA8WWlzZW4uWmh1YW5nQGh1YXdlaS5jb20+Cj4+IC0tLQo+PiAgZHJpdmVy
cy9uZXQvZXRoZXJuZXQvaGlzaWxpY29uL2hucy9obnNfZW5ldC5jIHwgNSArKystLQo+PiAgMSBm
aWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkKPj4KPj4gZGlmZiAt
LWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2hpc2lsaWNvbi9obnMvaG5zX2VuZXQuYyBiL2Ry
aXZlcnMvbmV0L2V0aGVybmV0L2hpc2lsaWNvbi9obnMvaG5zX2VuZXQuYwo+PiBpbmRleCBmNDky
NDZkLi5jMGNlMzdiIDEwMDY0NAo+PiAtLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9oaXNpbGlj
b24vaG5zL2huc19lbmV0LmMKPj4gKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvaGlzaWxpY29u
L2hucy9obnNfZW5ldC5jCj4+IEBAIC03NjgsMTAgKzc2OCwxMCBAQCByZWN2Ogo+PiAgICAgICAg
ICAgICAgY2xlYW5fY291bnQgPSAwOwo+PiAgICAgICAgICB9Cj4+Cj4+IC0gICAgICAgIC8qIHBv
bGwgb25lIHBrZyovCj4+ICsgICAgICAgIC8qIHBvbGwgb25lIHBrdCovCgpJIHdpbGwgZml4IGl0
IHdpdGggYSBuZXcgcGF0Y2guCgpUaGFua3MsCgpZaXNlbgoKPiAKPiAgICBIb3cgYWJvdXQgYWRk
aW5nIGEgc3BhY2UgYmVmb3JlICovPwo+IAo+IFsuLi5dCj4gCj4gTUJSLCBTZXJnZWkKPiAKPiAK
PiAuCj4gCgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
bGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxpc3QKbGludXgtYXJtLWtlcm5lbEBsaXN0cy5pbmZy
YWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3JnL21haWxtYW4vbGlzdGluZm8vbGlu
dXgtYXJtLWtlcm5lbAo=
