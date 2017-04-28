From: Logan Gunthorpe <logang@deltatee.com>
Subject: Re: [PATCH v2 07/21] crypto: shash,
 caam: Make use of the new sg_map helper function
Date: Fri, 28 Apr 2017 13:01:39 -0600
Message-ID: <d5242ef0-2670-63e4-02ce-a6d2368b7292@deltatee.com>
References: <1493144468-22493-1-git-send-email-logang@deltatee.com>
 <1493144468-22493-8-git-send-email-logang@deltatee.com>
 <20170427035603.GA32212@gondor.apana.org.au>
 <94123cbf-3287-f05e-7267-0bcf08ab0a8b@deltatee.com>
 <20170428063039.GB6817@gondor.apana.org.au>
 <5a08708b-c3b8-41fe-96de-607a109eacbd@deltatee.com>
 <20170428175147.GA9596@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dri-devel@lists.freedesktop.org, Stephen Bates <sbates@raithlin.com>,
 dm-devel@redhat.com, target-devel@vger.kernel.org,
 Christoph Hellwig <hch@lst.de>, devel@driverdev.osuosl.org,
 "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>, linux-scsi@vger.kernel.org,
 linux-nvdimm@lists.01.org, linux-rdma@vger.kernel.org,
 Sumit Semwal <sumit.semwal@linaro.org>,
 Ross Zwisler <ross.zwisler@linux.intel.com>, open-iscsi@googlegroups.com,
 linux-media@vger.kernel.org, intel-gfx@lists.freedesktop.org,
 sparmaintainer@unisys.com, linux-raid@vger.kernel.org,
 Dan Williams <dan.j.williams@intel.com>, megaraidlinux.pdl@broadcom.com,
 Jens Axboe <axboe@kernel.dk>,
 "Martin K. Petersen" <martin.petersen@oracle.com>, netdev@vger.kernel.org,
 Matthew Wilcox <mawilcox@microsoft.com>, linux-mmc@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
 Greg Kroah-Hartman <gregkh@linu
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <20170428175147.GA9596@gondor.apana.org.au>
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

CgpPbiAyOC8wNC8xNyAxMTo1MSBBTSwgSGVyYmVydCBYdSB3cm90ZToKPiBPbiBGcmksIEFwciAy
OCwgMjAxNyBhdCAxMDo1Mzo0NUFNIC0wNjAwLCBMb2dhbiBHdW50aG9ycGUgd3JvdGU6Cj4+Cj4+
Cj4+IE9uIDI4LzA0LzE3IDEyOjMwIEFNLCBIZXJiZXJ0IFh1IHdyb3RlOgo+Pj4gWW91IGFyZSBy
aWdodC4gIEluZGVlZCB0aGUgZXhpc3RpbmcgY29kZSBsb29rcyBidWdneSBhcyB0aGV5Cj4+PiBk
b24ndCB0YWtlIHNnLT5vZmZzZXQgaW50byBhY2NvdW50IHdoZW4gZG9pbmcgdGhlIGttYXAuICBD
b3VsZAo+Pj4geW91IHNlbmQgbWUgc29tZSBwYXRjaGVzIHRoYXQgZml4IHRoZXNlIHByb2JsZW1z
IGZpcnN0IHNvIHRoYXQKPj4+IHRoZXkgY2FuIGJlIGVhc2lseSBiYWNrcG9ydGVkPwo+Pgo+PiBP
aywgSSB0aGluayB0aGUgb25seSBidWdneSBvbmUgaW4gY3J5cHRvIGlzIGhpZm5fNzk1eC4gU2hh
c2ggYW5kIGNhYW0KPj4gYm90aCBkbyBoYXZlIHRoZSBzZy0+b2Zmc2V0IGFjY291bnRlZCBmb3Iu
IEknbGwgc2VuZCBhIHBhdGNoIGZvciB0aGUKPj4gYnVnZ3kgb25lIHNob3J0bHkuCj4gCj4gSSB0
aGluayB0aGV5J3JlIGFsbCBidWdneSB3aGVuIHNnLT5vZmZzZXQgaXMgZ3JlYXRlciB0aGFuIFBB
R0VfU0laRS4KClllcywgdGVjaG5pY2FsbHkuIEJ1dCB0aGF0J3MgYSBfdmVyeV8gY29tbW9uIG1p
c3Rha2UuIFByZXR0eSBuZWFybHkKZXZlcnkgY2FzZSBJIGxvb2tlZCBhdCBkaWQgbm90IHRha2Ug
dGhhdCBpbnRvIGFjY291bnQuIEkgZG9uJ3QgdGhpbmsKc2cncyB0aGF0IHBvaW50IHRvIG1vcmUg
dGhhbiBvbmUgY29udGludW91cyBwYWdlIGFyZSBhbGwgdGhhdCBjb21tb24uCgpGaXhpbmcgYWxs
IHRob3NlIGNhc2VzIHdpdGhvdXQgbWFraW5nIGEgY29tbW9uIGZ1bmN0aW9uIGlzIGEgd2FzdGUg
b2YKdGltZSBJTU8uCgpMb2dhbgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fXwpJbnRlbC1nZnggbWFpbGluZyBsaXN0CkludGVsLWdmeEBsaXN0cy5mcmVlZGVz
a3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5mcmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9p
bnRlbC1nZngK
