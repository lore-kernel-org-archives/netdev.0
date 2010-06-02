From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 2 Jun 2010 10:27:13 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1006021025200.30182@router.home>
References: <alpine.DEB.2.00.1006011609280.9438@router.home> <1275430054.2638.115.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1266566856-1275492433=:30182"
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi157.sbcis.sbc.com ([207.115.36.171]:39366 "EHLO
	nlpi157.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757699Ab0FBP1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 11:27:18 -0400
In-Reply-To: <1275430054.2638.115.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1266566856-1275492433=:30182
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 2 Jun 2010, Eric Dumazet wrote:

> Le mardi 01 juin 2010 =C3=A0 16:13 -0500, Christoph Lameter a =C3=A9crit =
:
> > Something like this would have been very helpful during recent debuggin=
g
> > of multicast issues. Silent discards are bad.
> >
>
> >
> > If the kernel perceives that something is wrong with an incoming packet=
 then the
> > IP stack currently silently discards packets. This makes it difficult t=
o diagnose
> > problems with the network configurations (such as a misbehaving kernel
> > subsystem discarding multicast packets because the reverse path filter
> > does not like multicast subscriptions on the second NIC with rp_filter=
=3D1).
> >
> > It is also necessary to know how many inbound packets are discarded to
> > assess networking issues in general with a NIC.
> >
> > Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> > Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> >
>
> I disagree with this patch.
>
> IPSTATS_MIB_INADDRERRORS has a strong meaning, part of RFCS.
>
> In this path, we simulate the routing of a virtual packet, not its
> delivery.
>
> This should not affect IPSTATS SNMP entries.
>
> You should use another MIB entry, say LINUX_MIB_INROUTEERRORS ?
>
> Dont inet_rtm_getroute() caller gets an error status anyway ?

Yes but they are not increment any counter. If packets are dropped because
of the rp_filter setting interfering f.e. then the packets vanish without
any accounting.

LINUX_MIB_INROUTEERRORS? Does it mean I can create a series of new
counters that allow us to diagnose and distinguish all the different
causes of packet loss? We would love to have that.


---1463811839-1266566856-1275492433=:30182--
