From: "Gao Feng" <gfree.wind@vip.163.com>
Subject: Re:Re: [PATCH net] ppp: fix xmit recursion detection on ppp
 channels
Date: Tue, 8 Aug 2017 22:21:58 +0800 (CST)
Message-ID: <22bd4c3b.1578c.15dc2394057.Coremail.gfree.wind@vip.163.com>
References: <e45ed6ea02e2665ec8b868279ad9afcb9b34fc81.1502185216.git.g.nault@alphalink.fr>
 <5a62fd3f.e0c3.15dc1fd5f1b.Coremail.gfree.wind@vip.163.com>
 <20170808135827.oszy6ikqi2gw5cs7@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, "Liu Jianying" <jianying.liu@ikuai8.com>,
        "David Miller" <davem@davemloft.net>, linux-ppp@vger.kernel.org,
        "Paul Mackerras" <paulus@samba.org>
To: "Guillaume Nault" <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m175-177.vip.163.com ([123.58.177.175]:60276 "EHLO
        m175-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752010AbdHHOWY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 10:22:24 -0400
In-Reply-To: <20170808135827.oszy6ikqi2gw5cs7@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CkF0IDIwMTctMDgtMDggMjE6NTg6MjcsICJHdWlsbGF1bWUgTmF1bHQiIDxnLm5hdWx0QGFscGhh
bGluay5mcj4gd3JvdGU6Cj5PbiBUdWUsIEF1ZyAwOCwgMjAxNyBhdCAwOToxNjozM1BNICswODAw
LCBHYW8gRmVuZyB3cm90ZToKPj4gQXQgMjAxNy0wOC0wOCAxNzo0MzoyNCwgIkd1aWxsYXVtZSBO
YXVsdCIgPGcubmF1bHRAYWxwaGFsaW5rLmZyPiB3cm90ZToKPj4gPi0tLSBhL2RyaXZlcnMvbmV0
L3BwcC9wcHBfZ2VuZXJpYy5jCj4+ID4rKysgYi9kcml2ZXJzL25ldC9wcHAvcHBwX2dlbmVyaWMu
Ywo+PiA+QEAgLTE5MTUsMjEgKzE5MTUsMjMgQEAgc3RhdGljIHZvaWQgX19wcHBfY2hhbm5lbF9w
dXNoKHN0cnVjdCBjaGFubmVsICpwY2gpCj4+ID4gCXNwaW5fdW5sb2NrKCZwY2gtPmRvd25sKTsK
Pj4gPiAJLyogc2VlIGlmIHRoZXJlIGlzIGFueXRoaW5nIGZyb20gdGhlIGF0dGFjaGVkIHVuaXQg
dG8gYmUgc2VudCAqLwo+PiA+IAlpZiAoc2tiX3F1ZXVlX2VtcHR5KCZwY2gtPmZpbGUueHEpKSB7
Cj4+ID4tCQlyZWFkX2xvY2soJnBjaC0+dXBsKTsKPj4gPiAJCXBwcCA9IHBjaC0+cHBwOwo+PiA+
IAkJaWYgKHBwcCkKPj4gPi0JCQlwcHBfeG1pdF9wcm9jZXNzKHBwcCk7Cj4+ID4tCQlyZWFkX3Vu
bG9jaygmcGNoLT51cGwpOwo+PiA+KwkJCV9fcHBwX3htaXRfcHJvY2VzcyhwcHApOwo+PiA+IAl9
Cj4+ID4gfQo+PiA+IAo+PiA+IHN0YXRpYyB2b2lkIHBwcF9jaGFubmVsX3B1c2goc3RydWN0IGNo
YW5uZWwgKnBjaCkKPj4gPiB7Cj4+ID4tCWxvY2FsX2JoX2Rpc2FibGUoKTsKPj4gPi0KPj4gPi0J
X19wcHBfY2hhbm5lbF9wdXNoKHBjaCk7Cj4+ID4tCj4+ID4tCWxvY2FsX2JoX2VuYWJsZSgpOwo+
PiA+KwlyZWFkX2xvY2tfYmgoJnBjaC0+dXBsKTsKPj4gPisJaWYgKHBjaC0+cHBwKSB7Cj4+ID4r
CQkoKnRoaXNfY3B1X3B0cihwY2gtPnBwcC0+eG1pdF9yZWN1cnNpb24pKSsrOwo+PiA+KwkJX19w
cHBfY2hhbm5lbF9wdXNoKHBjaCk7Cj4+ID4rCQkoKnRoaXNfY3B1X3B0cihwY2gtPnBwcC0+eG1p
dF9yZWN1cnNpb24pKS0tOwo+PiA+Kwl9IGVsc2Ugewo+PiA+KwkJX19wcHBfY2hhbm5lbF9wdXNo
KHBjaCk7Cj4+ID4rCX0KPj4gPisJcmVhZF91bmxvY2tfYmgoJnBjaC0+dXBsKTsKPj4gCj4+IElm
IGludm9rZWQgcmVhZF9sb2NrX2JoIGluIHBwcF9jaGFubmVsX3B1c2gsIGl0IHdvdWxkIGJlIHVu
bmVjZXNzYXJ5IHRvIGludm9rZSByZWFkX2xvY2soJnBjaC0+dXBsKQo+PiBpbiB0aGUgX19wcHBf
Y2hhbm5lbF9wdXNoLgo+PiAKPkJ1dCB0aGlzIHBhdGNoIGRvZXMgcmVtb3ZlIHJlYWRfbG9jaygm
cGNoLT51cGwpIGZyb20KPl9fcHBwX2NoYW5uZWxfcHVzaCgpLiBPciBoYXZlIEkgbWlzdW5kZXJz
dG9vZCB5b3VyIHBvaW50PwoKU29ycnksIGl0J3MgbXkgZmF1bHQuCkkgZm9yZ290IHlvdXIgZm9y
bWVyIGNoYW5nZXMgd2hlbiB0aGluayBhYm91dCB0aGUgdXBkYXRlcyBpbiBwcHBfY2hhbm5lbF9w
dXNoCgpCZXN0IFJlZ2FyZHMKRmVuZwoK
