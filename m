From: Logan Gunthorpe <logang@deltatee.com>
Subject: [PATCH v2 02/21] libiscsi: Add an internal error code
Date: Tue, 25 Apr 2017 12:20:49 -0600
Message-ID: <1493144468-22493-3-git-send-email-logang@deltatee.com>
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

VGhpcyBpcyBhIHByZXAgcGF0Y2ggdG8gYWRkIGEgbmV3IGVycm9yIGNvZGUgdG8gbGliaXNjc2ku
IFdlIHdhbnQgdG8KcmV3b3JrIHNvbWUga21hcCBjYWxscyB0byBiZSBhYmxlIHRvIGZhaWwuIFdo
ZW4gd2UgZG8sIHdlJ2QgbGlrZSB0bwp1c2UgdGhpcyBlcnJvciBjb2RlLgoKVGhpcyBwYXRjaCBz
aW1wbHkgaW50cm9kdWNlcyBJU0NTSV9UQ1BfSU5URVJOQUxfRVJSIGFuZCBwcmludHMKIkludGVy
bmFsIEVycm9yLiIgd2hlbiBpdCBnZXRzIGhpdC4KClNpZ25lZC1vZmYtYnk6IExvZ2FuIEd1bnRo
b3JwZSA8bG9nYW5nQGRlbHRhdGVlLmNvbT4KLS0tCiBkcml2ZXJzL3Njc2kvY3hnYmkvbGliY3hn
YmkuYyB8IDUgKysrKysKIGluY2x1ZGUvc2NzaS9saWJpc2NzaV90Y3AuaCAgIHwgMSArCiAyIGZp
bGVzIGNoYW5nZWQsIDYgaW5zZXJ0aW9ucygrKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvc2NzaS9j
eGdiaS9saWJjeGdiaS5jIGIvZHJpdmVycy9zY3NpL2N4Z2JpL2xpYmN4Z2JpLmMKaW5kZXggYmQ3
ZDM5ZS4uZTM4ZDBjMSAxMDA2NDQKLS0tIGEvZHJpdmVycy9zY3NpL2N4Z2JpL2xpYmN4Z2JpLmMK
KysrIGIvZHJpdmVycy9zY3NpL2N4Z2JpL2xpYmN4Z2JpLmMKQEAgLTE1NTYsNiArMTU1NiwxMSBA
QCBzdGF0aWMgaW5saW5lIGludCByZWFkX3BkdV9za2Ioc3RydWN0IGlzY3NpX2Nvbm4gKmNvbm4s
CiAJCSAqLwogCQlpc2NzaV9jb25uX3ByaW50ayhLRVJOX0VSUiwgY29ubiwgIkludmFsaWQgcGR1
IG9yIHNrYi4iKTsKIAkJcmV0dXJuIC1FRkFVTFQ7CisJY2FzZSBJU0NTSV9UQ1BfSU5URVJOQUxf
RVJSOgorCQlwcl9pbmZvKCJza2IgMHglcCwgb2ZmICV1LCAlZCwgVENQX0lOVEVSTkFMX0VSUi5c
biIsCisJCQlza2IsIG9mZnNldCwgb2ZmbG9hZGVkKTsKKwkJaXNjc2lfY29ubl9wcmludGsoS0VS
Tl9FUlIsIGNvbm4sICJJbnRlcm5hbCBlcnJvci4iKTsKKwkJcmV0dXJuIC1FRkFVTFQ7CiAJY2Fz
ZSBJU0NTSV9UQ1BfU0VHTUVOVF9ET05FOgogCQlsb2dfZGVidWcoMSA8PCBDWEdCSV9EQkdfUERV
X1JYLAogCQkJInNrYiAweCVwLCBvZmYgJXUsICVkLCBUQ1BfU0VHX0RPTkUsIHJjICVkLlxuIiwK
ZGlmZiAtLWdpdCBhL2luY2x1ZGUvc2NzaS9saWJpc2NzaV90Y3AuaCBiL2luY2x1ZGUvc2NzaS9s
aWJpc2NzaV90Y3AuaAppbmRleCAzMDUyMGQ1Li45MDY5MWFkIDEwMDY0NAotLS0gYS9pbmNsdWRl
L3Njc2kvbGliaXNjc2lfdGNwLmgKKysrIGIvaW5jbHVkZS9zY3NpL2xpYmlzY3NpX3RjcC5oCkBA
IC05Miw2ICs5Miw3IEBAIGVudW0gewogCUlTQ1NJX1RDUF9TS0JfRE9ORSwJCS8qIHNrYiBpcyBv
dXQgb2YgZGF0YSAqLwogCUlTQ1NJX1RDUF9DT05OX0VSUiwJCS8qIGlzY3NpIGxheWVyIGhhcyBm
aXJlZCBhIGNvbm4gZXJyICovCiAJSVNDU0lfVENQX1NVU1BFTkRFRCwJCS8qIGNvbm4gaXMgc3Vz
cGVuZGVkICovCisJSVNDU0lfVENQX0lOVEVSTkFMX0VSUiwgICAgICAgICAvKiBhbiBpbnRlcm5h
bCBlcnJvciBvY2N1cnJlZCAqLwogfTsKIAogZXh0ZXJuIHZvaWQgaXNjc2lfdGNwX2hkcl9yZWN2
X3ByZXAoc3RydWN0IGlzY3NpX3RjcF9jb25uICp0Y3BfY29ubik7Ci0tIAoyLjEuNAoKX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KSW50ZWwtZ2Z4IG1haWxp
bmcgbGlzdApJbnRlbC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBzOi8vbGlzdHMuZnJl
ZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vaW50ZWwtZ2Z4Cg==
