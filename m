From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in
 2.6.36.3
Date: Thu, 13 Jan 2011 10:05:56 +0100
Message-ID: <1294909556.3570.25.camel@edumazet-laptop>
References: <895344.13845.qm@web121707.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: JesseBrandeburg <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Tushar NDave <tushar.n.dave@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeffrey TKirsher <jeffrey.t.kirsher@intel.com>
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:49091 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932429Ab1AMJGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 04:06:02 -0500
Received: by wwi17 with SMTP id 17so4841566wwi.1
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 01:06:00 -0800 (PST)
In-Reply-To: <895344.13845.qm@web121707.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 janvier 2011 =C3=A0 01:00 -0800, Chris Rankin a =C3=A9crit =
:
> --- On Thu, 13/1/11, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Problem is e100 allocates an order-6 page in DMA zone
> > (a 256 KB contigous area of ram)
> >=20
> > This contigous area of ram is not available but just after
> > booting...
>=20
> I suspected as much. Fortunately, this machine has no function apart =
from routing and can happily left untouched for extended periods of tim=
e.
>=20
> > On such small router, I doubt you need more than 64 slots
> > in TX ring buffer.
>=20
> But what would the effect of that change be to the interfaces' perfor=
mance, please?

If you care of performance, dont unload/reload your driver all the time=
,
and dont use modules (this matter on old hardware because of TLB misses=
)

Anyway, the change ( 128 -> 64 ) is not needed, since the kernel messag=
e
is a warning only. The allocation is retried and apparently succeeds.

The __GFP_NOWARN should make the failed allocation not noticed at all.



