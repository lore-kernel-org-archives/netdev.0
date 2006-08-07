From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [patch] RFC: matching interface groups
Date: Mon, 07 Aug 2006 13:44:10 +0200
Message-ID: <1154951050.18676.12.camel@bzorp.balabit>
References: <1154452209.6395.77.camel@bzorp.balabit>
	 <44D31C2F.2050702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from balabit.hu ([82.141.167.23]:59096 "EHLO balabit.hu")
	by vger.kernel.org with ESMTP id S1750711AbWHGLoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 07:44:13 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44D31C2F.2050702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-04 at 12:06 +0200, Patrick McHardy wrote:
> Balazs Scheidler wrote:
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
> > Things to be done if you like this approach:
> > 
> > * interface group match in iptables,
> > * support for naming interface groups in userspace, a'la routing
> > protocols,
> > * emitting a netlink notification when the group of an interface
> > changes,
> > * possibly converting the "ip link" command to use NETLINK messages,
> > instead of using ioctl()
> > 
> > What do you think?
> 
> 
> I like it .. kind of like routing realms. For your specific case there
> is a possible solution already supported by the kernel, you can
> pre-allocate ppp devices using PPPIOCNEWUNIT, rename them and later
> attach to individual units in the ppp daemon using PPPIOCATTACH
> (I have a patch for this somewhere if you're interested). But that
> only works for PPP devices and the group idea looks more flexible.

Thanks for liking it :) I'm going to implement a complete patch with
iptables match and support for naming interface groups like routing
realms and post it when I'm ready.

I'd go for the more general solution as I have other interfaces not just
ppp, it was just a trivial example.

-- 
Bazsi

