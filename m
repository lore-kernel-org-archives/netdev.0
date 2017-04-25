From: Logan Gunthorpe <logang@deltatee.com>
Subject: [PATCH v2 09/21] staging: unisys: visorbus: Make use of
	the new sg_map helper function
Date: Tue, 25 Apr 2017 12:20:56 -0600
Message-ID: <1493144468-22493-10-git-send-email-logang@deltatee.com>
References: <1493144468-22493-1-git-send-email-logang@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jens Axboe <axboe@kernel.dk>,
 "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
 "Martin K. Petersen" <martin.petersen@oracle.com>,
 Matthew Wilcox <mawilcox@microsoft.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Sumit Semwal <sumit.semwal@linaro.org>,
 Ross Zwisler <ross.zwisler@linux.intel.com>,
 Dan Williams <dan.j.williams@intel.com>, Stephen Bates <sbates@raithlin.com>,
 Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>
To: linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
 linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org,
 intel-gfx@lists.freedesktop.org, linux-raid@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-nvdimm@lists.01.org,
 linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com,
 megaraidlinux.pdl@broadcom.com, sparmaintainer@unisys.com,
 devel@driverdev.osuosl.org, target-devel@vger.kernel.org,
 netdev@vger.kernel.org, linux-rdma@vger.kernel.org, dm-devel@redhat.com
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <1493144468-22493-1-git-send-email-logang@deltatee.com>
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

U3RyYWlnaHRmb3J3YXJkIGNvbnZlcnNpb24gdG8gdGhlIG5ldyBmdW5jdGlvbi4KClNpZ25lZC1v
ZmYtYnk6IExvZ2FuIEd1bnRob3JwZSA8bG9nYW5nQGRlbHRhdGVlLmNvbT4KQWNrZWQtYnk6IERh
dmlkIEtlcnNobmVyIDxkYXZpZC5rZXJzaG5lckB1bmlzeXMuY29tPgotLS0KIGRyaXZlcnMvc3Rh
Z2luZy91bmlzeXMvdmlzb3JoYmEvdmlzb3JoYmFfbWFpbi5jIHwgMTIgKysrKysrKy0tLS0tCiAx
IGZpbGUgY2hhbmdlZCwgNyBpbnNlcnRpb25zKCspLCA1IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdp
dCBhL2RyaXZlcnMvc3RhZ2luZy91bmlzeXMvdmlzb3JoYmEvdmlzb3JoYmFfbWFpbi5jIGIvZHJp
dmVycy9zdGFnaW5nL3VuaXN5cy92aXNvcmhiYS92aXNvcmhiYV9tYWluLmMKaW5kZXggZDM3MjEx
NS4uYzc3NDI2YyAxMDA2NDQKLS0tIGEvZHJpdmVycy9zdGFnaW5nL3VuaXN5cy92aXNvcmhiYS92
aXNvcmhiYV9tYWluLmMKKysrIGIvZHJpdmVycy9zdGFnaW5nL3VuaXN5cy92aXNvcmhiYS92aXNv
cmhiYV9tYWluLmMKQEAgLTg0Myw3ICs4NDMsNiBAQCBkb19zY3NpX25vbGludXhzdGF0KHN0cnVj
dCB1aXNjbWRyc3AgKmNtZHJzcCwgc3RydWN0IHNjc2lfY21uZCAqc2NzaWNtZCkKIAlzdHJ1Y3Qg
c2NhdHRlcmxpc3QgKnNnOwogCXVuc2lnbmVkIGludCBpOwogCWNoYXIgKnRoaXNfcGFnZTsKLQlj
aGFyICp0aGlzX3BhZ2Vfb3JpZzsKIAlpbnQgYnVmaW5kID0gMDsKIAlzdHJ1Y3Qgdmlzb3JkaXNr
X2luZm8gKnZkaXNrOwogCXN0cnVjdCB2aXNvcmhiYV9kZXZkYXRhICpkZXZkYXRhOwpAQCAtODcw
LDExICs4NjksMTQgQEAgZG9fc2NzaV9ub2xpbnV4c3RhdChzdHJ1Y3QgdWlzY21kcnNwICpjbWRy
c3AsIHN0cnVjdCBzY3NpX2NtbmQgKnNjc2ljbWQpCiAKIAkJc2cgPSBzY3NpX3NnbGlzdChzY3Np
Y21kKTsKIAkJZm9yIChpID0gMDsgaSA8IHNjc2lfc2dfY291bnQoc2NzaWNtZCk7IGkrKykgewot
CQkJdGhpc19wYWdlX29yaWcgPSBrbWFwX2F0b21pYyhzZ19wYWdlKHNnICsgaSkpOwotCQkJdGhp
c19wYWdlID0gKHZvaWQgKikoKHVuc2lnbmVkIGxvbmcpdGhpc19wYWdlX29yaWcgfAotCQkJCQkg
ICAgIHNnW2ldLm9mZnNldCk7CisJCQl0aGlzX3BhZ2UgPSBzZ19tYXAoc2cgKyBpLCAwLCBTR19L
TUFQX0FUT01JQyk7CisJCQlpZiAoSVNfRVJSKHRoaXNfcGFnZSkpIHsKKwkJCQlzY3NpY21kLT5y
ZXN1bHQgPSBESURfRVJST1IgPDwgMTY7CisJCQkJcmV0dXJuOworCQkJfQorCiAJCQltZW1jcHko
dGhpc19wYWdlLCBidWYgKyBidWZpbmQsIHNnW2ldLmxlbmd0aCk7Ci0JCQlrdW5tYXBfYXRvbWlj
KHRoaXNfcGFnZV9vcmlnKTsKKwkJCXNnX3VubWFwKHNnICsgaSwgdGhpc19wYWdlLCAwLCBTR19L
TUFQX0FUT01JQyk7CiAJCX0KIAl9IGVsc2UgewogCQlkZXZkYXRhID0gKHN0cnVjdCB2aXNvcmhi
YV9kZXZkYXRhICopc2NzaWRldi0+aG9zdC0+aG9zdGRhdGE7Ci0tIAoyLjEuNAoKX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KSW50ZWwtZ2Z4IG1haWxpbmcg
bGlzdApJbnRlbC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBzOi8vbGlzdHMuZnJlZWRl
c2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vaW50ZWwtZ2Z4Cg==
