From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v2] taskstats: fix nl parsing in
 accounting/getdelays.c
Date: Wed, 27 Apr 2016 12:56:41 -0400 (EDT)
Message-ID: <20160427.125641.2051987150702050549.davem@davemloft.net>
References: <5720DFA1.3080503@6wind.com>
 <1461772388-3763-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
 herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
 yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1461772388-3763-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

RnJvbTogTmljb2xhcyBEaWNodGVsIDxuaWNvbGFzLmRpY2h0ZWxANndpbmQuY29tPgpEYXRlOiBX
ZWQsIDI3IEFwciAyMDE2IDE3OjUzOjA4ICswMjAwCgo+IFRoZSB0eXBlIFRBU0tTVEFUU19UWVBF
X05VTEwgc2hvdWxkIGFsd2F5cyBiZSBpZ25vcmVkLgo+IAo+IFdoZW4ganVtcGluZyB0byB0aGUg
bmV4dCBhdHRyaWJ1dGUsIG9ubHkgdGhlIGxlbmd0aCBvZiB0aGUgY3VycmVudAo+IGF0dHJpYnV0
ZSBzaG91bGQgYmUgYWRkZWQsIG5vdCB0aGUgbGVuZ3RoIG9mIGFsbCBuZXN0ZWQgYXR0cmlidXRl
cy4KPiBUaGlzIGxhc3QgYnVnIHdhcyBub3QgdmlzaWJsZSBiZWZvcmUgY29tbWl0IDgwZGY1NTQy
NzVjMiwgYmVjYXVzZSB0aGUKPiBrZXJuZWwgZGlkbid0IHB1dCBtb3JlIHRoYW4gdHdvIG5lc3Rl
ZCBhdHRyaWJ1dGVzLgo+IAo+IEZpeGVzOiBhM2JhZjY0OWNhOWMgKCJbUEFUQ0hdIHBlci10YXNr
LWRlbGF5LWFjY291bnRpbmc6IGRvY3VtZW50YXRpb24iKQo+IEZpeGVzOiA4MGRmNTU0Mjc1YzIg
KCJ0YXNrc3RhdHM6IHVzZSB0aGUgbGlibmwgQVBJIHRvIGFsaWduIG5sYXR0ciBvbiA2NC1iaXQi
KQo+IFNpZ25lZC1vZmYtYnk6IE5pY29sYXMgRGljaHRlbCA8bmljb2xhcy5kaWNodGVsQDZ3aW5k
LmNvbT4KCkFwcGxpZWQsIHRoYW5rcy4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6
Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
