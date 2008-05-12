From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Mon, 12 May 2008 17:35:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805121656440.1888@wrl-59.cs.helsinki.fi>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi>
 <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
 <4823437D.20005@damtek.com> <Pine.LNX.4.64.0805082336440.31776@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0805120859470.1041@wrl-59.cs.helsinki.fi> <4828279C.3010102@damtek.com>
 <Pine.LNX.4.64.0805121419330.1888@wrl-59.cs.helsinki.fi> <4828304F.4040908@damtek.com>
 <Pine.LNX.4.64.0805121503280.1888@wrl-59.cs.helsinki.fi> <482849C9.30905@damtek.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_courier-20818-1210602909-0001-2"
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: "Damon L. Chesser" <damon@damtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42511 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbYELOfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 10:35:11 -0400
In-Reply-To: <482849C9.30905@damtek.com>
Content-ID: <Pine.LNX.4.64.0805121656441.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_courier-20818-1210602909-0001-2
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-ID: <Pine.LNX.4.64.0805121656442.1888@wrl-59.cs.helsinki.fi>

On Mon, 12 May 2008, Damon L. Chesser wrote:

> I applied the patches in order, no errors on that.  I compiled a stock
> 2.4.24-1 kernel with the patches, I saw no errors there.
> 
> booted into new kernel, printed with tcp_frto=0.  set tcp_frto =2, restarted
> the network (is this required, or is this a dynamic setting?), printed from OO
> document.  No joy.  tcpdump log attached (almost 15 min. worth of data)
> 
> If you want, I can re-compile and double check for any compilation errors,
> however, if there were any, it was not sever enough to stop the compilation.

On the bright side, the FRTO problem that was occuring previously is now 
fixed but there seems to be very few ways to communicate with that device 
sanely because it assumes in-order arrival and keeps discarding, as it 
seems, _all_ other segments... If you could try with this additional 
work-around attached (keep the fixes there as well). Turn 
tcp_frto_inorder_workaround sysctl to 1 before testing with FRTO.

...Can you please send a dump about working case too, this seems rather 
nasty device to work with (tcp_frto = 0 is enough to attain it, no 
need to have another kernel booted for that) and I'm interested to see 
what are the loss rates without FRTO...


-- 
 i.
--=_courier-20818-1210602909-0001-2
Content-Type: text/plain; charset=iso-8859-1; name="0001-TCP-FRTO-workaround-in-order-only-receivers.patch"
Content-Transfer-Encoding: base64
Content-ID: <Pine.LNX.4.64.0805121735070.1888@wrl-59.cs.helsinki.fi>
Content-Description: 
Content-Disposition: attachment; filename=0001-TCP-FRTO-workaround-in-order-only-receivers.patch

