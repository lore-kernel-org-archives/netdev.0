From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/3] net: Fix drivers advertising HW_CSUM
 feature to use csum_start
Date: Tue, 14 Dec 2010 19:07:27 -0800
Message-ID: <20101214190727.0ed1a925@nehalam>
References: <cover.1292372504.git.mirq-linux@rere.qmqm.pl>
	<aa9d85fa4961e87c38aec922913cbc95465fc082.1292372504.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Roopa Prabhu <roprabhu@cisco.com>, Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Vasanthy, Jie Yang <Jie.Yang@atheros.com>, Eric,
	Kolluri <vkolluri@cisco.com>, "VMware,
	Inc." <pv-drivers@vmware.com>, Brice Goglin <brice@myri.com>, H,
	Andrew Gallatin <gallatin@myri.com>,
	Joe Perches <joe@perches.com>, David Wang <dwang2@cisco.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sweeten <hsweeten@visionengravers.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <aa9d85fa4961e87c38aec922913cbc95465fc082.1292372504.git.mirq-linux@rere.qmqm.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

T24gV2VkLCAxNSBEZWMgMjAxMCAwMjoyNDowOCArMDEwMCAoQ0VUKQpNaWNoYcWCIE1pcm9zxYJh
dyA8bWlycS1saW51eEByZXJlLnFtcW0ucGw+IHdyb3RlOgoKPiBTb21lIGRyaXZlcnMgYXJlIHVz
aW5nIHNrYl90cmFuc3BvcnRfb2Zmc2V0KHNrYikgaW5zdGVhZCBvZiBza2ItPmNzdW1fc3RhcnQK
PiBmb3IgTkVUSUZfRl9IV19DU1VNIG9mZmxvYWQuICBUaGlzIGRvZXMgbm90IG1hdHRlciBub3cs
IGJ1dCBpZiBzb21lb25lCj4gaW1wbGVtZW50cyBjaGVja3N1bW1pbmcgb2YgZW5jYXBzdWxhdGVk
IHBhY2tldHMgdGhlbiB0aGlzIHdpbGwgYnJlYWsgc2lsZW50bHkuCj4gCj4gVFNPIG91dHB1dCBw
YXRocyBhcmUgbGVmdCBhcyB0aGV5IGFyZSwgc2luY2UgdGhleSBhcmUgZm9yIElQK1RDUCBvbmx5
Cj4gKG1pZ2h0IGJlIHdvcnRoIGNvbnZlcnRpbmcgdGhvdWdoKS4KPiAKPiBTaWduZWQtb2ZmLWJ5
OiBNaWNoYcWCIE1pcm9zxYJhdyA8bWlycS1saW51eEByZXJlLnFtcW0ucGw+CgpXaGljaCBpZiBh
bnkgb2YgdGhlc2UgZHJpdmVycyBkaWQgeW91IHRlc3Qgb24gcmVhbCBoYXJkd2FyZT8KCgotLSAK
Ci0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpMb3R1c3BoZXJlIDIwMTEKUmVnaXN0ZXIgbm93IGZvciBM
b3R1c3BoZXJlIDIwMTEgYW5kIGxlYXJuIGhvdwp0byBjb25uZWN0IHRoZSBkb3RzLCB0YWtlIHlv
dXIgY29sbGFib3JhdGl2ZSBlbnZpcm9ubWVudAp0byB0aGUgbmV4dCBsZXZlbCwgYW5kIGVudGVy
IHRoZSBlcmEgb2YgU29jaWFsIEJ1c2luZXNzLgpodHRwOi8vcC5zZi5uZXQvc2Z1L2xvdHVzcGhl
cmUtZDJkCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkUx
MDAwLWRldmVsIG1haWxpbmcgbGlzdApFMTAwMC1kZXZlbEBsaXN0cy5zb3VyY2Vmb3JnZS5uZXQK
aHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vZTEwMDAtZGV2ZWwK
VG8gbGVhcm4gbW9yZSBhYm91dCBJbnRlbCYjMTc0OyBFdGhlcm5ldCwgdmlzaXQgaHR0cDovL2Nv
bW11bml0aWVzLmludGVsLmNvbS9jb21tdW5pdHkvd2lyZWQK
