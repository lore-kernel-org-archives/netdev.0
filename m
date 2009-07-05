From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict
 verification
Date: Sun, 5 Jul 2009 15:46:44 +0930
Message-ID: <20090705154644.38e41050.lk-netdev@lk-netdev.nosense.org>
References: <200907030246.18054.denys@visp.net.lb>
	<200907041803.25436.denys@visp.net.lb>
	<m13a9c6rhv.fsf@fess.ebiederm.org>
	<200907050100.08148.denys@visp.net.lb>
	<20090705085203.332f0c3b.lk-netdev@lk-netdev.nosense.org>
	<m13a9c2dsg.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:51140 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbZGEGQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 02:16:48 -0400
In-Reply-To: <m13a9c2dsg.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 04 Jul 2009 17:07:11 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Mark Smith <lk-netdev@lk-netdev.nosense.org> writes:
> 
> > On Sun, 5 Jul 2009 01:00:08 +0300
> > Denys Fedoryschenko <denys@visp.net.lb> wrote:
> >
> >> On Sunday 05 July 2009 00:57:32 Eric W. Biederman wrote:
> >> >
> >> > How can that possibly be a correct network configuration?
> >> >
> >> > Eric
> >> It is a problem to have different networks, who doesn't communicate one with 
> >> each other, in same ethernet segment?
> >> 
> >> Does it violate anything?
> >
> > I'm pretty sure it doesn't.
> >
> > It's a common enough situation. A second subnet (or more) is assigned
> > to a link because the first isn't large enough, and renumbering the
> > hosts into a larger subnet is not practical at the time. A
> > 'one-armed router' is used up stream to have traffic go between the
> > different subnets, at the cost of traffic double traversing the link.
> > (The worst example I've seen is 25 subnets operating this way!)
> >
> > Fundamentally it is no different to routing traffic to other subnets.
> > IP was designed on the assumption that there'd only be a single subnet
> > per link, so nothing was done to make this scenario more efficent.
> >
> > IPv6 has introduced the ability for hosts to be told by their default
> > router that destinations they think are "offlink", because the address
> > falls outside a locally assigned or learned prefixes, are actually
> > "onlink", preventing this double traversing problem.
> 
> Multiple subnets on an ethernet segment sure.  Multiple subnets
> subnets that don't communicate?  Not telling your router about all of
> the subnets on the ethernet segment?
> 
> The combination of not configuring the router to know about all of the
> subnets and enabling proxy arp is what is causing problems for Denys.
> 
> That sure seems like a misconfiguration to me.
> 

A misconfiguration if you don't intend it, otherwise, isolation between
subnets on a common link can be useful. I've taken advantage of it
in networking test labs. 

It can also be useful for basic traffic engineering. You set up two
routers attached to the same link, but both with different configured
prefixes. Nodes are assigned adresses out of one or the other prefix,
to influence which outbound (and inbound) path their traffic takes.
Leaving it like that would be a bit unusual, however it could be as
part of a gradual transition to splitting the link to reduce the
broadcast domain size.

Regards,
Mark.

