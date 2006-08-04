From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] RFC: matching interface groups
Date: Fri, 04 Aug 2006 12:06:39 +0200
Message-ID: <44D31C2F.2050702@trash.net>
References: <1154452209.6395.77.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:720 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1030217AbWHDKIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 06:08:35 -0400
To: Balazs Scheidler <bazsi@balabit.hu>
In-Reply-To: <1154452209.6395.77.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Balazs Scheidler wrote:
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


I like it .. kind of like routing realms. For your specific case there
is a possible solution already supported by the kernel, you can
pre-allocate ppp devices using PPPIOCNEWUNIT, rename them and later
attach to individual units in the ppp daemon using PPPIOCATTACH
(I have a patch for this somewhere if you're interested). But that
only works for PPP devices and the group idea looks more flexible.

