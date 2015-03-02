From: Vlastimil Babka <vbabka-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [patch v2 2/3] mm,
 thp: really limit transparent hugepage allocation to local node
Date: Mon, 02 Mar 2015 14:47:21 +0100
Message-ID: <54F469E9.7050303@suse.cz>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1502271416580.7225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Pekka Enberg <penberg-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
 Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>,
 Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
 Joonsoo Kim <iamjoonsoo.kim-Hm3cg6mZ9cc@public.gmane.org>
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <alpine.DEB.2.10.1502271416580.7225-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

T24gMDIvMjcvMjAxNSAxMToxNyBQTSwgRGF2aWQgUmllbnRqZXMgd3JvdGU6Cj4gQ29tbWl0IDA3
N2ZjZjExNmM4YyAoIm1tL3RocDogYWxsb2NhdGUgdHJhbnNwYXJlbnQgaHVnZXBhZ2VzIG9uIGxv
Y2FsCj4gbm9kZSIpIHJlc3RydWN0dXJlZCBhbGxvY19odWdlcGFnZV92bWEoKSB3aXRoIHRoZSBp
bnRlbnQgb2Ygb25seQo+IGFsbG9jYXRpbmcgdHJhbnNwYXJlbnQgaHVnZXBhZ2VzIGxvY2FsbHkg
d2hlbiB0aGVyZSB3YXMgbm90IGFuIGVmZmVjdGl2ZQo+IGludGVybGVhdmUgbWVtcG9saWN5Lgo+
Cj4gYWxsb2NfcGFnZXNfZXhhY3Rfbm9kZSgpIGRvZXMgbm90IGxpbWl0IHRoZSBhbGxvY2F0aW9u
IHRvIHRoZSBzaW5nbGUKPiBub2RlLCBob3dldmVyLCBidXQgcmF0aGVyIHByZWZlcnMgaXQuICBU
aGlzIGlzIGJlY2F1c2UgX19HRlBfVEhJU05PREUgaXMKPiBub3Qgc2V0IHdoaWNoIHdvdWxkIGNh
dXNlIHRoZSBub2RlLWxvY2FsIG5vZGVtYXNrIHRvIGJlIHBhc3NlZC4gIFdpdGhvdXQKPiBpdCwg
b25seSBhIG5vZGVtYXNrIHRoYXQgcHJlZmVycyB0aGUgbG9jYWwgbm9kZSBpcyBwYXNzZWQuCj4K
PiBGaXggdGhpcyBieSBwYXNzaW5nIF9fR0ZQX1RISVNOT0RFIGFuZCBmYWxsaW5nIGJhY2sgdG8g
c21hbGwgcGFnZXMgd2hlbgo+IHRoZSBhbGxvY2F0aW9uIGZhaWxzLgo+Cj4gQ29tbWl0IDlmMWI4
NjhhMTNhYyAoIm1tOiB0aHA6IGtodWdlcGFnZWQ6IGFkZCBwb2xpY3kgZm9yIGZpbmRpbmcgdGFy
Z2V0Cj4gbm9kZSIpIHN1ZmZlcnMgZnJvbSBhIHNpbWlsYXIgcHJvYmxlbSBmb3Iga2h1Z2VwYWdl
ZCwgd2hpY2ggaXMgYWxzbwo+IGZpeGVkLgo+Cj4gRml4ZXM6IDA3N2ZjZjExNmM4YyAoIm1tL3Ro
cDogYWxsb2NhdGUgdHJhbnNwYXJlbnQgaHVnZXBhZ2VzIG9uIGxvY2FsIG5vZGUiKQo+IEZpeGVz
OiA5ZjFiODY4YTEzYWMgKCJtbTogdGhwOiBraHVnZXBhZ2VkOiBhZGQgcG9saWN5IGZvciBmaW5k
aW5nIHRhcmdldCBub2RlIikKPiBTaWduZWQtb2ZmLWJ5OiBEYXZpZCBSaWVudGplcyA8cmllbnRq
ZXNAZ29vZ2xlLmNvbT4KCkFja2VkLWJ5OiBWbGFzdGltaWwgQmFia2EgPHZiYWJrYUBzdXNlLmN6
PgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2IG1h
aWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFp
bG1hbi9saXN0aW5mby9kZXYK
