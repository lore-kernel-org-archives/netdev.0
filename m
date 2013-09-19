From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] USBNET: fix handling padding packet
Date: Thu, 19 Sep 2013 09:29:07 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B734A@saturn3.aculab.com>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com><878uyu6xjm.fsf@nemi.mork.no><CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com><87zjra5dpx.fsf@nemi.mork.no><1379523984.2430.3.camel@linux-fkkt.site><be5ecff3-27e1-4ab7-b3af-9d7c4376140f@email.android.com><1379573843.8608.7.camel@linux-fkkt.site> <87wqmd46vj.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: "Ming Lei" <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	"Network Development" <netdev@vger.kernel.org>,
	"linux-usb" <linux-usb@vger.kernel.org>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	"Oliver Neukum" <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43115 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751828Ab3ISIa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Sep 2013 04:30:58 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15798-10 for <netdev@vger.kernel.org>;
 Thu, 19 Sep 2013 09:30:54 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <87wqmd46vj.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBJIHdvbmRlciB3aGF0IHRoZSBnYWluIG9mIHRoYXQgcmVhbGx5IGlzPyAgWWVzLCBJIGNhbiBz
ZWUgdGhlIGFkdmFudGFnZQ0KPiBvZiBtYWtpbmcgdGhlIGNsYXNzIGRyaXZlcnMgbW9yZSBlZmZl
Y3RpdmUuICBCdXQgcGFkZGluZyBpcyBvbmx5DQo+IHJlbGV2YW50IGZvciB0aGUgRUNNIGNsYXNz
LCBpc24ndCBpdD8gQW5kIGFyZSB0aGVyZSBhbnkgRUNNIGNsYXNzDQo+IGRldmljZXMgd2hlcmUg
U0cgc3VwcG9ydCBtYXR0ZXJzPw0KDQpBRkFJQ1QgdGhlIHJlcXVpcmVtZW50IGZvciBhdm9pZGlu
ZyBaTFAgaXMgYSBwcm9wZXJ0eSBvZiB0aGUgc2xhdmUuDQpTdXBwb3J0IGZvciBzY2F0dGVyLWdh
dGhlciBpcyBhIHByb3BlcnR5IG9mIHRoZSBob3N0Lg0KDQpTbyBjb25uZWN0IGFuIG9sZCBzbGF2
ZSB0byBhIG1vZGVybiBob3N0IGFuZCB5b3UgbWF5IGJlIGFibGUgdG8gdXNlDQpzZyB0byBhZGQg
dGhlIGhlYWRlciBvciBwYWRkaW5nIChhbmQgcG9zc2libHkgaGF2ZSBhIGZyYWdtZW50ZWQgc2ti
KS4NCg0KR2VuZXJhdGluZyBmcmFtZXMgdGhhdCB3b3VsZCBoYXZlIGEgWkxQIHNob3VsZCBqdXN0
IGJlIGEgbWF0dGVyIG9mDQpzZW5kaW5nIFVEUCBmcmFtZXMgd2l0aCBldmVyIGluY3JlYXNpbmcg
bGVuZ3RocyAtIGFsdGhvdWdoIGENCnByaW50ZiBpbiB0aGUgZHJpdmVyIHdvdWxkIGNvbmZpcm0g
aXQuDQoNCkhvd2V2ZXIgdGhlIGlzIGEgcmVwb3J0IChzb21ld2hlcmUpIHRoYXQgaXQgd291bGQg
d29yayBzb21ldGltZXMNCmFuZCBub3Qgb3RoZXJzIHdpdGggY2VydGFpbiB0YXJnZXRzLg0KDQpJ
J3ZlIGdvdCBvbmUgb2YgdGhlIEFTSVggVVNCMyBkZXZpY2VzIGhlcmUsIGJ1dCB0aGUgc3lzdGVt
IGlzIHJ1bm5pbmcNCnVidW50dSAxMi4wNCAtIHdoaWNoIGRvZXNuJ3QgaGF2ZSB0aGUgc2cgY2hh
bmdlcy4gSSd2ZSBub3QgbG9va2VkIGZhcg0KZW5vdWdoIHRvIHNlZSBpZiB0aGUgc2cgY2hhbmdl
cyBpbiB1c2JuZXQuYyBjYW4gYmUgYXBwbGllZCB0byB0aGF0DQprZXJuZWwuDQoNCglEYXZpZA0K
DQo=
