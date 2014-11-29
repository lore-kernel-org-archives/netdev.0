From: nick <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] drivers:net:wireless: Add mutex locking for function,
 b43_op_beacon_set_time in main.c
Date: Sat, 29 Nov 2014 13:09:09 -0500
Message-ID: <547A0BC5.2080005@gmail.com>
References: <1417213013-19758-1-git-send-email-xerofoify@gmail.com>	<CACna6rxmOC0h9hOpa=5iWFM1THQ8Q4hCi8MnmqkZJbB_U0PJ0A@mail.gmail.com>	<20141129002148.1beb21d9@wiggum>	<54793E4E.7050602@gmail.com>	<20141129095632.69361457@wiggum>
 <CACna6ryjZ-LY06wAMzoL77Wca3McUUT+VYsO4EPO87NqjBnaNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
 b43-dev <b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, =?UTF-8?B?TWljaGE=?=
 =?UTF-8?B?ZWwgQsO8c2No?= <m@bues.ch>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CACna6ryjZ-LY06wAMzoL77Wca3McUUT+VYsO4EPO87NqjBnaNw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

U29ycnkgYWJvdXQgdGhhdCwgbmV4dCB0aW1lIEkgd2lsbCBiZSBtb3JlIGNhcmVmdWwuCk5pY2sK
Ck9uIDIwMTQtMTEtMjkgMDQ6MDQgQU0sIFJhZmHFgiBNacWCZWNraSB3cm90ZToKPiBPbiAyOSBO
b3ZlbWJlciAyMDE0IGF0IDA5OjU2LCBNaWNoYWVsIELDvHNjaCA8bUBidWVzLmNoPiB3cm90ZToK
Pj4gT24gRnJpLCAyOCBOb3YgMjAxNCAyMjozMjozMCAtMDUwMAo+PiBuaWNrIDx4ZXJvZm9pZnlA
Z21haWwuY29tPiB3cm90ZToKPj4KPj4+IEkgZG9uJ3QgaGF2ZSBoYXJkd2FyZSBmb3IgdGhpcyBk
cml2ZXIgb24gbWUsIHNvIEkgZGlkbid0IHRlc3QgaXQuIEhvd2V2ZXIgdGhpcyBzZWVtcyB0bwo+
Pj4gYmUgY29ycmVjdCBmcm9tIG15IHJlYWRpbmcgb2YgdGhlIGNvZGUgYXJvdW5kIHRoaXMgZnVu
Y3Rpb24gYW5kIG90aGVyIGxvY2tpbmcgcmVsYXRlZAo+Pj4gdG8gdGhpcyBkcml2ZXIuCj4+Cj4+
IEZyb20gdGhlIGN1cnJlbnQgZG9jczoKPj4KPj4+ICAqIEBzZXRfdGltOiBTZXQgVElNIGJpdC4g
bWFjODAyMTEgY2FsbHMgdGhpcyBmdW5jdGlvbiB3aGVuIGEgVElNIGJpdAo+Pj4gICogICAgICBt
dXN0IGJlIHNldCBvciBjbGVhcmVkIGZvciBhIGdpdmVuIFNUQS4gTXVzdCBiZSBhdG9taWMuCj4+
Cj4+IFNvIGl0IGlzIG5vdCBhbGxvd2VkIHRvIGxvY2sgYSBtdXRleCBoZXJlLgo+IAo+IE5pY2hv
bGFzIHBsZWFzZSBiZSBtb3JlIGNhcmVmdWwgd2l0aCB5b3VyIHBhdGNoZXMuIEl0IHNlZW1zIHlv
dXIgcGF0Y2gKPiBpcyB3cm9uZywgeW91IGRpZG4ndCBjaGVjayB0aGUgZG9jcyBhbmQgeW91IGRp
ZG4ndCBldmVuIHNheSBpbiB0aGUKPiBmaXJzdCBwbGFjZSB0aGF0IGl0IHdhc24ndCB0ZXN0ZWQu
IFlvdSBjb3VsZCBhdCBsZWFzdCBzdWJtaXQgd2l0aCB3aXRoCj4gUkZUIHRhZyBvciBzdGguCj4g
CgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpiNDMtZGV2
IG1haWxpbmcgbGlzdApiNDMtZGV2QGxpc3RzLmluZnJhZGVhZC5vcmcKaHR0cDovL2xpc3RzLmlu
ZnJhZGVhZC5vcmcvbWFpbG1hbi9saXN0aW5mby9iNDMtZGV2Cg==
