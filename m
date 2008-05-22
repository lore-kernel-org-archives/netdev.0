From: Stephane Chazelas <Stephane_Chazelas@yahoo.fr>
Subject: rtt metric only for incoming connections?
Date: Thu, 22 May 2008 11:36:10 +0100
Message-ID: <20080522103610.GB5354@sc.homeunix.net>
References: <20080521163815.GA5028@sc.homeunix.net> <20080521101053.27db3495@extreme> <20080521114354.31c6807c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sidious.london.02.net ([82.132.130.152]:34556 "EHLO
	mail.o2.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751908AbYEVKgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 06:36:16 -0400
Content-Disposition: inline
In-Reply-To: <20080521114354.31c6807c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2008 at 11:43:54AM -0700, Stephen Hemminger wrote:
[...]
> The problem is that these values are now hardcoded into people's syst=
ems
> so anyone using the 'ip route' options: rttvar, rtomin, or rtt are br=
oken.
> They might be lucky now (but I doubt it).
[...]

Hi Stephen, all

a slightly related question:

it seems that the "rtt" parameter provided in "ip route ... rtt
<value>" is not taken into account for the retransmission of
SYNs while it is for the retransmissions of SYN+ACKs, why would
that be (2.6.24.2)?

Also, it seems we can't lower the initial RTO below the RFC 1122
default of 3 seconds. 3 seconds may be appropriate for a host
for which we don't know how many hops, links, satellites are
needed to reach it, but what about local/corporate networks
where it's possible to administratively know the rtt so that it
can be hardcoded in the routing table.

=46or instance, on the office wireless network, I know the average
rtt is below the ms. Some SYNs may be lost, but they can't be
delayed more than a few hundred ms. So, I may want to specify in
the route to that network, the initial and maximum rto, so that
a down host can be detected in less than a second.

The delay before the first retransmission is 3 seconds at the
moment. That value is often more than what some applications are
ready to wait for (applications that are meant to be run locally
for instance). So, it's a shame, because the application will
timeout on the connect even before the first retransmission, so
the SYN retransmission mechanism is useless in that case.

Or is it because there's a risk of congesting the internet if
people misuse that? Note that applications can always reattempt
a connect to work around that (for SYNs to be sent more often).

It would be nice if what the "rtt" exactly is could be
clarified. For instance, if I understand correctly, by default,
the initial rtt is 0 and the rttvar 3s, which results in a rto
of 3s. That "rtt" is the smoothed rtt, right? (I think the
"route" man page from net-tools is incorrect about that, BTW.),
but then when setting those variables per route, it's the RTT
that can't be made lower than 3s, while rttvar can be as low as
rto_min (200ms by default). It's all very confusing (well, I'm
very confused ;).

regards,
St=E9phane
