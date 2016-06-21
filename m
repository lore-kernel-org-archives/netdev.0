From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [6/6] ppc: ebpf/jit: Implement JIT compiler for extended BPF
Date: Tue, 21 Jun 2016 21:04:03 +1000
Message-ID: <1466507043.18876.1.camel@ellerman.id.au>
References: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <3rWKtT2tSrz9t2G@ozlabs.org>
 <20160619173642.GB8886@naverao1-tp.localdomain>
 <1466465899.437.0.camel@ellerman.id.au>
 <20160621065847.GD8886@naverao1-tp.localdomain>
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
In-Reply-To: <20160621065847.GD8886@naverao1-tp.localdomain>
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

T24gVHVlLCAyMDE2LTA2LTIxIGF0IDEyOjI4ICswNTMwLCBOYXZlZW4gTi4gUmFvIHdyb3RlOgo+
IE9uIDIwMTYvMDYvMjEgMDk6MzhBTSwgTWljaGFlbCBFbGxlcm1hbiB3cm90ZToKPiA+IE9uIFN1
biwgMjAxNi0wNi0xOSBhdCAyMzowNiArMDUzMCwgTmF2ZWVuIE4uIFJhbyB3cm90ZToKPiA+ID4g
Cj4gPiA+ICNpbmNsdWRlIDxhc20va3Byb2Jlcy5oPgo+ID4gPiAKPiA+ID4gaW4gYnBmX2ppdF9j
b21wNjQuYwo+ID4gPiAKPiA+ID4gQ2FuIHlvdSBwbGVhc2UgY2hlY2sgaWYgaXQgcmVzb2x2ZXMg
dGhlIGJ1aWxkIGVycm9yPwo+ID4gCj4gPiBDYW4geW91PyA6RAo+IAo+IDopCj4gU29ycnksIEkg
c2hvdWxkIGhhdmUgZXhwbGFpbmVkIG15c2VsZiBiZXR0ZXIuIEkgZGlkIGFjdHVhbGx5IHRyeSB5
b3VyIAo+IGNvbmZpZyBhbmQgSSB3YXMgYWJsZSB0byByZXByb2R1Y2UgdGhlIGJ1aWxkIGVycm9y
LiBBZnRlciB0aGUgYWJvdmUgCj4gI2luY2x1ZGUsIHRoYXQgZXJyb3Igd2VudCBhd2F5LCBidXQg
SSBzYXcgc29tZSB2ZHNvIHJlbGF0ZWQgZXJyb3JzLiBJIAo+IHRob3VnaHQgSSB3YXMgZG9pbmcg
c29tZXRoaW5nIHdyb25nIGFuZCBuZWVkZWQgYSBkaWZmZXJlbnQgc2V0dXAgZm9yIAo+IHRoYXQg
cGFydGljdWxhciBrZXJuZWwgY29uZmlnLCB3aGljaCBpcyB3aHkgSSByZXF1ZXN0ZWQgeW91ciBo
ZWxwIGluIHRoZSAKPiBtYXR0ZXIuIEkganVzdCBkaWRuJ3QgZG8gYSBnb29kIGpvYiBvZiBwdXR0
aW5nIGFjcm9zcyB0aGF0IG1lc3NhZ2UuLi4KIApBaCBPSy4gTm90IHN1cmUgd2h5IHlvdSdyZSBz
ZWVpbmcgVkRTTyBlcnJvcnM/Cgo+IE5vdGUgdG8gc2VsZjogcmFuZGNvbmZpZyBidWlsZHMgKmFu
ZCogbW9yZSB0aW1lIGRyYWZ0aW5nIGVtYWlscyA6KQoKTm8gc3RyZXNzLiBZb3UgZG9uJ3QgbmVl
ZCB0byBkbyByYW5kY29uZmlnIGJ1aWxkcywgb3IgZXZlbiBidWlsZCBhbGwgdGhlCmFyY2gvcG93
ZXJwYy8gY29uZmlncywganVzdCB0cnkgdG8gZG8gYSByZWFzb25hYmxlIHNldCwgc29tZXRoaW5n
IGxpa2UgLSBwcGM2NCwKcG93ZXJudiwgcHNlcmllcywgcG1hYzMyLCBwcGM2NGUuCgpJJ20gaGFw
cHkgdG8gY2F0Y2ggdGhlIGVzb3RlcmljIGJ1aWxkIGZhaWx1cmVzLgoKPiBEbyB5b3Ugd2FudCBt
ZSB0byByZXNwaW4gdGhlIHBhdGNoZXM/CgpObyB0aGF0J3MgZmluZSwgSSdsbCBmaXggaXQgdXAg
aGVyZS4KCmNoZWVycwoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KTGludXhwcGMtZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJz
Lm9yZwpodHRwczovL2xpc3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2
