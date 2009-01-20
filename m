From: Paul Moore <paul.moore@hp.com>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal firewalls"
Date: Tue, 20 Jan 2009 16:01:44 -0500
Message-ID: <200901201601.44319.paul.moore@hp.com>
References: <317242.47729.qm@web31508.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-security-module" <linux-security-module@vger.kernel.org>,
	Stephan Peijnik <stephan@peijnik.at>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: imipak@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:47254 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756937AbZATVBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 16:01:47 -0500
In-Reply-To: <317242.47729.qm@web31508.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 January 2009 2:46:43 pm Jonathan Day wrote:
> --- On Tue, 1/20/09, Stephan Peijnik <stephan@peijnik.at> wrote:
> (snip)
>
> > Firstly, I would like to elaborate on what we more or less
> > agreed on a
> > personal firewall should be able to do and what such a
> > piece of software
> > is intended for.
> >
> > A personal firewall should implement per-application
> > mandatory access
> > control for sockets. In short this means that such a
> > program decides
> > every time a call to either socket(), accept(), bind(),
> > connect() or
> > listen() is made whether the invoking program is allowed to
> > do so or
> > not. No per-packet filtering can be done and neither is
> > connection
> > intercepting of any interest.
>
> It depends on what what it is that the MAC is trying to accomplish.
>
> Possibility 1: It's an enhanced tcpwrapper/firewall concept, which
> either blocks or allows any and all connections from named remote
> sources on identified ports. From your description of it being a
> "personal firewall", I am guessing this is what is being
> accomplished.
>
> Possibility 2: It's being used the same way as all other mandatory
> access controls, so only connections from a source socket from a
> user/app combination that has been explicitly granted permission is
> permitted. This is how I would personally understand mandatory access
> controls over a network, as this provides a uniform view of what a
> MAC is.
>
> Possibility 3: Some permutation of the above two, so that you can
> restrict connections both as a firewall and as a permissions concept.

Based on my understanding from previous discussions ... while the author 
chose to use the term MAC, what is being proposed is less of a 
mandatory solution and more of a discretionary solution as the ultimate 
access control decision resides with the user clicking on the 
allow/deny button versus the system's security policy.  I believe what 
Stephan is proposing is a mechanism which would prompt users (or some 
userspace application acting as a user) to make a decision on specific 
network events such as new connections.

> > This means personal firewalls should not enforce system
> > security policy,
> > but rather a per-user security policy.
> > The implementations can then add caching of decisions made
> > (ie.
> > "remember this decision") and thus not ask every
> > time a call is made.
> > Also, the only protocols to be supported are IPv4 and IPv6.
> > Adding
> > support for AF_UNIX and/or AF_NETLINK doesn't make much
> > sense, as this
> > is not network-related and would only increase the amount
> > of work a
> > personal firewall implementation has to do.
>
> I agree that Unix and Netlink would not be useful, but there are
> other socket types that are LAN- or WAN-based, and I'd not be too
> quick to implement anything that precluded them being covered.
> (There's a difference between designing code in a way that makes
> extending it hard and actually implementing other network types, so
> only implementing IPv4 and IPv6 on a framework that could be extended
> by anyone deeply passionate about other protocls makes sense --
> unless implementing it that way would be so much harder that it's
> pointless.)

I think it is reasonable to limit an initial implementation to just 
AF_INET[6] sockets.  As you note, if done properly it shouldn't be 
difficult to extend to other address/protocol families.

-- 
paul moore
linux @ hp
