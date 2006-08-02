From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [patch] RFC: matching interface groups
Date: Wed, 02 Aug 2006 09:18:44 +0200
Message-ID: <1154503124.6241.21.camel@bzorp.balabit>
References: <1154452209.6395.77.camel@bzorp.balabit>
	 <20060801112919.765eb831@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from balabit.hu ([82.141.167.23]:65454 "EHLO balabit.hu")
	by vger.kernel.org with ESMTP id S1751309AbWHBHT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 03:19:26 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060801112919.765eb831@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-01 at 11:29 -0700, Stephen Hemminger wrote:
> On Tue, 01 Aug 2006 19:10:09 +0200
> Balazs Scheidler <bazsi@balabit.hu> wrote:
> 
> > Hi,
> > 
> > I would like to easily match a set of dynamically created interfaces
> > from my packet filter rules. The attached patch forms the basis of my
> > implementation and I would like to know whether something like this is
> > mergeable to mainline.
> > 
> > The use-case is as follows:
> > 
> > * I have two different subsystems creating interfaces dynamically (for
> > example pptpd and serial pppd lines, each creating dynamic pppX
> > interfaces),
> > * I would like to assign a different set of iptables rules for these
> > clients,
> > * I would like to react to a new interface being added to a specific set
> > in a userspace application,
> > 
> > The reasons I see this needs new kernel functionality:
> > 
> > * iptables supports wildcard interface matching (for example "iptables
> > -i ppp+"), but as the names of the interfaces used by PPTPD and PPPD
> > cannot be distinguished this way, this is not enough,
> > * Reloading the iptables ruleset everytime a new interface comes up is
> > not really feasible, as it abrupts packet processing, and validating the
> > ruleset in the kernel can take significant amount of time,
> > * the kernel change is very simple, adapting userspace to this change is
> > also very simple, and in userspace various software packages can easily
> > interoperate with each-other once this is merged.
> > 
> > The implementation:
> > 
> > Each interface can belong to a single "group" at a time, an interface
> > comes up without being a member in any of the groups.
> > 
> > Userspace can assign interfaces to groups after being created, this
> > would typically be performed in /etc/ppp/ip-up.d (and similar) scripts.
> > 
> > In spirit "interface group" is somewhat similar to the "routing
> > protocol" field for routing entries, which contains information on which
> > routing daemon was responsible for adding the given route entry.
> > 
> > [snip]

> I like the concept, but it probably needs more review.
> 
> There is a bigger issue, which is how should the network device namespace
> exist? There are virtualization efforts, that want to virtualize it,
> and network device names have always lived in a parallel universe.
> I don't expect your patch to solve this...

I have read the OLS paper on virtualization, it states that the current
state of affairs is that struct net_device will be assigned to one
specific namespace. As my change changes struct net_device itself, I
expect to work without problems when virtualization comes, the interface
group can be interpreted on a per-namespace basis.

There probably will be several iptables rulesets when the time comes,
one for each namespace, but again, struct net_device will be assigned to
a namespace, and the proper iptables tables will be iterated based on
the net_device assignment.

Am I missing something?

-- 
Bazsi

