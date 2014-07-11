From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH 2/2 V3] PCI: implement VFs assignment
	reference counter
Date: Fri, 11 Jul 2014 21:01:53 +0800
Message-ID: <CABawtvN0H9bsUkXSw48hM7SncJnACaKnWb=PHcbJFrXmvJ2guQ@mail.gmail.com>
References: <1405081802-419-1-git-send-email-ethan.zhao@oracle.com>
	<1405081802-419-2-git-send-email-ethan.zhao@oracle.com>
	<53BFDBC0.8000705@gmail.com>
	<CABawtvOV5DQqqLu96CFktxmHkJA+n3FUyA3Nt3HtPMKs5KpVOw@mail.gmail.com>
	<53BFDF04.7090906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "<kvm@vger.kernel.org>" <kvm@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"vaughan.cao@oracle.com" <vaughan.cao@oracle.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, Ethan Zhao <ethan.zhao@oracle.com>,
	"<linux.nics@intel.com>" <linux.nics@intel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"<gleb@kernel.org>" <gleb@kernel.org>,
	"<alex.williamson@redhat.com>" <alex.williamson@redhat.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	"<boris.ostrovsky@oracle.com>" <boris.ostrovsky@oracle.com>,
	netdev <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, LKML <linux-kernel@vger.kernel.org>,
	"<john.ronciak@intel.com>" <john.ronciak@intel.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"<pbonzini@redhat.com>" <pbonzini@redhat.com>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <53BFDF04.7090906@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

T24gRnJpLCBKdWwgMTEsIDIwMTQgYXQgODo1NiBQTSwgVmFya2EgQmhhZHJhbSA8dmFya2FiaGFk
cmFtQGdtYWlsLmNvbT4gd3JvdGU6Cj4gT24gMDcvMTEvMjAxNCAwNjoyMSBQTSwgRXRoYW4gWmhh
byB3cm90ZToKPgo+IE9uIEZyaSwgSnVsIDExLCAyMDE0IGF0IDg6NDIgUE0sIFZhcmthIEJoYWRy
YW0gPHZhcmthYmhhZHJhbUBnbWFpbC5jb20+Cj4gd3JvdGU6Cj4KPiBPbiAwNy8xMS8yMDE0IDA2
OjAwIFBNLCBFdGhhbiBaaGFvIHdyb3RlOgo+Cj4gQ3VycmVudCBpbXBsZW1lbnRhdGlvbiBvZiBo
ZWxwZXIgZnVuY3Rpb24gcGNpX3Zmc19hc3NpZ25lZCgpIGlzIGEKPiBsaXR0bGUgY29tcGxleCwg
dG8gZ2V0IHN1bSBvZiBWRnMgdGhhdCBhc3NpZ25lZCB0byBWTSwgYWNjZXNzIGxvdwo+IGxldmVs
IGNvbmZpZ3VyYXRpb24gc3BhY2UgcmVnaXN0ZXIgYW5kIHRoZW4gbG9vcCBpbiB0cmF2ZXJzaW5n
Cj4gZGV2aWNlIHRyZWUuCj4KPiAoLi4uKQo+Cj4KPiBAQCAtNjUwLDYgKzYzMCwxMSBAQCBFWFBP
UlRfU1lNQk9MX0dQTChwY2lfdmZzX2Fzc2lnbmVkKTsKPiAgIHZvaWQgcGNpX2lvdl9hc3NpZ25f
ZGV2aWNlKHN0cnVjdCBwY2lfZGV2ICpwZGV2KQo+ICAgewo+ICAgICAgICAgcGRldi0+ZGV2X2Zs
YWdzIHw9IFBDSV9ERVZfRkxBR1NfQVNTSUdORUQ7Cj4gKyAgICAgICBpZiAocGRldi0+aXNfdmly
dGZuICYmICFwZGV2LT5pc19waHlzZm4pCj4gKyAgICAgICAgICAgICAgIGlmIChwZGV2LT5waHlz
Zm4pCj4gKyAgICAgICAgICAgICAgICAgICAgICAgaWYgKHBkZXYtPnBoeXNmbi0+c3Jpb3YpCj4K
PiBXaHkgZG9uJ3Qgd2UgbWFrZSBsYXN0IHR3byAnaWYnIGNvbmRpdGlvbnMgaW50byBzaW5nbGUg
J2lmJwo+Cj4gaWYgKHBkZXYtPnBoeXNmbiAmJiBwZGV2LT5waHlzZm4tPnNyaW92KQo+Cj4gWWVh
aO+8jCB0aGlzIG9uZSBsb29rcyBiZXR0ZXIsICB0aGF0IHN0eWxlIHVzZWQgdG8gdGVsbCBteXNl
bGYsIEkgbWlnaHQKPiBmb3JnZXQgdGhlIHdoaWNoIHNpZGUgb2YgICYmIG9wZXJhdG9yICBmaXJz
dCwgaWYgeW91IHN1cmUgbGVmdCBmaXJzdCwKPiBJIHByZWZlciB0aGF0IHRvbyA6Pgo+Cj4gZm9y
ICYmIG9wZXJhdG9yIC0gZXZhbHVhdGlvbiBpcyBmcm9tIExlZnQgdG8gUmlnaHQKCkRlZmluaXRl
bHkgcmlnaHQgIQoKVGhhbmtzLApFdGhhbgo+Cj4gLS0KPiBSZWdhcmRzLAo+IFZhcmthIEJoYWRy
YW0uCgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KT3BlbiBzb3VyY2UgYnVzaW5lc3MgcHJvY2VzcyBt
YW5hZ2VtZW50IHN1aXRlIGJ1aWx0IG9uIEphdmEgYW5kIEVjbGlwc2UKVHVybiBwcm9jZXNzZXMg
aW50byBidXNpbmVzcyBhcHBsaWNhdGlvbnMgd2l0aCBCb25pdGEgQlBNIENvbW11bml0eSBFZGl0
aW9uClF1aWNrbHkgY29ubmVjdCBwZW9wbGUsIGRhdGEsIGFuZCBzeXN0ZW1zIGludG8gb3JnYW5p
emVkIHdvcmtmbG93cwpXaW5uZXIgb2YgQk9TU0lFLCBDT0RJRSwgT1cyIGFuZCBHYXJ0bmVyIGF3
YXJkcwpodHRwOi8vcC5zZi5uZXQvc2Z1L0Jvbml0YXNvZnQKX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX18KRTEwMDAtZGV2ZWwgbWFpbGluZyBsaXN0CkUxMDAw
LWRldmVsQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRwczovL2xpc3RzLnNvdXJjZWZvcmdlLm5l
dC9saXN0cy9saXN0aW5mby9lMTAwMC1kZXZlbApUbyBsZWFybiBtb3JlIGFib3V0IEludGVsJiMx
NzQ7IEV0aGVybmV0LCB2aXNpdCBodHRwOi8vY29tbXVuaXRpZXMuaW50ZWwuY29tL2NvbW11bml0
eS93aXJlZAo=
