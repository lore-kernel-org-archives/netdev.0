From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 04/10] mm: replace get_user_pages_locked()
 write/force parameters with gup_flags
Date: Tue, 18 Oct 2016 14:54:25 +0200
Message-ID: <20161018125425.GD29967@quack2.suse.cz>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-5-lstoakes@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org,
 Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-sh@vger.kernel.org,
 Dave Hansen <dave.hansen@linux.intel.com>, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org,
 linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>,
 linux-media@vger.kernel.org, Rik van Riel <riel@redhat.com>,
 intel-gfx@lists.freedesktop.org, adi-buildroot-devel@lists.sourceforge.net,
 ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>,
 linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.org,
 lin
To: Lorenzo Stoakes <lstoakes@gmail.com>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20161013002020.3062-5-lstoakes@gmail.com>
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

T24gVGh1IDEzLTEwLTE2IDAxOjIwOjE0LCBMb3JlbnpvIFN0b2FrZXMgd3JvdGU6Cj4gVGhpcyBw
YXRjaCByZW1vdmVzIHRoZSB3cml0ZSBhbmQgZm9yY2UgcGFyYW1ldGVycyBmcm9tIGdldF91c2Vy
X3BhZ2VzX2xvY2tlZCgpCj4gYW5kIHJlcGxhY2VzIHRoZW0gd2l0aCBhIGd1cF9mbGFncyBwYXJh
bWV0ZXIgdG8gbWFrZSB0aGUgdXNlIG9mIEZPTExfRk9SQ0UKPiBleHBsaWNpdCBpbiBjYWxsZXJz
IGFzIHVzZSBvZiB0aGlzIGZsYWcgY2FuIHJlc3VsdCBpbiBzdXJwcmlzaW5nIGJlaGF2aW91ciAo
YW5kCj4gaGVuY2UgYnVncykgd2l0aGluIHRoZSBtbSBzdWJzeXN0ZW0uCj4gCj4gU2lnbmVkLW9m
Zi1ieTogTG9yZW56byBTdG9ha2VzIDxsc3RvYWtlc0BnbWFpbC5jb20+Cj4gLS0tCj4gIGluY2x1
ZGUvbGludXgvbW0uaCB8ICAyICstCj4gIG1tL2ZyYW1lX3ZlY3Rvci5jICB8ICA4ICsrKysrKyst
Cj4gIG1tL2d1cC5jICAgICAgICAgICB8IDEyICsrKy0tLS0tLS0tLQo+ICBtbS9ub21tdS5jICAg
ICAgICAgfCAgNSArKysrLQo+ICA0IGZpbGVzIGNoYW5nZWQsIDE1IGluc2VydGlvbnMoKyksIDEy
IGRlbGV0aW9ucygtKQo+IAo+IGRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L21tLmggYi9pbmNs
dWRlL2xpbnV4L21tLmgKPiBpbmRleCA2YWRjNGJjLi4yN2FiNTM4IDEwMDY0NAo+IC0tLSBhL2lu
Y2x1ZGUvbGludXgvbW0uaAo+ICsrKyBiL2luY2x1ZGUvbGludXgvbW0uaAo+IEBAIC0xMjgyLDcg
KzEyODIsNyBAQCBsb25nIGdldF91c2VyX3BhZ2VzKHVuc2lnbmVkIGxvbmcgc3RhcnQsIHVuc2ln
bmVkIGxvbmcgbnJfcGFnZXMsCj4gIAkJCSAgICBpbnQgd3JpdGUsIGludCBmb3JjZSwgc3RydWN0
IHBhZ2UgKipwYWdlcywKPiAgCQkJICAgIHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqKnZtYXMpOwo+
ICBsb25nIGdldF91c2VyX3BhZ2VzX2xvY2tlZCh1bnNpZ25lZCBsb25nIHN0YXJ0LCB1bnNpZ25l
ZCBsb25nIG5yX3BhZ2VzLAo+IC0JCSAgICBpbnQgd3JpdGUsIGludCBmb3JjZSwgc3RydWN0IHBh
Z2UgKipwYWdlcywgaW50ICpsb2NrZWQpOwo+ICsJCSAgICB1bnNpZ25lZCBpbnQgZ3VwX2ZsYWdz
LCBzdHJ1Y3QgcGFnZSAqKnBhZ2VzLCBpbnQgKmxvY2tlZCk7CgpIdW0sIHRoZSBwcm90b3R5cGUg
aXMgaW5jb25zaXN0ZW50IHdpdGggZS5nLiBfX2dldF91c2VyX3BhZ2VzX3VubG9ja2VkKCkKd2hl
cmUgZ3VwX2ZsYWdzIGNvbWUgYWZ0ZXIgKipwYWdlcyBhcmd1bWVudC4gQWN0dWFsbHkgaXQgbWFr
ZXMgbW9yZSBzZW5zZQp0byBoYXZlIGl0IGJlZm9yZSAqKnBhZ2VzIHNvIHRoYXQgaW5wdXQgYXJn
dW1lbnRzIGNvbWUgZmlyc3QgYW5kIG91dHB1dAphcmd1bWVudHMgc2Vjb25kIGJ1dCBJIGRvbid0
IGNhcmUgdGhhdCBtdWNoLiBCdXQgaXQgZGVmaW5pdGVseSBzaG91bGQgYmUKY29uc2lzdGVudC4u
LgoKCQkJCQkJCQlIb256YQotLSAKSmFuIEthcmEgPGphY2tAc3VzZS5jb20+ClNVU0UgTGFicywg
Q1IKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KSW50ZWwt
Z2Z4IG1haWxpbmcgbGlzdApJbnRlbC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBzOi8v
bGlzdHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vaW50ZWwtZ2Z4Cg==
