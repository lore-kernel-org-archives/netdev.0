From: "Gao Feng" <gfree.wind@vip.163.com>
Subject: Re:Re: [net PATCH] net: sched: Fix one possible panic when no
 destroy callback
Date: Wed, 28 Jun 2017 08:54:53 +0800 (CST)
Message-ID: <6da470a2.7d57.15cec319c03.Coremail.gfree.wind@vip.163.com>
References: <1498527333-86838-1-git-send-email-gfree.wind@vip.163.com>
 <CAM_iQpXRy=cC2vuhju2Jf9=sJ+Yc6DvkzvFEU_DrRonyhW+E9w@mail.gmail.com>
 <1498582211.736.118.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUx8d_vQT=1d06Ah-d+E5R_10pnvcy4Y9ac_=txanPBOw@mail.gmail.com>
 <1498585790.736.135.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Cc: "Cong Wang" <xiyou.wangcong@gmail.com>,
        "Jamal Hadi Salim" <jhs@mojatatu.com>,
        "Jiri Pirko" <jiri@resnulli.us>,
        "David Miller" <davem@davemloft.net>,
        "Linux Kernel Network Developers" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m171-177.vip.163.com ([123.58.177.171]:35719 "EHLO
        m171-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752764AbdF1A7W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 20:59:22 -0400
In-Reply-To: <1498585790.736.135.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

QXQgMjAxNy0wNi0yOCAwMTo0OTo1MCwgIkVyaWMgRHVtYXpldCIgPGVyaWMuZHVtYXpldEBnbWFp
bC5jb20+IHdyb3RlOgo+T24gVHVlLCAyMDE3LTA2LTI3IGF0IDEwOjA4IC0wNzAwLCBDb25nIFdh
bmcgd3JvdGU6Cj4+IE9uIFR1ZSwgSnVuIDI3LCAyMDE3IGF0IDk6NTAgQU0sIEVyaWMgRHVtYXpl
dCA8ZXJpYy5kdW1hemV0QGdtYWlsLmNvbT4gd3JvdGU6Cj4+ID4gT24gVHVlLCAyMDE3LTA2LTI3
IGF0IDA5OjMwIC0wNzAwLCBDb25nIFdhbmcgd3JvdGU6Cj4+ID4+IE9uIE1vbiwgSnVuIDI2LCAy
MDE3IGF0IDY6MzUgUE0sICA8Z2ZyZWUud2luZEB2aXAuMTYzLmNvbT4gd3JvdGU6Cj4+ID4+ID4g
RnJvbTogR2FvIEZlbmcgPGdmcmVlLndpbmRAdmlwLjE2My5jb20+Cj4+ID4+ID4KPj4gPj4gPiBX
aGVuIHFkaXNjIGZhaWwgdG8gaW5pdCwgcWRpc2NfY3JlYXRlIHdvdWxkIGludm9rZSB0aGUgZGVz
dHJveSBjYWxsYmFjawo+PiA+PiA+IHRvIGNsZWFudXAuIEJ1dCB0aGVyZSBpcyBubyBjaGVjayBp
ZiB0aGUgY2FsbGJhY2sgZXhpc3RzIHJlYWxseS4gU28gaXQKPj4gPj4gPiB3b3VsZCBjYXVzZSB0
aGUgcGFuaWMgaWYgdGhlcmUgaXMgbm8gcmVhbCBkZXN0cm95IGNhbGxiYWNrIGxpa2UgdGhlc2UK
Pj4gPj4gPiBxZGlzYyBjb2RlbCwgcGZpZm8sIHBmaWZvX2Zhc3QsIGFuZCBzbyBvbi4KPj4gPj4g
Pgo+PiA+PiA+IE5vdyBhZGQgb25lIHRoZSBjaGVjayBmb3IgZGVzdHJveSB0byBhdm9pZCB0aGUg
cG9zc2libGUgcGFuaWMuCj4+ID4+ID4KPj4gPj4gPiBTaWduZWQtb2ZmLWJ5OiBHYW8gRmVuZyA8
Z2ZyZWUud2luZEB2aXAuMTYzLmNvbT4KPj4gPj4KPj4gPj4gTG9va3MgZ29vZCwKPj4gPj4KPj4g
Pj4gQWNrZWQtYnk6IENvbmcgV2FuZyA8eGl5b3Uud2FuZ2NvbmdAZ21haWwuY29tPgo+PiA+Pgo+
PiA+PiBUaGlzIGlzIGludHJvZHVjZWQgYnkgY29tbWl0IDg3YjYwY2ZhY2Y5ZjE3Y2Y3MTkzM2M2
ZTMzYi4KPj4gPj4gUGxlYXNlIGFkZCBwcm9wZXIgRml4ZXMgdGFnIG5leHQgdGltZS4KCk9LLiBB
Y3R1YWxseSBJIGRpZG4ndCBrbm93IGl0IGlzIGludHJvZHVjZWQgYnkgdGhpcyBjb21taXQgYmVm
b3JlIDopCk5lZWQgSSBzZW5kIGFuIHVwZGF0ZSBwYXRjaCBhZ2FpbiA/Cgo+PiA+Cj4+ID4gR2l2
ZW4gdGhhdCBwZmlmbywgcGZpZm9fZmFzdCBvciBjb2RlbCBjYW4gbm90IGZhaWwgdGhlaXIgaW5p
dCwKPj4gCj4+IAo+PiBIb3cgYWJvdXQgY29kZWxfaW5pdCgpIC0+IGNvZGVsX2NoYW5nZSgpIC0+
IG5sYV9wYXJzZV9uZXN0ZWQoKSA/Cj4KPgo+WWVhaCwgd2l0aCBhIG1hbGljaW91cyB1c2VyIHNw
YWNlIHRoZW4gKGlwcm91dGUyL3RjIGlzIGZpbmUpLCBjb2RlbAo+Y291bGQgYmUgcHJvYmxlbWF0
aWMuCj4KPnBmaWZvIGFuZCBwZmlmb19mYXN0IGNhbiBkZWZpbml0ZWx5IG5vdCBoaXQgdGhpcyBi
dWcuCj4KPmNoYW5nZWxvZyBuZWVkcyBhIGJpdCBvZiBhdHRlbnRpb24sIGV2ZW4gaWYgdGhlIGJ1
ZyBpcyByZWFsLgo+Cj5UaGFua3MuCj4KPgoKWWVzLCB0aGUgY29kZWwgY291bGQgZmFpbCB0byBp
bml0LCBhbmQgdGhlIGZpZm8vcGZpZm8gY291bGQgZmFpbGVkIFdoZW4gIm5sYV9sZW4ob3B0KSA8
IHNpemVvZigqY3RsKSIuCgpCZXN0IFJlZ2FyZHMKRmVuZwoKCg==
