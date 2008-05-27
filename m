From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: rtt metric only for incoming connections?
Date: Tue, 27 May 2008 11:43:11 -0700
Message-ID: <20080527114311.2734402b@speedy>
References: <20080521163815.GA5028@sc.homeunix.net>
	<20080521101053.27db3495@extreme>
	<20080521114354.31c6807c@extreme>
	<20080522103610.GB5354@sc.homeunix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephane Chazelas <Stephane_Chazelas@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48544 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755384AbYE0SnM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 14:43:12 -0400
In-Reply-To: <20080522103610.GB5354@sc.homeunix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 May 2008 11:36:10 +0100
Stephane Chazelas <Stephane_Chazelas@yahoo.fr> wrote:

> On Wed, May 21, 2008 at 11:43:54AM -0700, Stephen Hemminger wrote:
> [...]
> > The problem is that these values are now hardcoded into people's sy=
stems
> > so anyone using the 'ip route' options: rttvar, rtomin, or rtt are =
broken.
> > They might be lucky now (but I doubt it).
> [...]
>=20
> Hi Stephen, all
>=20
> a slightly related question:
>=20
> it seems that the "rtt" parameter provided in "ip route ... rtt
> <value>" is not taken into account for the retransmission of
> SYNs while it is for the retransmissions of SYN+ACKs, why would
> that be (2.6.24.2)?
>=20
> Also, it seems we can't lower the initial RTO below the RFC 1122
> default of 3 seconds. 3 seconds may be appropriate for a host
> for which we don't know how many hops, links, satellites are
> needed to reach it, but what about local/corporate networks
> where it's possible to administratively know the rtt so that it
> can be hardcoded in the routing table.

Violating RFC's is not really that useful. If you have a network
dropping SYN packets regularly than there are worse problems.

> For instance, on the office wireless network, I know the average
> rtt is below the ms. Some SYNs may be lost, but they can't be
> delayed more than a few hundred ms. So, I may want to specify in
> the route to that network, the initial and maximum rto, so that
> a down host can be detected in less than a second.
>=20
> The delay before the first retransmission is 3 seconds at the
> moment. That value is often more than what some applications are
> ready to wait for (applications that are meant to be run locally
> for instance). So, it's a shame, because the application will
> timeout on the connect even before the first retransmission, so
> the SYN retransmission mechanism is useless in that case.

Relying on TCP to overcome wireless network problems is not
a good idea.=20

> Or is it because there's a risk of congesting the internet if
> people misuse that? Note that applications can always reattempt
> a connect to work around that (for SYNs to be sent more often).

The problem is that distributions can't even get the settings right now=
=2E
It would be too easy for some distribution to ship with a default small
value.

> It would be nice if what the "rtt" exactly is could be
> clarified. For instance, if I understand correctly, by default,
> the initial rtt is 0 and the rttvar 3s, which results in a rto
> of 3s. That "rtt" is the smoothed rtt, right? (I think the
> "route" man page from net-tools is incorrect about that, BTW.),
> but then when setting those variables per route, it's the RTT
> that can't be made lower than 3s, while rttvar can be as low as
> rto_min (200ms by default). It's all very confusing (well, I'm
> very confused ;).
>=20
> regards,
> St=C3=A9phane

RTT is used as a starting point for the smoothed round trip time.
As soon as the first ack comes back the value starts to change.
