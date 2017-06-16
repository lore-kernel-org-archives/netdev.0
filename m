From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 38/44] arm: implement ->dma_supported instead of
	->set_dma_mask
Date: Fri, 16 Jun 2017 20:10:53 +0200
Message-ID: <20170616181059.19206-39-hch@lst.de>
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

U2FtZSBiZWhhdmlvciwgbGVzcyBjb2RlIGR1cGxpY2F0aW9uLgoKU2lnbmVkLW9mZi1ieTogQ2hy
aXN0b3BoIEhlbGx3aWcgPGhjaEBsc3QuZGU+Ci0tLQogYXJjaC9hcm0vY29tbW9uL2RtYWJvdW5j
ZS5jIHwgNyArKystLS0tCiAxIGZpbGUgY2hhbmdlZCwgMyBpbnNlcnRpb25zKCspLCA0IGRlbGV0
aW9ucygtKQoKZGlmZiAtLWdpdCBhL2FyY2gvYXJtL2NvbW1vbi9kbWFib3VuY2UuYyBiL2FyY2gv
YXJtL2NvbW1vbi9kbWFib3VuY2UuYwppbmRleCA2ZWNkNWJlNWQzN2UuLjlhOTJkZTYzNDI2ZiAx
MDA2NDQKLS0tIGEvYXJjaC9hcm0vY29tbW9uL2RtYWJvdW5jZS5jCisrKyBiL2FyY2gvYXJtL2Nv
bW1vbi9kbWFib3VuY2UuYwpAQCAtNDQ1LDEyICs0NDUsMTIgQEAgc3RhdGljIHZvaWQgZG1hYm91
bmNlX3N5bmNfZm9yX2RldmljZShzdHJ1Y3QgZGV2aWNlICpkZXYsCiAJYXJtX2RtYV9vcHMuc3lu
Y19zaW5nbGVfZm9yX2RldmljZShkZXYsIGhhbmRsZSwgc2l6ZSwgZGlyKTsKIH0KIAotc3RhdGlj
IGludCBkbWFib3VuY2Vfc2V0X21hc2soc3RydWN0IGRldmljZSAqZGV2LCB1NjQgZG1hX21hc2sp
CitzdGF0aWMgaW50IGRtYWJvdW5jZV9kbWFfc3VwcG9ydGVkKHN0cnVjdCBkZXZpY2UgKmRldiwg
dTY0IGRtYV9tYXNrKQogewogCWlmIChkZXYtPmFyY2hkYXRhLmRtYWJvdW5jZSkKIAkJcmV0dXJu
IDA7CiAKLQlyZXR1cm4gYXJtX2RtYV9vcHMuc2V0X2RtYV9tYXNrKGRldiwgZG1hX21hc2spOwor
CXJldHVybiBhcm1fZG1hX29wcy5kbWFfc3VwcG9ydGVkKGRldiwgZG1hX21hc2spOwogfQogCiBz
dGF0aWMgaW50IGRtYWJvdW5jZV9tYXBwaW5nX2Vycm9yKHN0cnVjdCBkZXZpY2UgKmRldiwgZG1h
X2FkZHJfdCBkbWFfYWRkcikKQEAgLTQ3MSw5ICs0NzEsOCBAQCBzdGF0aWMgY29uc3Qgc3RydWN0
IGRtYV9tYXBfb3BzIGRtYWJvdW5jZV9vcHMgPSB7CiAJLnVubWFwX3NnCQk9IGFybV9kbWFfdW5t
YXBfc2csCiAJLnN5bmNfc2dfZm9yX2NwdQk9IGFybV9kbWFfc3luY19zZ19mb3JfY3B1LAogCS5z
eW5jX3NnX2Zvcl9kZXZpY2UJPSBhcm1fZG1hX3N5bmNfc2dfZm9yX2RldmljZSwKLQkuc2V0X2Rt
YV9tYXNrCQk9IGRtYWJvdW5jZV9zZXRfbWFzaywKKwkuZG1hX3N1cHBvcnRlZAkJPSBkbWFib3Vu
Y2VfZG1hX3N1cHBvcnRlZCwKIAkubWFwcGluZ19lcnJvcgkJPSBkbWFib3VuY2VfbWFwcGluZ19l
cnJvciwKLQkuZG1hX3N1cHBvcnRlZAkJPSBhcm1fZG1hX3N1cHBvcnRlZCwKIH07CiAKIHN0YXRp
YyBpbnQgZG1hYm91bmNlX2luaXRfcG9vbChzdHJ1Y3QgZG1hYm91bmNlX3Bvb2wgKnBvb2wsIHN0
cnVjdCBkZXZpY2UgKmRldiwKLS0gCjIuMTEuMAoKCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fClhlbi1kZXZlbCBtYWlsaW5nIGxpc3QKWGVuLWRldmVsQGxp
c3RzLnhlbi5vcmcKaHR0cHM6Ly9saXN0cy54ZW4ub3JnL3hlbi1kZXZlbAo=
