From: "Gerd v. Egidy" <lists@egidy.de>
Subject: Re: [patch] RFC: matching interface groups
Date: Thu, 3 Aug 2006 14:57:25 +0200
Message-ID: <200608031457.26120.lists@egidy.de>
References: <1154452209.6395.77.camel@bzorp.balabit> <20060801191805.GA28649@zion.homelinux.com> <1154502269.6241.11.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Balazs Scheidler <bazsi@balabit.hu>,
	Sven Schuster <schuster.sven@gmx.de>,
	Phil Oester <kernel@linuxace.com>, netdev@vger.kernel.org,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re01.intra2net.com ([82.165.28.202]:41743 "EHLO
	re01.intra2net.com") by vger.kernel.org with ESMTP id S932436AbWHCM5a
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 08:57:30 -0400
To: netfilter-devel@lists.netfilter.org
In-Reply-To: <1154502269.6241.11.camel@bzorp.balabit>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > > Since in this scenario userspace is able to determine ppp vs pptp,
> > > could you not also do something like have an inbound_ppp and
> > > inbound_pptp chain, then jump to the appropriate chain depending on
> > > type?  If you need per-interface rules, then create an inbound_pppX
> > > chain, populate it with rules, then jump to that chain if -i pppX.  In
> > > ip-down, just delete the chain as well as the jump.
> >
> > if I understood Balazs correctly, one of the things he wanted to
> > avoid is addition/deletion of iptables rules on every pppX interface
> > up/down
>
> Exactly.

We faced a similar problem: we wanted to not only differentiate between ppp 
and pptp interfaces but even between different providers connected via ppp 
and pptp.

We ended up predefining all possible providers in the rules and differentiate 
between them using the ipt_condition module. This module is not very 
well-loved in the netfilter community but there are usecases like this where 
it comes in handy.

Maybe this is a solution for you too.

> > as this would require the complete chain (say, INPUT or
> > OUTPUT) to be "downloaded" to userspace, modified and then again
> > "uploaded" to the kernel. At least until iptables redesign to
> > allow replacement/insertion/deletion of single rules is completed
> > which if started at all will take quite some more time :-)
>
> Iptables operates on a per-table basis, so it is not only the INPUT or
> OUTPUT chain that needs to be down and uploaded, but the whole filter
> table.

The problem with the current solution is not only speed and maintainability 
but also locking: if two device up/down events happen at the same time in 
this scenario, the tabels will become wrong until you develop some kind of 
userspace locking.

Kind regards,

Gerd
