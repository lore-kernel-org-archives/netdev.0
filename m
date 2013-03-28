From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: Re: /128 link-local subnet on 6in4 (sit) tunnels?
Date: Thu, 28 Mar 2013 14:00:38 +0100
Message-ID: <1364475638.5000.19.camel@localhost>
References: <1364335457.8215.21.camel@localhost>
	 <20130327151210.GA23223@order.stressinduktion.org>
	 <1364398673.21709.4.camel@localhost>
	 <20130327181146.GB23223@order.stressinduktion.org>
	 <1364408454.15362.1.camel@localhost>
	 <20130327183558.GC23223@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 37-251-2-65.FTTH.ispfabriek.nl ([37.251.2.65]:59164 "EHLO
	mail.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755389Ab3C1NAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 09:00:42 -0400
In-Reply-To: <20130327183558.GC23223@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-27 at 19:35 +0100, Hannes Frederic Sowa wrote:
> On Wed, Mar 27, 2013 at 07:20:54PM +0100, Wilco Baan Hofman wrote:
> > http://tools.ietf.org/html/rfc4213
> 
> Thanks, I have seen that already. The sit driver is used for more than 6in4
> (6to4, isatap, 6rd). So such a change has to be ok with all the other
> protocols implemented by sit. I also looked in the historic git archive for a
> rationale of this but couldn't find one. Commit messages 2002 where not as
> descriptive as today("Import changeset"). :)
> 
> I also added YOSHIFUJI Hideaki as Cc, perhaps he knows the reason.
> 


I've been doing some RFC checking of my own..

As far as 6to4 and 6rd go, a link-local address is optional and not very
useful at all. ISATAP should have a /64 subnet configured as far as I
can tell, same for 6in4.

>From rfc3056 section 3.1 [1]:

   The link-local address of a 6to4 pseudo-interface performing 6to4
   encapsulation would, if needed, be formed as described in Section 3.7
   of [MECH].  However, no scenario is known in which such an address
   would be useful, since a peer 6to4 gateway cannot determine the
   appropriate link-layer (IPv4) address to send to.


For 6rd, rfc5969 section 9 specifies that a link *may*, if needed, have
a non-used link-local address [2], this may be where the /128 comes in:

   The 6rd link is modeled as an NBMA link similar to other automatic
   IPv6 in IPv4 tunneling mechanisms like [RFC5214], with all 6rd CEs
   and BRs defined as off-link neighbors from one other.  The link-local
   address of a 6rd virtual interface performing the 6rd encapsulation
   would, if needed, be formed as described in Section 3.7 of [RFC4213].
   However, no communication using link-local addresses will occur.


For ISATAP, it basically states that a link-local should have a "subnet
of appropriate length".
rfc5214 section 6.2 refers to rfc4862 [2] for link local addressing:

   ISATAP interfaces form ISATAP interface identifiers from IPv4
   addresses in their locator set and use them to create link-local
   ISATAP addresses (Section 5.3 of [RFC4862]).

Which states:

   A link-local address is formed by combining the well-known link-local
   prefix FE80::0 [RFC4291] (of appropriate length) with an interface
   identifier as follows: >snip<


[1] http://tools.ietf.org/html/rfc3056#section-3.1
[2] http://tools.ietf.org/html/rfc5969#section-9
[3] http://tools.ietf.org/html/rfc5214#section-6.2
[4] http://tools.ietf.org/html/rfc4862#section-5.3
