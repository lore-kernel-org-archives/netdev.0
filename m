From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] udp: increment UDP_MIB_NOPORTS in mcast receive
Date: Wed, 3 Oct 2012 10:09:51 -0400
Message-ID: <OF8CC7A8E7.DA3B059E-ON85257A8C.004C258C-85257A8C.004DCE49@us.ibm.com>
References: <506955F3.8050304@googlemail.com>	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>	 <20121001.160115.1816241312626722150.davem@davemloft.net>
	 <1349121884.12401.721.camel@edumazet-glaptop>	 <1349192133.12401.768.camel@edumazet-glaptop>
	 <1349192919.12401.778.camel@edumazet-glaptop>	 <alpine.LFD.2.00.1210030032430.25856@ja.ssi.bg>
	 <1349249328.12401.1364.camel@edumazet-glaptop>	 <OFA39D9FC0.CDC6EE41-ON85257A8C.00458030-85257A8C.00461EF4@us.ibm.com> <1349270151.12401.2372.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: chris2553@googlemail.com, Dave Jones <davej@redhat.com>,
	David Miller <davem@davemloft.net>, gpiez@web.de,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:59605 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068Ab2JCOZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 10:25:37 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 3 Oct 2012 10:25:33 -0400
In-Reply-To: <1349270151.12401.2372.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 10/03/2012 09:15:51 AM:
 
> So when a host receives an UDP datagram but there was no application
> at the destination port we should increment udpNoPorts, and its not
> an error but just a fact.

        Of course. I think our difference is on the definition of 
"receives".
I don't think a packet delivered locally due to promiscuous mode, 
broadcast
or an imperfect multicast address filter match is a host UDP datagram 
receive.
These packets really shouldn't be delivered to UDP at all; they are not
addressed to this host (at least the non-broadcast, no-membership ones).
        A unicast UDP packet that doesn't match a local IP address does 
not
increment this counter. A promiscuous mode multicast delivery is no 
different,
except that the destination alone doesn't tell us if it is for us.

        I think counting these will primarily lead to administrators 
seeing
non-zero drops and wasting their time trying to track them down.

                                                                +-DLS
