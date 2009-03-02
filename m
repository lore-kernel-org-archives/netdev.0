From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Marvell 88E609x switch?
Date: Mon, 02 Mar 2009 11:56:22 +0100
Message-ID: <1235991382.30736.62.camel@localhost.localdomain>
References: <20090227145746.GD17040@xi.wantstofly.org>
	 <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org>
	 <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org>
	 <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org>
	 <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org>
	 <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>
	 <20090227222802.GZ17040@xi.wantstofly.org>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-2t6WHPowBEoBBimBKSei"
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Gary Thomas <gary@mlbassoc.com>,
	netdev <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:40726 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756003AbZCBK4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 05:56:25 -0500
In-Reply-To: <20090227222802.GZ17040@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2t6WHPowBEoBBimBKSei
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2009-02-27 at 23:28 +0100, Lennert Buytenhek wrote:

> The main conclusion so far is that this write (net/dsa/mv88e6131.c):
> 
> 	/*
> 	 * MAC Forcing register: don't force link, speed, duplex
> 	 * or flow control state to any particular values.
> 	 */
>	REG_WRITE(addr, 0x01, 0x0003);

This sort of enables auto-detection of speed.

> isn't correct on ports that can either be CPU ports or external ports.

For external ports I had to enabled the PPU to allow the external PHYs
to negotiate.

Also, on external PHYs ports 8 and 9, I write 0x0403 not 0x0003 (to
register 0x1, PCS Control Register).  Which also enables inband
auto-negotiation, but I'm not sure this is necessary.


> Forcing the link up on the CPU port helps somewhat, but things aren't
> 100% working yet.

On the CPU port I force link-up and force speed+duplex setting.  I only
got 100Mbit/s to the CPU port...

/* CPU Port 10: Force 100Mbit Full-Duplex */
REG_WRITE( 0x1A , 0x01 , 0x003D );

You should write 0x003E ... see attached patch

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

--=-2t6WHPowBEoBBimBKSei
Content-Disposition: attachment; filename=test01
Content-Type: text/plain; name=test01; charset=us-ascii
Content-Transfer-Encoding: base64

T24gQ1BVIHBvcnQsIEZvcmNlIDEwMDBNYml0L3MgRnVsbC1kdXBsZXggYW5kIGxpbmstdXAuDQoN
Cg0KLS0tDQoNCiBuZXQvZHNhL212ODhlNjEzMS5jIHwgICAgOCArKysrKystLQ0KIDEgZmlsZXMg
Y2hhbmdlZCwgNiBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQ0KDQoNCmRpZmYgLS1naXQg
YS9uZXQvZHNhL212ODhlNjEzMS5jIGIvbmV0L2RzYS9tdjg4ZTYxMzEuYw0KaW5kZXggMzc0ZDQ2
YS4uNDAwNDczYSAxMDA2NDQNCi0tLSBhL25ldC9kc2EvbXY4OGU2MTMxLmMNCisrKyBiL25ldC9k
c2EvbXY4OGU2MTMxLmMNCkBAIC0xNTksOSArMTU5LDEzIEBAIHN0YXRpYyBpbnQgbXY4OGU2MTMx
X3NldHVwX3BvcnQoc3RydWN0IGRzYV9zd2l0Y2ggKmRzLCBpbnQgcCkNCiANCiAJLyoNCiAJICog
TUFDIEZvcmNpbmcgcmVnaXN0ZXI6IGRvbid0IGZvcmNlIGxpbmssIHNwZWVkLCBkdXBsZXgNCi0J
ICogb3IgZmxvdyBjb250cm9sIHN0YXRlIHRvIGFueSBwYXJ0aWN1bGFyIHZhbHVlcy4NCisJICog
b3IgZmxvdyBjb250cm9sIHN0YXRlIHRvIGFueSBwYXJ0aWN1bGFyIHZhbHVlcy4gIFVubGVzcw0K
KwkgKiB0aGlzIGlzIHRoZSBDUFUgcG9ydCwgdGhlbiBmb3JjZSAxR2IvcyBhbmQgbGluay11cC4N
CiAJICovDQotCVJFR19XUklURShhZGRyLCAweDAxLCAweDAwMDMpOw0KKwlpZiAoKHAgPT0gZHMt
PmNwdV9wb3J0KSkNCisJCVJFR19XUklURShhZGRyLCAweDAxLCAweDAwM0UpOw0KKwllbHNlDQor
CQlSRUdfV1JJVEUoYWRkciwgMHgwMSwgMHgwMDAzKTsNCiANCiAJLyoNCiAJICogUG9ydCBDb250
cm9sOiBkaXNhYmxlIENvcmUgVGFnLCBkaXNhYmxlIERyb3Atb24tTG9jaywNCg==


--=-2t6WHPowBEoBBimBKSei--
