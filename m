From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Sat, 21 Nov 2009 07:58:33 +0100
Message-ID: <4B078F99.70100@gmail.com>
References: <4B05D8DC.7020907@gmail.com> <87aayg539l.fsf@basil.nowhere.org>	 <4B07188C.2070808@gmail.com> <20091120223723.GA4460@basil.fritz.box> <65634d660911201642k3930dc78vd576e0e89dc0c794@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51734 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbZKUG6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 01:58:36 -0500
In-Reply-To: <65634d660911201642k3930dc78vd576e0e89dc0c794@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert a =E9crit :
>=20
> It probably is a special case, but addresses a real problem.  Like rp=
s,
> this addresses the case where a single queue NIC is the bottleneck on=
 a
> system.  Anything that takes work off the interrupting core and sprea=
ds
> it to other cores may alleviate the bottleneck.=20
>=20


Yes, and this brings back an idea I mentioned earlier in April, for a m=
ulticast
problem we had with AthenaCR.

XPS could be 'started' only if caller runs from ksoftirqd, eg we are in=
 a stress
situation, and additional cost of XPS is nothing compared to huge gains=
 we have
to spread part of work to more CPUS.

(Costs of XPS includes : ~500 bytes of ICACHE, and IPI)


