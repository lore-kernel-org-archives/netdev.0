From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch] RFC: matching interface groups
Date: Tue, 1 Aug 2006 11:29:19 -0700
Message-ID: <20060801112919.765eb831@localhost.localdomain>
References: <1154452209.6395.77.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31666 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751777AbWHAS3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 14:29:31 -0400
To: Balazs Scheidler <bazsi@balabit.hu>
In-Reply-To: <1154452209.6395.77.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 01 Aug 2006 19:10:09 +0200
Balazs Scheidler <bazsi@balabit.hu> wrote:

> Hi,
> 
> I would like to easily match a set of dynamically created interfaces
> from my packet filter rules. The attached patch forms the basis of my
> implementation and I would like to know whether something like this is
> mergeable to mainline.
> 
> The use-case is as follows:
> 
> * I have two different subsystems creating interfaces dynamically (for
> example pptpd and serial pppd lines, each creating dynamic pppX
> interfaces),
> * I would like to assign a different set of iptables rules for these
> clients,
> * I would like to react to a new interface being added to a specific set
> in a userspace application,
> 
> The reasons I see this needs new kernel functionality:
> 
> * iptables supports wildcard interface matching (for example "iptables
> -i ppp+"), but as the names of the interfaces used by PPTPD and PPPD
> cannot be distinguished this way, this is not enough,
> * Reloading the iptables ruleset everytime a new interface comes up is
> not really feasible, as it abrupts packet processing, and validating the
> ruleset in the kernel can take significant amount of time,
> * the kernel change is very simple, adapting userspace to this change is
> also very simple, and in userspace various software packages can easily
> interoperate with each-other once this is merged.
> 
> The implementation:
> 
> Each interface can belong to a single "group" at a time, an interface
> comes up without being a member in any of the groups.
> 
> Userspace can assign interfaces to groups after being created, this
> would typically be performed in /etc/ppp/ip-up.d (and similar) scripts.
> 
> In spirit "interface group" is somewhat similar to the "routing
> protocol" field for routing entries, which contains information on which
> routing daemon was responsible for adding the given route entry.
> 
> Things to be done if you like this approach:
> 
> * interface group match in iptables,
> * support for naming interface groups in userspace, a'la routing
> protocols,
> * emitting a netlink notification when the group of an interface
> changes,
> * possibly converting the "ip link" command to use NETLINK messages,
> instead of using ioctl()
> 
> What do you think?

I like the concept, but it probably needs more review.

There is a bigger issue, which is how should the network device namespace
exist? There are virtualization efforts, that want to virtualize it,
and network device names have always lived in a parallel universe.
I don't expect your patch to solve this...
