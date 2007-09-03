From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: [PATCH 2/2]: [NET_SCHED]: Making rate table lookups more
	flexible.
Date: Mon, 03 Sep 2007 16:19:11 +0200
Message-ID: <1188829151.16405.10.camel@localhost.localdomain>
References: <1188562978.18622.13.camel@localhost.localdomain>
	 <46D91082.7050609@trash.net>
	 <Pine.LNX.4.61.0709012338320.29796@ask.diku.dk>
	 <46DACA48.2060602@trash.net>
	 <Pine.LNX.4.61.0709022006380.20071@ask.diku.dk>
	 <46DB2846.2030400@trash.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-BtBPfk0QN7tBpsDS2AoL"
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:53504 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbXICOTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 10:19:00 -0400
In-Reply-To: <46DB2846.2030400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-BtBPfk0QN7tBpsDS2AoL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Sun, 2007-09-02 at 23:16 +0200, Patrick McHardy wrote:
> Jesper Dangaard Brouer wrote:
> > On Sun, 2 Sep 2007, Patrick McHardy wrote:
> >>
> >
> > Lets focus on the general case, where the functionality actually is 
> > needed right away.
> >
> > In the general case:
> >
> > - The rate table needs to be aligned (cell_align=-1).
> >   (currently, we miscalculates up to 7 bytes on every lookup)
> 
> We will always do that, thats a consequence of storing the
> transmission times for multiples of 8b.

The issue is that we use the lower boundary for calculating the transmit
cost. Thus, a 15 bytes packet only have a transmit cost of 8 bytes.

> > - The existing tc overhead calc can be made more accurate.
> >   (by adding overhead before doing the lookup, instead of the
> >    current solution where the rate table is modified with its
> >    limited resolution)
> 
> Please demonstrate this with patches (one for the overhead
> calculation, one for the cell_align thing), then we can
> continue this discussion.

I have attached a patch for the overhead calculation.

I'll look into the "the cell_align thing" tomorrow.

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk

--=-BtBPfk0QN7tBpsDS2AoL
Content-Disposition: attachment; filename=pkt_sched.h.patch
Content-Type: text/x-patch; name=pkt_sched.h.patch; charset=us-ascii
Content-Transfer-Encoding: base64

Y29tbWl0IGEyOWQ0M2I3OGQ1ZGRiMjBhODA4ZDkyNzBjMmRlMzU4NTU2YmE1ZWUNCkF1dGhvcjog
SmVzcGVyIERhbmdhYXJkIEJyb3VlciA8aGF3a0Bjb214LmRrPg0KRGF0ZTogICBNb24gU2VwIDMg
MTQ6MzU6MTkgMjAwNyArMDIwMA0KDQogICAgW0lQUk9VVEUyXTogVXBkYXRlIHBrdF9zY2hlZC5o
DQogICAgDQogICAgSW4gc3RydWN0IHRjX3JhdGVzcGVjLCByZXBsYWNlICdhZGRlbmQnLCB3aXRo
ICdjZWxsX2FsaWduJyBhbmQgJ292ZXJoZWFkJy4NCiAgICANCiAgICBTaWduZWQtb2ZmLWJ5OiBK
ZXNwZXIgRGFuZ2FhcmQgQnJvdWVyIDxoYXdrQGNvbXguZGs+DQoNCmRpZmYgLS1naXQgYS9pbmNs
dWRlL2xpbnV4L3BrdF9zY2hlZC5oIGIvaW5jbHVkZS9saW51eC9wa3Rfc2NoZWQuaA0KaW5kZXgg
MjY4YzUxNS4uYTEyN2Q2MyAxMDA2NDQNCi0tLSBhL2luY2x1ZGUvbGludXgvcGt0X3NjaGVkLmgN
CisrKyBiL2luY2x1ZGUvbGludXgvcGt0X3NjaGVkLmgNCkBAIC03OCw3ICs3OCw4IEBAIHN0cnVj
dCB0Y19yYXRlc3BlYw0KIAl1bnNpZ25lZCBjaGFyCWNlbGxfbG9nOw0KIAl1bnNpZ25lZCBjaGFy
CV9fcmVzZXJ2ZWQ7DQogCXVuc2lnbmVkIHNob3J0CWZlYXR1cmU7DQotCXNob3J0CQlhZGRlbmQ7
DQorCWNoYXIJCWNlbGxfYWxpZ247DQorCXVuc2lnbmVkIGNoYXIJb3ZlcmhlYWQ7DQogCXVuc2ln
bmVkIHNob3J0CW1wdTsNCiAJX191MzIJCXJhdGU7DQogfTsNCg==


--=-BtBPfk0QN7tBpsDS2AoL
Content-Disposition: attachment; filename=overhead_to_kernel.patch
Content-Type: text/x-patch; name=overhead_to_kernel.patch; charset=us-ascii
Content-Transfer-Encoding: base64

