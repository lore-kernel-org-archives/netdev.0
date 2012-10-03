From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: increment UDP_MIB_NOPORTS in mcast receive
Date: Wed, 03 Oct 2012 15:15:51 +0200
Message-ID: <1349270151.12401.2372.camel@edumazet-glaptop>
References: <506955F3.8050304@googlemail.com>
	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>
	 <20121001.160115.1816241312626722150.davem@davemloft.net>
	 <1349121884.12401.721.camel@edumazet-glaptop>
	 <1349192133.12401.768.camel@edumazet-glaptop>
	 <1349192919.12401.778.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1210030032430.25856@ja.ssi.bg>
	 <1349249328.12401.1364.camel@edumazet-glaptop>
	 <OFA39D9FC0.CDC6EE41-ON85257A8C.00458030-85257A8C.00461EF4@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chris2553@googlemail.com, Dave Jones <davej@redhat.com>,
	David Miller <davem@davemloft.net>, gpiez@web.de,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36563 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755027Ab2JCNP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 09:15:57 -0400
In-Reply-To: <OFA39D9FC0.CDC6EE41-ON85257A8C.00458030-85257A8C.00461EF4@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-03 at 08:45 -0400, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 10/03/2012 03:28:48 AM:
>  
> > BTW, it seems we dont properly increase UDP MIB counters when a
> > multicast message is not delivered to at least one socket.
> 
> If an interface is in promiscuous mode or there are false
> positives in a multicast address filter, wouldn't this count as
> "drops" packets that were never intended for this machine?
> 

Yes, probably. So we drop them and its expected.

> I think an otherwise valid multicast or broadcast packet that doesn't
> have a local receiver is not an error and shouldn't be counted.

Hmmm

This counter is not an "error counter", just a "counter".

RFC definitions are exactly :

udpNoPorts OBJECT-TYPE
       SYNTAX     Counter32
       MAX-ACCESS read-only
       STATUS     current
       DESCRIPTION
              "The total number of received UDP datagrams for which
               there was no application at the destination port.

udpInErrors OBJECT-TYPE
       SYNTAX     Counter32
       MAX-ACCESS read-only
       STATUS     current
       DESCRIPTION
              "The number of received UDP datagrams that could not be
               delivered for reasons other than the lack of an
               application at the destination port.


So when a host receives an UDP datagram but there was no application
at the destination port we should increment udpNoPorts, and its not
an error but just a fact.

Now _if_ some reader interprets udpNoPorts increases as an indication
of errors, this reader is wrong.
