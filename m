From: Jonathan Day <imipak@yahoo.com>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal firewalls"
Date: Tue, 20 Jan 2009 11:46:43 -0800 (PST)
Message-ID: <317242.47729.qm@web31508.mail.mud.yahoo.com>
References: <1232473719.24943.102.camel@sp-laptop3.sp-local>
Reply-To: imipak@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: linux-security-module <linux-security-module@vger.kernel.org>,
	Stephan Peijnik <stephan@peijnik.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web31508.mail.mud.yahoo.com ([68.142.198.137]:46222 "HELO
	web31508.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754589AbZATTxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 14:53:23 -0500
In-Reply-To: <1232473719.24943.102.camel@sp-laptop3.sp-local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Tue, 1/20/09, Stephan Peijnik <stephan@peijnik.at> wrote:
(snip)
> Firstly, I would like to elaborate on what we more or less
> agreed on a
> personal firewall should be able to do and what such a
> piece of software
> is intended for.
> 
> A personal firewall should implement per-application
> mandatory access
> control for sockets. In short this means that such a
> program decides
> every time a call to either socket(), accept(), bind(),
> connect() or
> listen() is made whether the invoking program is allowed to
> do so or
> not. No per-packet filtering can be done and neither is
> connection
> intercepting of any interest.

It depends on what what it is that the MAC is trying to accomplish.

Possibility 1: It's an enhanced tcpwrapper/firewall concept, which either blocks or allows any and all connections from named remote sources on identified ports. From your description of it being a "personal firewall", I am guessing this is what is being accomplished.

Possibility 2: It's being used the same way as all other mandatory access controls, so only connections from a source socket from a user/app combination that has been explicitly granted permission is permitted. This is how I would personally understand mandatory access controls over a network, as this provides a uniform view of what a MAC is.

Possibility 3: Some permutation of the above two, so that you can restrict connections both as a firewall and as a permissions concept.

There are probably other ways of constructing a MAC for sockets, but these are the two that spring to mind first. Admittedly because they also happen to be the types of greatest interest to me, but I'm not immune to bouts of fixation.

The two would logically be implemented in different ways at different levels in the stack, as they do completely different tasks. Both need to know about processes, but one only cares about local processes and the other cares about both local and remote.

> As personal firewalls are targeted at single-user, desktop
> systems the
> decision on whether a call is allowed or not is usually
> made by the user
> of that system (for example using a popup asking the user
> what to do).

I'm not sure that that's such a good target. There are plenty of server processes (BGP springs to mind) where you want per-process restrictions but can't necessarily trust the application's built-in restrictions on who/what can connect. This would be primarily an example of the first of the two forms of socket MAC, as you'd be more concerned with the connecting machine than the connecting user ID or process ID.

In cloud computing, it is especially important to prevent two systems running on the same cloud from interacting without prior permission. It would not be good if company A's software could interact with company B's database simply because B was foolish enough to use a cloud in the first place. Because here you are concerned very much with restrictions at the user/process level at both sides of the connection, this would need to be the second sort of socket MAC.

In both cases, you're definitely outside the desktop, so it seems clear that it's not a desktop-specific thing but an idea that would be extremely useful across the board, almost no matter how you envisage it.

> This means personal firewalls should not enforce system
> security policy,
> but rather a per-user security policy.
> The implementations can then add caching of decisions made
> (ie.
> "remember this decision") and thus not ask every
> time a call is made.
> Also, the only protocols to be supported are IPv4 and IPv6.
> Adding
> support for AF_UNIX and/or AF_NETLINK doesn't make much
> sense, as this
> is not network-related and would only increase the amount
> of work a
> personal firewall implementation has to do.

I agree that Unix and Netlink would not be useful, but there are other socket types that are LAN- or WAN-based, and I'd not be too quick to implement anything that precluded them being covered. (There's a difference between designing code in a way that makes extending it hard and actually implementing other network types, so only implementing IPv4 and IPv6 on a framework that could be extended by anyone deeply passionate about other protocls makes sense -- unless implementing it that way would be so much harder that it's pointless.)

> All proposed implementations of personal firewalls until
> now have made
> it rather clear that the decision-making logic should be
> placed in
> userspace, whilst only a small piece of code communicating
> with a
> userspace daemon should be placed in the kernel itself.

Well, it has probably not been a significant factor in anyone's decision, but it occurs to me that per-process firewalling within the kernel makes the "per-process" bit much more complicated and would not work at all using any of the zerocopy or kernel bypass networking mechanisms.

Ok, there are probably three people on the planet using either networking method, so if it didn't occur to anyone, there would be exceptionally good reason. On the other hand, if all proposed solutions would be just as useful to said magi as to Normal People, then that would seem to be a Good Idea.

(snipped remainer)



      