RnJvbSAxZmJjZDkzZmU4MWEyMjc2ZTlkZjEyZmU1NzVmMzNkZjRkYmZiMzEy
IE1vbiBTZXAgMTcgMDA6MDA6MDAgMjAwMQ0KRnJvbTogPT9JU08tODg1OS0x
P3E/SWxwbz0yMEo9RTRydmluZW4/PSA8aWxwby5qYXJ2aW5lbkBoZWxzaW5r
aS5maT4NCkRhdGU6IE1vbiwgMTIgTWF5IDIwMDggMTc6MjQ6MDIgKzAzMDAN
ClN1YmplY3Q6IFtQQVRDSF0gW1RDUF0gRlJUTzogd29ya2Fyb3VuZCBpbi1v
cmRlciBvbmx5IHJlY2VpdmVycw0KTUlNRS1WZXJzaW9uOiAxLjANCkNvbnRl
bnQtVHlwZTogdGV4dC9wbGFpbjsgY2hhcnNldD1JU08tODg1OS0xDQpDb250
ZW50LVRyYW5zZmVyLUVuY29kaW5nOiA4Yml0DQoNCklmIHJlY2VpdmVyIGNv
bnN1bWVzIHNlZ21lbnRzIHN1Y2Nlc3NmdWxseSBvbmx5IGluLW9yZGVyLA0K
RlJUTyBmYWxsYmFjayB0byBjb252ZW50aW9uYWwgcmVjb3ZlcnkgcHJvZHVj
ZXMgUlRPIGxvb3AgYmVjYXVzZQ0KRlJUTydzIGZvcndhcmQgdHJhbnNtaXNz
aW9ucyB3aWxsIGFsd2F5cyBnZXQgZHJvcHBlZCBhbmQgbmVlZCB0bw0KYmUg
cmVzZW50LCB5ZXQgYnkgZGVmYXVsdCB0aGV5J3JlIG5vdCBtYXJrZWQgYXMg
bG9zdCAod2hpY2ggYXJlDQp0aGUgb25seSBzZWdtZW50cyB3ZSB3aWxsIHJl
dHJhbnNtaXQgaW4gQ0FfTG9zcykuDQoNClNpZ25lZC1vZmYtYnk6IElscG8g
SuRydmluZW4gPGlscG8uamFydmluZW5AaGVsc2lua2kuZmk+DQpSZXBvcnRl
ZC1ieTogRGFtb24gTC4gQ2hlc3NlciA8ZGFtb25AZGFtdGVrLmNvbT4NCi0t
LQ0KIGluY2x1ZGUvbmV0L3RjcC5oICAgICAgICAgIHwgICAgMSArDQogbmV0
L2lwdjQvc3lzY3RsX25ldF9pcHY0LmMgfCAgICA4ICsrKysrKysrDQogbmV0
L2lwdjQvdGNwX2lucHV0LmMgICAgICAgfCAgICA0ICsrKy0NCiAzIGZpbGVz
IGNoYW5nZWQsIDEyIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb25zKC0pDQoN
CmRpZmYgLS1naXQgYS9pbmNsdWRlL25ldC90Y3AuaCBiL2luY2x1ZGUvbmV0
L3RjcC5oDQppbmRleCBjYjViMDMzLi5lNmU0NGI4IDEwMDY0NA0KLS0tIGEv
aW5jbHVkZS9uZXQvdGNwLmgNCisrKyBiL2luY2x1ZGUvbmV0L3RjcC5oDQpA
QCAtMjIyLDYgKzIyMiw3IEBAIGV4dGVybiBpbnQgc3lzY3RsX3RjcF9hZHZf
d2luX3NjYWxlOw0KIGV4dGVybiBpbnQgc3lzY3RsX3RjcF90d19yZXVzZTsN
CiBleHRlcm4gaW50IHN5c2N0bF90Y3BfZnJ0bzsNCiBleHRlcm4gaW50IHN5
c2N0bF90Y3BfZnJ0b19yZXNwb25zZTsNCitleHRlcm4gaW50IHN5c2N0bF90
Y3BfZnJ0b19pbm9yZGVyX3dvcmthcm91bmQ7DQogZXh0ZXJuIGludCBzeXNj
dGxfdGNwX2xvd19sYXRlbmN5Ow0KIGV4dGVybiBpbnQgc3lzY3RsX3RjcF9k
bWFfY29weWJyZWFrOw0KIGV4dGVybiBpbnQgc3lzY3RsX3RjcF9ub21ldHJp
Y3Nfc2F2ZTsNCmRpZmYgLS1naXQgYS9uZXQvaXB2NC9zeXNjdGxfbmV0X2lw
djQuYyBiL25ldC9pcHY0L3N5c2N0bF9uZXRfaXB2NC5jDQppbmRleCBiZWM2
ZmU4Li45Y2JkY2NmIDEwMDY0NA0KLS0tIGEvbmV0L2lwdjQvc3lzY3RsX25l
dF9pcHY0LmMNCisrKyBiL25ldC9pcHY0L3N5c2N0bF9uZXRfaXB2NC5jDQpA
QCAtNzIzLDYgKzcyMywxNCBAQCBjdGxfdGFibGUgaXB2NF90YWJsZVtdID0g
ew0KIAkJLnByb2NfaGFuZGxlcgk9ICZwcm9jX2RvaW50dmVjDQogCX0sDQog
CXsNCisJCS5jdGxfbmFtZQk9IENUTF9VTk5VTUJFUkVELA0KKwkJLnByb2Nu
YW1lCT0gInRjcF9mcnRvX2lub3JkZXJfd29ya2Fyb3VuZCIsDQorCQkuZGF0
YQkJPSAmc3lzY3RsX3RjcF9mcnRvX2lub3JkZXJfd29ya2Fyb3VuZCwNCisJ
CS5tYXhsZW4JCT0gc2l6ZW9mKGludCksDQorCQkubW9kZQkJPSAwNjQ0LA0K
KwkJLnByb2NfaGFuZGxlcgk9ICZwcm9jX2RvaW50dmVjDQorCX0sCQ0KKwl7
DQogCQkuY3RsX25hbWUJPSBORVRfVENQX0xPV19MQVRFTkNZLA0KIAkJLnBy
b2NuYW1lCT0gInRjcF9sb3dfbGF0ZW5jeSIsDQogCQkuZGF0YQkJPSAmc3lz
Y3RsX3RjcF9sb3dfbGF0ZW5jeSwNCmRpZmYgLS1naXQgYS9uZXQvaXB2NC90
Y3BfaW5wdXQuYyBiL25ldC9pcHY0L3RjcF9pbnB1dC5jDQppbmRleCBiMzlm
MGQ4Li4wMjkyMDcwIDEwMDY0NA0KLS0tIGEvbmV0L2lwdjQvdGNwX2lucHV0
LmMNCisrKyBiL25ldC9pcHY0L3RjcF9pbnB1dC5jDQpAQCAtODcsNiArODcs
NyBAQCBpbnQgc3lzY3RsX3RjcF9yZmMxMzM3IF9fcmVhZF9tb3N0bHk7DQog
aW50IHN5c2N0bF90Y3BfbWF4X29ycGhhbnMgX19yZWFkX21vc3RseSA9IE5S
X0ZJTEU7DQogaW50IHN5c2N0bF90Y3BfZnJ0byBfX3JlYWRfbW9zdGx5ID0g
MjsNCiBpbnQgc3lzY3RsX3RjcF9mcnRvX3Jlc3BvbnNlIF9fcmVhZF9tb3N0
bHk7DQoraW50IHN5c2N0bF90Y3BfZnJ0b19pbm9yZGVyX3dvcmthcm91bmQg
X19yZWFkX21vc3RseTsNCiBpbnQgc3lzY3RsX3RjcF9ub21ldHJpY3Nfc2F2
ZSBfX3JlYWRfbW9zdGx5Ow0KIA0KIGludCBzeXNjdGxfdGNwX21vZGVyYXRl
X3JjdmJ1ZiBfX3JlYWRfbW9zdGx5ID0gMTsNCkBAIC0xNzI5LDcgKzE3MzAs
OCBAQCBzdGF0aWMgdm9pZCB0Y3BfZW50ZXJfZnJ0b19sb3NzKHN0cnVjdCBz
b2NrICpzaywgaW50IGFsbG93ZWRfc2VnbWVudHMsIGludCBmbGFnKQ0KIA0K
IAkJLyogRG9uJ3QgbG9zdCBtYXJrIHNrYnMgdGhhdCB3ZXJlIGZ3ZCB0cmFu
c21pdHRlZCBhZnRlciBSVE8gKi8NCiAJCWlmICghKFRDUF9TS0JfQ0Ioc2ti
KS0+c2Fja2VkJlRDUENCX1NBQ0tFRF9BQ0tFRCkgJiYNCi0JCSAgICAhYWZ0
ZXIoVENQX1NLQl9DQihza2IpLT5lbmRfc2VxLCB0cC0+ZnJ0b19oaWdobWFy
aykpIHsNCisJCSAgICAoc3lzY3RsX3RjcF9mcnRvX2lub3JkZXJfd29ya2Fy
b3VuZCB8fA0KKwkJICAgICAhYWZ0ZXIoVENQX1NLQl9DQihza2IpLT5lbmRf
c2VxLCB0cC0+ZnJ0b19oaWdobWFyaykpKSB7DQogCQkJVENQX1NLQl9DQihz
a2IpLT5zYWNrZWQgfD0gVENQQ0JfTE9TVDsNCiAJCQl0cC0+bG9zdF9vdXQg
Kz0gdGNwX3NrYl9wY291bnQoc2tiKTsNCiAJCX0NCi0tIA0KMS41LjIuMg0K
DQo=

--=_courier-20818-1210602909-0001-2--
