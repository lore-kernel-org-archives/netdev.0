From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 22/44] x86/pci-nommu: implement ->mapping_error
Date: Fri, 16 Jun 2017 20:10:37 +0200
Message-ID: <20170616181059.19206-23-hch@lst.de>
References: <20170616181059.19206-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-kernel@vger.kernel.org
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
 xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
 linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
 linux-mips@linux-mips.org, openrisc@lists.librecores.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
 linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org,
 netdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

RE1BX0VSUk9SX0NPREUgaXMgZ29pbmcgdG8gZ28gYXdheSwgc28gZG9uJ3QgcmVseSBvbiBpdC4K
ClNpZ25lZC1vZmYtYnk6IENocmlzdG9waCBIZWxsd2lnIDxoY2hAbHN0LmRlPgotLS0KIGFyY2gv
eDg2L2tlcm5lbC9wY2ktbm9tbXUuYyB8IDEwICsrKysrKysrKy0KIDEgZmlsZSBjaGFuZ2VkLCA5
IGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkKCmRpZmYgLS1naXQgYS9hcmNoL3g4Ni9rZXJu
ZWwvcGNpLW5vbW11LmMgYi9hcmNoL3g4Ni9rZXJuZWwvcGNpLW5vbW11LmMKaW5kZXggYTg4OTUy
ZWYzNzFjLi4wODVmZTZjZTQwNDkgMTAwNjQ0Ci0tLSBhL2FyY2gveDg2L2tlcm5lbC9wY2ktbm9t
bXUuYworKysgYi9hcmNoL3g4Ni9rZXJuZWwvcGNpLW5vbW11LmMKQEAgLTExLDYgKzExLDggQEAK
ICNpbmNsdWRlIDxhc20vaW9tbXUuaD4KICNpbmNsdWRlIDxhc20vZG1hLmg+CiAKKyNkZWZpbmUg
Tk9NTVVfTUFQUElOR19FUlJPUgkJMAorCiBzdGF0aWMgaW50CiBjaGVja19hZGRyKGNoYXIgKm5h
bWUsIHN0cnVjdCBkZXZpY2UgKmh3ZGV2LCBkbWFfYWRkcl90IGJ1cywgc2l6ZV90IHNpemUpCiB7
CkBAIC0zMyw3ICszNSw3IEBAIHN0YXRpYyBkbWFfYWRkcl90IG5vbW11X21hcF9wYWdlKHN0cnVj
dCBkZXZpY2UgKmRldiwgc3RydWN0IHBhZ2UgKnBhZ2UsCiAJZG1hX2FkZHJfdCBidXMgPSBwYWdl
X3RvX3BoeXMocGFnZSkgKyBvZmZzZXQ7CiAJV0FSTl9PTihzaXplID09IDApOwogCWlmICghY2hl
Y2tfYWRkcigibWFwX3NpbmdsZSIsIGRldiwgYnVzLCBzaXplKSkKLQkJcmV0dXJuIERNQV9FUlJP
Ul9DT0RFOworCQlyZXR1cm4gTk9NTVVfTUFQUElOR19FUlJPUjsKIAlmbHVzaF93cml0ZV9idWZm
ZXJzKCk7CiAJcmV0dXJuIGJ1czsKIH0KQEAgLTg4LDYgKzkwLDExIEBAIHN0YXRpYyB2b2lkIG5v
bW11X3N5bmNfc2dfZm9yX2RldmljZShzdHJ1Y3QgZGV2aWNlICpkZXYsCiAJZmx1c2hfd3JpdGVf
YnVmZmVycygpOwogfQogCitzdGF0aWMgaW50IG5vbW11X21hcHBpbmdfZXJyb3Ioc3RydWN0IGRl
dmljZSAqZGV2LCBkbWFfYWRkcl90IGRtYV9hZGRyKQoreworCXJldHVybiBkbWFfYWRkciA9PSBO
T01NVV9NQVBQSU5HX0VSUk9SOworfQorCiBjb25zdCBzdHJ1Y3QgZG1hX21hcF9vcHMgbm9tbXVf
ZG1hX29wcyA9IHsKIAkuYWxsb2MJCQk9IGRtYV9nZW5lcmljX2FsbG9jX2NvaGVyZW50LAogCS5m
cmVlCQkJPSBkbWFfZ2VuZXJpY19mcmVlX2NvaGVyZW50LApAQCAtOTYsNCArMTAzLDUgQEAgY29u
c3Qgc3RydWN0IGRtYV9tYXBfb3BzIG5vbW11X2RtYV9vcHMgPSB7CiAJLnN5bmNfc2luZ2xlX2Zv
cl9kZXZpY2UgPSBub21tdV9zeW5jX3NpbmdsZV9mb3JfZGV2aWNlLAogCS5zeW5jX3NnX2Zvcl9k
ZXZpY2UJPSBub21tdV9zeW5jX3NnX2Zvcl9kZXZpY2UsCiAJLmlzX3BoeXMJCT0gMSwKKwkubWFw
cGluZ19lcnJvcgkJPSBub21tdV9tYXBwaW5nX2Vycm9yLAogfTsKLS0gCjIuMTEuMAoKCl9fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClhlbi1kZXZlbCBtYWls
aW5nIGxpc3QKWGVuLWRldmVsQGxpc3RzLnhlbi5vcmcKaHR0cHM6Ly9saXN0cy54ZW4ub3JnL3hl
bi1kZXZlbAo=
