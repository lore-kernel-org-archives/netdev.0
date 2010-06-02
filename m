From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 2 Jun 2010 11:12:14 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1006021103410.30182@router.home>
References: <alpine.DEB.2.00.1006011609280.9438@router.home>  <1275430054.2638.115.camel@edumazet-laptop>  <alpine.DEB.2.00.1006021025200.30182@router.home> <1275492754.2725.192.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-135208990-1275495135=:30182"
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi129.sbcis.sbc.com ([207.115.36.143]:59170 "EHLO
	nlpi129.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932706Ab0FBQMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:12:21 -0400
In-Reply-To: <1275492754.2725.192.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-135208990-1275495135=:30182
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 2 Jun 2010, Eric Dumazet wrote:

> Le mercredi 02 juin 2010 =C3=A0 10:27 -0500, Christoph Lameter a =C3=A9cr=
it :
>
> > Yes but they are not increment any counter. If packets are dropped beca=
use
> > of the rp_filter setting interfering f.e. then the packets vanish witho=
ut
> > any accounting.
> >
>
> But packets are vanishing either way.

Its important to know why drops occur (any drops for that matter, drops
mean retransmit which means latency). The symptom here was that
multicast traffic on secondary interfaces was not being forwarded to the ap=
plication.
The rp_filter just dropped them and there was no way to easily track down
the issue for the people experiencing the problem.

In 2.6.31 the rp_filter was fixed to work properly with multicast and now
it considers multicast traffic to secondary interfaces to have the wrong
reverse path even though the multicast subscription occurred on the
secondary interface. So it drops multicast traffic. The rp_filter has to
be switched off when using multiple NICs for multicast load balancing.

> > LINUX_MIB_INROUTEERRORS? Does it mean I can create a series of new
> > counters that allow us to diagnose and distinguish all the different
> > causes of packet loss? We would love to have that.
> >
>
> For an example, you could take a look at commit 907cdda5205b
> (tcp: Add SNMP counter for DEFER_ACCEPT)

Well these are all TCP counters. I would add IP and UDP counters?
---1463811839-135208990-1275495135=:30182--
