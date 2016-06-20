From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [6/6] ppc: ebpf/jit: Implement JIT compiler for extended BPF
Date: Tue, 21 Jun 2016 09:38:19 +1000
Message-ID: <1466465899.437.0.camel@ellerman.id.au>
References: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <3rWKtT2tSrz9t2G@ozlabs.org>
 <20160619173642.GB8886@naverao1-tp.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Matt Evans <matt@ozlabs.org>, Daniel Borkmann <daniel@iogearbox.net>,
 Alexei Starovoitov <ast@fb.com>, netdev@vger.kernel.org,
 Denis Kirjanov <kda@linux-powerpc.org>, linux-kernel@vger.kernel.org,
 Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, "David S.
 Miller" <davem@davemloft.net>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20160619173642.GB8886@naverao1-tp.localdomain>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

T24gU3VuLCAyMDE2LTA2LTE5IGF0IDIzOjA2ICswNTMwLCBOYXZlZW4gTi4gUmFvIHdyb3RlOgo+
IE9uIDIwMTYvMDYvMTcgMTA6NTNQTSwgTWljaGFlbCBFbGxlcm1hbiB3cm90ZToKPiA+IE9uIFR1
ZSwgMjAxNi0wNy0wNiBhdCAxMzozMjoyMyBVVEMsICJOYXZlZW4gTi4gUmFvIiB3cm90ZToKPiA+
ID4gZGlmZiAtLWdpdCBhL2FyY2gvcG93ZXJwYy9uZXQvYnBmX2ppdF9jb21wNjQuYyBiL2FyY2gv
cG93ZXJwYy9uZXQvYnBmX2ppdF9jb21wNjQuYwo+ID4gPiBuZXcgZmlsZSBtb2RlIDEwMDY0NAo+
ID4gPiBpbmRleCAwMDAwMDAwLi45NTRmZjUzCj4gPiA+IC0tLSAvZGV2L251bGwKPiA+ID4gKysr
IGIvYXJjaC9wb3dlcnBjL25ldC9icGZfaml0X2NvbXA2NC5jCj4gPiA+IEBAIC0wLDAgKzEsOTU2
IEBACj4gPiAuLi4KCj4gPiA+ICsKPiA+ID4gK3N0YXRpYyB2b2lkIGJwZl9qaXRfZmlsbF9pbGxf
aW5zbnModm9pZCAqYXJlYSwgdW5zaWduZWQgaW50IHNpemUpCj4gPiA+ICt7Cj4gPiA+ICsJaW50
ICpwID0gYXJlYTsKPiA+ID4gKwo+ID4gPiArCS8qIEZpbGwgd2hvbGUgc3BhY2Ugd2l0aCB0cmFw
IGluc3RydWN0aW9ucyAqLwo+ID4gPiArCXdoaWxlIChwIDwgKGludCAqKSgoY2hhciAqKWFyZWEg
KyBzaXplKSkKPiA+ID4gKwkJKnArKyA9IEJSRUFLUE9JTlRfSU5TVFJVQ1RJT047Cj4gPiA+ICt9
Cj4gPiAKPiA+IFRoaXMgYnJlYWtzIHRoZSBidWlsZCBmb3Igc29tZSBjb25maWdzLCBwcmVzdW1h
Ymx5IHlvdSdyZSBtaXNzaW5nIGEgaGVhZGVyOgo+ID4gCj4gPiAgIGFyY2gvcG93ZXJwYy9uZXQv
YnBmX2ppdF9jb21wNjQuYzozMDoxMDogZXJyb3I6ICdCUkVBS1BPSU5UX0lOU1RSVUNUSU9OJyB1
bmRlY2xhcmVkIChmaXJzdCB1c2UgaW4gdGhpcyBmdW5jdGlvbikKPiA+IAo+ID4gaHR0cDovL2tp
c3NrYi5lbGxlcm1hbi5pZC5hdS9raXNza2IvYnVpbGRyZXN1bHQvMTI3MjA2MTEvCj4gCj4gT29w
cy4gWWVzLCBJIHNob3VsZCBoYXZlIGNhdWdodCB0aGF0LiBJIG5lZWQgdG8gYWRkOgo+IAo+ICNp
bmNsdWRlIDxhc20va3Byb2Jlcy5oPgo+IAo+IGluIGJwZl9qaXRfY29tcDY0LmMKPiAKPiBDYW4g
eW91IHBsZWFzZSBjaGVjayBpZiBpdCByZXNvbHZlcyB0aGUgYnVpbGQgZXJyb3I/CgpDYW4geW91
PyA6RAoKY2hlZXJzCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpMaW51eHBwYy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMu
b3JnCmh0dHBzOi8vbGlzdHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBwYy1kZXY=