Y29tbWl0IDFlODk0NDI0NjhkY2E5ODNlMGUzZDI0Yjg5MDkzMzcwODk2ZjJkNmENCkF1dGhvcjog
SmVzcGVyIERhbmdhYXJkIEJyb3VlciA8aGF3a0Bjb214LmRrPg0KRGF0ZTogICBNb24gU2VwIDMg
MTU6NDk6NDEgMjAwNyArMDIwMA0KDQogICAgW0lQUk9VVEUyXTogT3ZlcmhlYWQgY2FsY3VsYXRp
b24gaXMgbm93IGRvbmUgaW4gdGhlIGtlcm5lbC4NCiAgICANCiAgICBUaGUgb25seSBjdXJyZW50
IHVzZXIgaXMgSFRCLiBIVEIgb3ZlcmhlYWQgYXJndW1lbnQgaXMgbm93DQogICAgcGFzc2VkIG9u
IHRoZSBrZXJuZWwgKGluIHRoZSBzdHJ1Y3QgdGNfcmF0ZXNwZWMpLg0KICAgIA0KICAgIFNpZ25l
ZC1vZmYtYnk6IEplc3BlciBEYW5nYWFyZCBCcm91ZXIgPGhhd2tAY29teC5kaz4NCg0KZGlmZiAt
LWdpdCBhL3RjL3FfaHRiLmMgYi90Yy9xX2h0Yi5jDQppbmRleCA1M2UzZjc4Li5iNTc5ZWJlIDEw
MDY0NA0KLS0tIGEvdGMvcV9odGIuYw0KKysrIGIvdGMvcV9odGIuYw0KQEAgLTIwNiw5ICsyMDYs
MTEgQEAgc3RhdGljIGludCBodGJfcGFyc2VfY2xhc3Nfb3B0KHN0cnVjdCBxZGlzY191dGlsICpx
dSwgaW50IGFyZ2MsIGNoYXIgKiphcmd2LCBzdHINCiAJaWYgKCFidWZmZXIpIGJ1ZmZlciA9IG9w
dC5yYXRlLnJhdGUgLyBnZXRfaHooKSArIG10dTsNCiAJaWYgKCFjYnVmZmVyKSBjYnVmZmVyID0g
b3B0LmNlaWwucmF0ZSAvIGdldF9oeigpICsgbXR1Ow0KIA0KLS8qIGVuY29kZSBvdmVyaGVhZCBh
bmQgbXB1LCA4IGJpdHMgZWFjaCwgaW50byBsb3dlciAxNiBiaXRzICovDQotCW1wdSA9ICh1bnNp
Z25lZCltcHU4IHwgKHVuc2lnbmVkKW92ZXJoZWFkIDw8IDg7DQotCW9wdC5jZWlsLm1wdSA9IG1w
dTsgb3B0LnJhdGUubXB1ID0gbXB1Ow0KKwlvcHQuY2VpbC5vdmVyaGVhZCA9IG92ZXJoZWFkOw0K
KwlvcHQucmF0ZS5vdmVyaGVhZCA9IG92ZXJoZWFkOw0KKw0KKwlvcHQuY2VpbC5tcHUgPSBtcHU7
DQorCW9wdC5yYXRlLm1wdSA9IG1wdTsNCiANCiAJaWYgKChjZWxsX2xvZyA9IHRjX2NhbGNfcnRh
YmxlKG9wdC5yYXRlLnJhdGUsIHJ0YWIsIGNlbGxfbG9nLCBtdHUsIG1wdSkpIDwgMCkgew0KIAkJ
ZnByaW50ZihzdGRlcnIsICJodGI6IGZhaWxlZCB0byBjYWxjdWxhdGUgcmF0ZSB0YWJsZS5cbiIp
Ow0KZGlmZiAtLWdpdCBhL3RjL3RjX2NvcmUuYyBiL3RjL3RjX2NvcmUuYw0KaW5kZXggNTgxNTVm
Yi4uMWFiMGJhMCAxMDA2NDQNCi0tLSBhL3RjL3RjX2NvcmUuYw0KKysrIGIvdGMvdGNfY29yZS5j
DQpAQCAtNzMsOCArNzMsNiBAQCBpbnQgdGNfY2FsY19ydGFibGUodW5zaWduZWQgYnBzLCBfX3Uz
MiAqcnRhYiwgaW50IGNlbGxfbG9nLCB1bnNpZ25lZCBtdHUsDQogCQkgICB1bnNpZ25lZCBtcHUp
DQogew0KIAlpbnQgaTsNCi0JdW5zaWduZWQgb3ZlcmhlYWQgPSAobXB1ID4+IDgpICYgMHhGRjsN
Ci0JbXB1ID0gbXB1ICYgMHhGRjsNCiANCiAJaWYgKG10dSA9PSAwKQ0KIAkJbXR1ID0gMjA0NzsN
CkBAIC04Niw4ICs4NCw2IEBAIGludCB0Y19jYWxjX3J0YWJsZSh1bnNpZ25lZCBicHMsIF9fdTMy
ICpydGFiLCBpbnQgY2VsbF9sb2csIHVuc2lnbmVkIG10dSwNCiAJfQ0KIAlmb3IgKGk9MDsgaTwy
NTY7IGkrKykgew0KIAkJdW5zaWduZWQgc3ogPSAoaTw8Y2VsbF9sb2cpOw0KLQkJaWYgKG92ZXJo
ZWFkKQ0KLQkJCXN6ICs9IG92ZXJoZWFkOw0KIAkJaWYgKHN6IDwgbXB1KQ0KIAkJCXN6ID0gbXB1
Ow0KIAkJcnRhYltpXSA9IHRjX2NhbGNfeG1pdHRpbWUoYnBzLCBzeik7DQo=


--=-BtBPfk0QN7tBpsDS2AoL--
