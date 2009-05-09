From: Bill Fink <billfink@mindspring.com>
Subject: Re: ports beeing reused too fast
Date: Sat, 9 May 2009 15:31:35 -0400
Message-ID: <20090509153135.04874f72.billfink@mindspring.com>
References: <200905082311.09414.opurdila@ixiacom.com>
	<4A052991.5040009@cosmosbay.com>
	<200905091611.20321.opurdila@ixiacom.com>
	<4A059E75.7060008@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:59497 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752970AbZEITbg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 May 2009 15:31:36 -0400
In-Reply-To: <4A059E75.7060008@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 09 May 2009, Eric Dumazet wrote:

> Octavian Purdila a =E9crit :
> > On Saturday 09 May 2009 09:58:25 Eric Dumazet wrote:
> >=20
> >>> I've looked over the  code and it looks right, so maybe net_rando=
m() is
> >>> not random enough? Or maybe there are side effects because of the=
 %
> >>> port_range?
> >> Random is random :)
> >> Probability a port can be reused pretty fast is not nul.
> >>
> >=20
> > Thinking again about it... you are right :)
> >=20
> >> So yes, behavior you discovered is expected, when we switched port
> >> selection from a sequential one (not very secure btw) to a random =
one.
> >>
> >> Any strong reason why a firewall would drop a SYN because ports we=
re used
> >> in a previous session ?
> >=20
> > We don't know why the firewall (Cisco FWSM) is dropping the packets=
, may be a=20
> > bug, limitation or miss-configuration. We are trying to track this =
down with=20
> > the firewall vendor.
>=20
> Normally, the client machine should not reuse a port during the TIME_=
WAIT duration
> (TCP_TIMEWAIT_LEN being 60 seconds on linux). Port selection being ra=
ndom or sequential,
> it should avoid all ports recently used.
>=20
> Maybe this firewall has a longer TIME_WAIT enforcement (something lik=
e 2 minutes)

But he had 19 ports being reused after only 1000 connect()s, which
with his stated ~360 (I'm assuming per second) connection rate,
would only take about 3 seconds.

						-Bill
