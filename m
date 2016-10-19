From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/10] mm: replace __access_remote_vm()
 write parameter with gup_flags
Date: Wed, 19 Oct 2016 10:13:52 +0200
Message-ID: <20161019081352.GB7562@dhcp22.suse.cz>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-9-lstoakes@gmail.com>
 <20161019075903.GP29967@quack2.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org,
 linux-ia64@vger.kernel.org, kvm@vger.kernel.org, linux-sh@vger.kernel.org,
 Dave Hansen <dave.hansen@linux.intel.com>, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org,
 Hugh Dickins <hughd@google.com>, linux-media@vger.kernel.org,
 Rik van Riel <riel@redhat.com>, intel-gfx@lists.freedesktop.org,
 adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, Lorenzo Stoakes <lstoakes@gmail.com>,
 linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>,
 linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-alpha@vger.ker
To: Jan Kara <jack@suse.cz>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20161019075903.GP29967@quack2.suse.cz>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

T24gV2VkIDE5LTEwLTE2IDA5OjU5OjAzLCBKYW4gS2FyYSB3cm90ZToKPiBPbiBUaHUgMTMtMTAt
MTYgMDE6MjA6MTgsIExvcmVuem8gU3RvYWtlcyB3cm90ZToKPiA+IFRoaXMgcGF0Y2ggcmVtb3Zl
cyB0aGUgd3JpdGUgcGFyYW1ldGVyIGZyb20gX19hY2Nlc3NfcmVtb3RlX3ZtKCkgYW5kIHJlcGxh
Y2VzIGl0Cj4gPiB3aXRoIGEgZ3VwX2ZsYWdzIHBhcmFtZXRlciBhcyB1c2Ugb2YgdGhpcyBmdW5j
dGlvbiBwcmV2aW91c2x5IF9pbXBsaWVkXwo+ID4gRk9MTF9GT1JDRSwgd2hlcmVhcyBhZnRlciB0
aGlzIHBhdGNoIGNhbGxlcnMgZXhwbGljaXRseSBwYXNzIHRoaXMgZmxhZy4KPiA+IAo+ID4gV2Ug
bWFrZSB0aGlzIGV4cGxpY2l0IGFzIHVzZSBvZiBGT0xMX0ZPUkNFIGNhbiByZXN1bHQgaW4gc3Vy
cHJpc2luZyBiZWhhdmlvdXIKPiA+IChhbmQgaGVuY2UgYnVncykgd2l0aGluIHRoZSBtbSBzdWJz
eXN0ZW0uCj4gPiAKPiA+IFNpZ25lZC1vZmYtYnk6IExvcmVuem8gU3RvYWtlcyA8bHN0b2FrZXNA
Z21haWwuY29tPgo+IAo+IFNvIEknbSBub3QgY29udmluY2VkIHRoaXMgKGFuZCB0aGUgZm9sbG93
aW5nIHR3byBwYXRjaGVzKSBpcyBhY3R1YWxseQo+IGhlbHBpbmcgbXVjaC4gQnkgZ3JlcHBpbmcg
Zm9yIEZPTExfRk9SQ0Ugd2Ugd2lsbCBlYXNpbHkgc2VlIHRoYXQgYW55IGNhbGxlcgo+IG9mIGFj
Y2Vzc19yZW1vdGVfdm0oKSBnZXRzIHRoYXQgc2VtYW50aWNzIGFuZCBjYW4gdGh1cyBjb250aW51
ZSBzZWFyY2gKCkkgYW0gcmVhbGx5IHdvbmRlcmluZy4gSXMgdGhlcmUgYW55dGhpbmcgaW5oZXJl
bnQgdGhhdCB3b3VsZCByZXF1aXJlCkZPTExfRk9SQ0UgZm9yIGFjY2Vzc19yZW1vdGVfdm0/IEkg
bWVhbiBGT0xMX0ZPUkNFIGlzIGEgcmVhbGx5Cm5vbi10cml2aWFsIHRoaW5nLiBJdCBkb2Vzbid0
IG9iZXkgdm1hIHBlcm1pc3Npb25zIHNvIHdlIHNob3VsZCByZWFsbHkKbWluaW1pemUgaXRzIHVz
YWdlLiBEbyBhbGwgb2YgdGhvc2UgdXNlcnMgcmVhbGx5IG5lZWQgRk9MTF9GT1JDRT8KCkFueXdh
eSBJIHdvdWxkIHJhdGhlciBzZWUgdGhlIGZsYWcgZXhwbGljaXQgYW5kIHVzZWQgYXQgbW9yZSBw
bGFjZXMgdGhhbgpoaWRkZW4gYmVoaW5kIGEgaGVscGVyIGZ1bmN0aW9uLgotLSAKTWljaGFsIEhv
Y2tvClNVU0UgTGFicwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpJbnRlbC1nZnggbWFpbGluZyBsaXN0CkludGVsLWdmeEBsaXN0cy5mcmVlZGVza3RvcC5v
cmcKaHR0cHM6Ly9saXN0cy5mcmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9pbnRlbC1n
ZngK
