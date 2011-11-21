From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v1 0/4] e1000e: ethtool setfeatures
	fixes + loopback
Date: Mon, 21 Nov 2011 15:19:56 -0800
Message-ID: <cover.1321917278.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Decotigny <david.decotigny@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

VGhpcyBzZXJpZXMgZml4ZXMgYSBidWcgaW4gZXRodG9vbCBzZXRmZWF0dXJlcyBhbmQgYWRkcyBs
b29wYmFjawpzdXBwb3J0IHRocm91Z2ggZXRodG9vbCBzZXRmZWF0dXJlcy4KCkkgYmVsaWV2ZSB0
aGVzZSBwYXRjaGVzIGNvdWxkIGVhc2lseSBiZSBhZGFwdGVkIHRvIGUxMDAwLCBidXQgSSBkb24n
dApoYXZlIHRoZSBoYXJkd2FyZSB0byB0ZXN0LgoKIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMj
IyMjIyMjIyMjIyMjIyMjIyMKIyBQYXRjaCBTZXQgU3VtbWFyeToKCkRhdmlkIERlY290aWdueSAo
Mik6CiAgbmV0LWUxMDAwZTogZml4IGV0aHRvb2wgc2V0X2ZlYXR1cmVzIHRha2luZyBuZXcgZmVh
dHVyZXMgaW50byBhY2NvdW50CiAgICB0b28gbGF0ZQogIG5ldC1lMTAwMGU6IGVuYWJsZSBldGh0
b29sIGxvb3BiYWNrIHN1cHBvcnQKCk1hY2llaiDFu2VuY3p5a293c2tpICgyKToKICBuZXQtZTEw
MDBlOiByZXdvcmtlZCBjYXJyaWVyIGRldGVjdGlvbiBsb2dpYwogIG5ldC1lMTAwMGU6IFJlcG9y
dCBjYXJyaWVyIGluIGxvb3BiYWNrIG1vZGUKCiBkcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9l
MTAwMGUvZTEwMDAuaCAgIHwgICAgMiArCiBkcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9lMTAw
MGUvZXRodG9vbC5jIHwgICAgNiArLQogZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvZTEwMDBl
L25ldGRldi5jICB8ICAgMzEgKysrKysrKysrKy0tCiBkcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRl
bC9lMTAwMGUvcGh5LmMgICAgIHwgICA2OSArKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0KIDQg
ZmlsZXMgY2hhbmdlZCwgNzYgaW5zZXJ0aW9ucygrKSwgMzIgZGVsZXRpb25zKC0pCgotLSAKMS43
LjMuMQoKCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpBbGwgdGhlIGRhdGEgY29udGludW91c2x5IGdl
bmVyYXRlZCBpbiB5b3VyIElUIGluZnJhc3RydWN0dXJlIApjb250YWlucyBhIGRlZmluaXRpdmUg
cmVjb3JkIG9mIGN1c3RvbWVycywgYXBwbGljYXRpb24gcGVyZm9ybWFuY2UsIApzZWN1cml0eSB0
aHJlYXRzLCBmcmF1ZHVsZW50IGFjdGl2aXR5LCBhbmQgbW9yZS4gU3BsdW5rIHRha2VzIHRoaXMg
CmRhdGEgYW5kIG1ha2VzIHNlbnNlIG9mIGl0LiBJVCBzZW5zZS4gQW5kIGNvbW1vbiBzZW5zZS4K
aHR0cDovL3Auc2YubmV0L3NmdS9zcGx1bmstbm92ZDJkCl9fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fCkUxMDAwLWRldmVsIG1haWxpbmcgbGlzdApFMTAwMC1k
ZXZlbEBsaXN0cy5zb3VyY2Vmb3JnZS5uZXQKaHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQv
bGlzdHMvbGlzdGluZm8vZTEwMDAtZGV2ZWwKVG8gbGVhcm4gbW9yZSBhYm91dCBJbnRlbCYjMTc0
OyBFdGhlcm5ldCwgdmlzaXQgaHR0cDovL2NvbW11bml0aWVzLmludGVsLmNvbS9jb21tdW5pdHkv
d2lyZWQK
