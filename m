From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v4] core, nfqueue,
 openvswitch: Orphan frags in skb_zerocopy and handle errors
Date: Wed, 26 Mar 2014 16:12:42 -0400 (EDT)
Message-ID: <20140326.161242.576245997077162750.davem@davemloft.net>
References: <1395397894-9493-1-git-send-email-zoltan.kiss@citrix.com>
 <20140326.155958.1928261590856069753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso8859-7"
Content-Transfer-Encoding: base64
Cc: netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mszeredi-AlSwsSmVLrQ@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, JBeulich-IBi9RG/b67k@public.gmane.org,
 therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
 kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
 jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, Paul.Durrant-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
To: zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140326.155958.1928261590856069753.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogV2VkLCAyNiBN
YXIgMjAxNCAxNTo1OTo1OCAtMDQwMCAoRURUKQ0KDQo+IEZyb206IFpvbHRhbiBLaXNzIDx6b2x0
YW4ua2lzc0BjaXRyaXguY29tPg0KPiBEYXRlOiBGcmksIDIxIE1hciAyMDE0IDEwOjMxOjM0ICsw
MDAwDQo+IA0KPj4gc2tiX3plcm9jb3B5IGNhbiBjb3B5IGVsZW1lbnRzIG9mIHRoZSBmcmFncyBh
cnJheSBiZXR3ZWVuIHNrYnMsIGJ1dCBpdCBkb2Vzbid0DQo+PiBvcnBoYW4gdGhlbS4gQWxzbywg
aXQgZG9lc24ndCBoYW5kbGUgZXJyb3JzLCBzbyB0aGlzIHBhdGNoIHRha2VzIGNhcmUgb2YgdGhh
dA0KPj4gYXMgd2VsbCwgYW5kIG1vZGlmeSB0aGUgY2FsbGVycyBhY2NvcmRpbmdseS4gc2tiX3R4
X2Vycm9yKCkgaXMgYWxzbyBhZGRlZCB0bw0KPj4gdGhlIGNhbGxlcnMgc28gdGhleSB3aWxsIHNp
Z25hbCB0aGUgZmFpbGVkIGRlbGl2ZXJ5IHRvd2FyZHMgdGhlIGNyZWF0b3Igb2YgdGhlDQo+PiBz
a2IuDQo+PiANCj4+IFNpZ25lZC1vZmYtYnk6IFpvbHRhbiBLaXNzIDx6b2x0YW4ua2lzc0BjaXRy
aXguY29tPg0KPiANCj4gQXBwbGllZCwgdGhhbmtzIFpvbHRhbi4NCg0KQWN0dWFsbHksIFpvbHRh
biwgeW91IGhhdmUgdG8gZml4IHRoaXM6DQoNCm5ldC9jb3JlL3NrYnVmZi5jOiBJbiBmdW5jdGlv
biChc2tiX3plcm9jb3B5ojoNCm5ldC9jb3JlL3NrYnVmZi5jOjIxNzI6Mjogd2FybmluZzogcGFz
c2luZyBhcmd1bWVudCAxIG9mIKFza2Jfb3JwaGFuX2ZyYWdzoiBkaXNjYXJkcyChY29uc3SiIHF1
YWxpZmkNCmVyIGZyb20gcG9pbnRlciB0YXJnZXQgdHlwZSBbZW5hYmxlZCBieSBkZWZhdWx0XQ0K
SW4gZmlsZSBpbmNsdWRlZCBmcm9tIGluY2x1ZGUvbGludXgvdGNwLmg6MjE6MCwNCiAgICAgICAg
ICAgICAgICAgZnJvbSBuZXQvY29yZS9za2J1ZmYuYzo1MDoNCmluY2x1ZGUvbGludXgvc2tidWZm
Lmg6MTkwNDoxOTogbm90ZTogZXhwZWN0ZWQgoXN0cnVjdCBza19idWZmICqiIGJ1dCBhcmd1bWVu
dCBpcyBvZiB0eXBlIKFjb25zdCBzdHINCnVjdCBza19idWZmICqiDQpuZXQvY29yZS9za2J1ZmYu
YzoyMTczOjM6IHdhcm5pbmc6IHBhc3NpbmcgYXJndW1lbnQgMSBvZiChc2tiX3R4X2Vycm9yoiBk
aXNjYXJkcyChY29uc3SiIHF1YWxpZmllciBmDQpyb20gcG9pbnRlciB0YXJnZXQgdHlwZSBbZW5h
YmxlZCBieSBkZWZhdWx0XQ0KbmV0L2NvcmUvc2tidWZmLmM6NjQyOjY6IG5vdGU6IGV4cGVjdGVk
IKFzdHJ1Y3Qgc2tfYnVmZiAqoiBidXQgYXJndW1lbnQgaXMgb2YgdHlwZSChY29uc3Qgc3RydWN0
IHNrXw0KYnVmZiAqog0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3
aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
