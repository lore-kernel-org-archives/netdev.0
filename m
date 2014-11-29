From: nick <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] drivers:net:wireless: Add mutex locking for function,
 b43_op_beacon_set_time in main.c
Date: Fri, 28 Nov 2014 22:32:30 -0500
Message-ID: <54793E4E.7050602@gmail.com>
References: <1417213013-19758-1-git-send-email-xerofoify@gmail.com>	<CACna6rxmOC0h9hOpa=5iWFM1THQ8Q4hCi8MnmqkZJbB_U0PJ0A@mail.gmail.com>
 <20141129002148.1beb21d9@wiggum>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
 b43-dev <b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: =?UTF-8?B?TWljaGFlbCBCw7xzY2g=?= <m@bues.ch>, =?UTF-8?B?UmFmYcWCIE1pxYI=?=
 =?UTF-8?B?ZWNraQ==?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20141129002148.1beb21d9@wiggum>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

TWljaGFlbCwKSSBkb24ndCBoYXZlIGhhcmR3YXJlIGZvciB0aGlzIGRyaXZlciBvbiBtZSwgc28g
SSBkaWRuJ3QgdGVzdCBpdC4gSG93ZXZlciB0aGlzIHNlZW1zIHRvIApiZSBjb3JyZWN0IGZyb20g
bXkgcmVhZGluZyBvZiB0aGUgY29kZSBhcm91bmQgdGhpcyBmdW5jdGlvbiBhbmQgb3RoZXIgbG9j
a2luZyByZWxhdGVkCnRvIHRoaXMgZHJpdmVyLgpDaGVlcnMgTmljawoKT24gMjAxNC0xMS0yOCAw
NjoyMSBQTSwgTWljaGFlbCBCw7xzY2ggd3JvdGU6Cj4gT24gRnJpLCAyOCBOb3YgMjAxNCAyMzo0
MDo0NiArMDEwMAo+IFJhZmHFgiBNacWCZWNraSA8emFqZWM1QGdtYWlsLmNvbT4gd3JvdGU6Cj4g
Cj4+PiBAQCAtNTA5NCw4ICs1MDk0LDkgQEAgc3RhdGljIGludCBiNDNfb3BfYmVhY29uX3NldF90
aW0oc3RydWN0IGllZWU4MDIxMV9odyAqaHcsCj4+PiAgewo+Pj4gICAgICAgICBzdHJ1Y3QgYjQz
X3dsICp3bCA9IGh3X3RvX2I0M193bChodyk7Cj4+Pgo+Pj4gLSAgICAgICAvKiBGSVhNRTogYWRk
IGxvY2tpbmcgKi8KPj4+ICsgICAgICAgbXV0ZXhfbG9jaygmd2wtPm11dGV4KTsKPj4+ICAgICAg
ICAgYjQzX3VwZGF0ZV90ZW1wbGF0ZXMod2wpOwo+Pj4gKyAgICAgICBtdXRleF91bmxvY2soJnds
LT5tdXRleCk7Cj4+Pgo+Pj4gICAgICAgICByZXR1cm4gMDsKPj4+ICB9Cj4+Cj4+IERvZXMgYW55
b25lIHJlbWVtYmVyIHdoeSB0aGlzIHNpbXBsZSBzb2x1dGlvbiB3YXNuJ3QgaW1wbGVtZW50ZWQK
Pj4gZWFybGllcj8gTWljaGFlbD8KPiAKPiBJIHRoaW5rIHRoZSBjYWxsYmFjayB1c2VkIHRvIGJl
IChpcz8pIGluIGF0b21pYyBjb250ZXh0Lgo+IAo+PiBOaWNob2xhczogZGlkIHlvdSB0ZXN0IGl0
IGFueWhvdz8KPiAKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCmI0My1kZXYgbWFpbGluZyBsaXN0CmI0My1kZXZAbGlzdHMuaW5mcmFkZWFkLm9yZwpodHRw
Oi8vbGlzdHMuaW5mcmFkZWFkLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2I0My1kZXYK
