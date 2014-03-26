From: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4] core, nfqueue,
 openvswitch: Orphan frags in skb_zerocopy and handle errors
Date: Wed, 26 Mar 2014 22:38:48 +0000
Message-ID: <533356F8.7070307@citrix.com>
References: <1395397894-9493-1-git-send-email-zoltan.kiss@citrix.com>	<20140326.155958.1928261590856069753.davem@davemloft.net>
 <20140326.161242.576245997077162750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso8859-7"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mszeredi-AlSwsSmVLrQ@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, JBeulich-IBi9RG/b67k@public.gmane.org,
 therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
 kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
 jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, Paul.Durrant-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140326.161242.576245997077162750.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

T24gMjYvMDMvMTQgMjA6MTIsIERhdmlkIE1pbGxlciB3cm90ZToKPiBGcm9tOiBEYXZpZCBNaWxs
ZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+Cj4gRGF0ZTogV2VkLCAyNiBNYXIgMjAxNCAxNTo1OTo1
OCAtMDQwMCAoRURUKQo+Cj4+IEZyb206IFpvbHRhbiBLaXNzIDx6b2x0YW4ua2lzc0BjaXRyaXgu
Y29tPgo+PiBEYXRlOiBGcmksIDIxIE1hciAyMDE0IDEwOjMxOjM0ICswMDAwCj4+Cj4+PiBza2Jf
emVyb2NvcHkgY2FuIGNvcHkgZWxlbWVudHMgb2YgdGhlIGZyYWdzIGFycmF5IGJldHdlZW4gc2ti
cywgYnV0IGl0IGRvZXNuJ3QKPj4+IG9ycGhhbiB0aGVtLiBBbHNvLCBpdCBkb2Vzbid0IGhhbmRs
ZSBlcnJvcnMsIHNvIHRoaXMgcGF0Y2ggdGFrZXMgY2FyZSBvZiB0aGF0Cj4+PiBhcyB3ZWxsLCBh
bmQgbW9kaWZ5IHRoZSBjYWxsZXJzIGFjY29yZGluZ2x5LiBza2JfdHhfZXJyb3IoKSBpcyBhbHNv
IGFkZGVkIHRvCj4+PiB0aGUgY2FsbGVycyBzbyB0aGV5IHdpbGwgc2lnbmFsIHRoZSBmYWlsZWQg
ZGVsaXZlcnkgdG93YXJkcyB0aGUgY3JlYXRvciBvZiB0aGUKPj4+IHNrYi4KPj4+Cj4+PiBTaWdu
ZWQtb2ZmLWJ5OiBab2x0YW4gS2lzcyA8em9sdGFuLmtpc3NAY2l0cml4LmNvbT4KPj4KPj4gQXBw
bGllZCwgdGhhbmtzIFpvbHRhbi4KPgo+IEFjdHVhbGx5LCBab2x0YW4sIHlvdSBoYXZlIHRvIGZp
eCB0aGlzOgo+Cj4gbmV0L2NvcmUvc2tidWZmLmM6IEluIGZ1bmN0aW9uIKFza2JfemVyb2NvcHmi
Ogo+IG5ldC9jb3JlL3NrYnVmZi5jOjIxNzI6Mjogd2FybmluZzogcGFzc2luZyBhcmd1bWVudCAx
IG9mIKFza2Jfb3JwaGFuX2ZyYWdzoiBkaXNjYXJkcyChY29uc3SiIHF1YWxpZmkKPiBlciBmcm9t
IHBvaW50ZXIgdGFyZ2V0IHR5cGUgW2VuYWJsZWQgYnkgZGVmYXVsdF0KPiBJbiBmaWxlIGluY2x1
ZGVkIGZyb20gaW5jbHVkZS9saW51eC90Y3AuaDoyMTowLAo+ICAgICAgICAgICAgICAgICAgIGZy
b20gbmV0L2NvcmUvc2tidWZmLmM6NTA6Cj4gaW5jbHVkZS9saW51eC9za2J1ZmYuaDoxOTA0OjE5
OiBub3RlOiBleHBlY3RlZCChc3RydWN0IHNrX2J1ZmYgKqIgYnV0IGFyZ3VtZW50IGlzIG9mIHR5
cGUgoWNvbnN0IHN0cgo+IHVjdCBza19idWZmICqiCj4gbmV0L2NvcmUvc2tidWZmLmM6MjE3Mzoz
OiB3YXJuaW5nOiBwYXNzaW5nIGFyZ3VtZW50IDEgb2YgoXNrYl90eF9lcnJvcqIgZGlzY2FyZHMg
oWNvbnN0oiBxdWFsaWZpZXIgZgo+IHJvbSBwb2ludGVyIHRhcmdldCB0eXBlIFtlbmFibGVkIGJ5
IGRlZmF1bHRdCj4gbmV0L2NvcmUvc2tidWZmLmM6NjQyOjY6IG5vdGU6IGV4cGVjdGVkIKFzdHJ1
Y3Qgc2tfYnVmZiAqoiBidXQgYXJndW1lbnQgaXMgb2YgdHlwZSChY29uc3Qgc3RydWN0IHNrXwo+
IGJ1ZmYgKqIKPgoKT2ssIHJlc3VibWl0dGVkLiAnZnJvbScgaXMgbm93IG5vdCBhIGNvbnN0IHBh
cmFtZXRlciwgYmVjYXVzZSAKc2tiLT5wZm1lbWFsbG9jIG1pZ2h0IGNoYW5nZS4KClpvbGkKX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2IG1haWxpbmcg
bGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9s
aXN0aW5mby9kZXYK
