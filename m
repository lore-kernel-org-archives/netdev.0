From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: VRFs and the scalability of namespaces
Date: Tue, 30 Sep 2014 01:50:24 +0200
Message-ID: <1412034624.2008259.173208057.03BE7CBA@webmail.messagingengine.com>
References: <5425EAA6.7040302@gmail.com>
 <1411824598.2136890.172383085.705271DD@webmail.messagingengine.com>
 <54295971.2040402@gmail.com> <54298B66.8060807@candelatech.com>
 <CACP96tR_c3-nVEGhswm1qt1WGXPNzyXA61FCxPutCTPNomjy+g@mail.gmail.com>
 <54299019.3050604@candelatech.com> <5429EEAF.9030702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:50810 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752538AbaI2XuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 19:50:24 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 5E85B20A52
	for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 19:50:24 -0400 (EDT)
In-Reply-To: <5429EEAF.9030702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014, at 01:43, David Ahern wrote:
> On 9/29/14, 11:00 AM, Ben Greear wrote:
> > On 09/29/2014 09:50 AM, Sowmini Varadhan wrote:
> >> On Mon, Sep 29, 2014 at 12:40 PM, Ben Greear <greearb@candelatech.com> wrote:
> >>> On 09/29/2014 06:06 AM, David Ahern wrote:
> >>
> >>>
> >>> We have implemented support for at least most of this (excepting duplicate IPs)
> >>> using routing tables, rules, and (optionally, xorp as the router).
> >>>
> >>
> >> My undertanding of multiple routing-tables/rules was that they
> >> are closer in semantics to switch/router ACLs than to VRFs, eg.,
> >> one big difference is that an interface can belong to exactly one
> >> VRF at a time, which is not mandated by multiple routing-tables/rules.
> >>
> >> Was I mistaken?
> >
> > You can effectively force an interface to belong to a particular virtual
> > router (table).  It is not trivial to do, and possibly I have still not
> > covered every possible case.  Some rules grow somewhat exponentially as
> > interfaces are added to virtual routers (ie, preference 10 rules).
> 
> An interesting way of doing it; thanks for the reference point.
> 
> Fundamentally the design should be able to assign interfaces to a single 
> VRF, support duplicate IP addresses on different interfaces in different 
> VRFs and be able to scale to 10,000+ netdevices -- devices representing 
> physical ports as well as logical interfaces built on top of them (e.g., 
> sub-interfaces).

Duplicate IP addresses don't go well with current linux stack being a
soft end model by default. Current separation is done on arp level today
if some kind of strong end model is desired. This calls for some kind of
namespaces again. ;)

Bye,
Hannes
