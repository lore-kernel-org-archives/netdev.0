From: Stephan Peijnik <stephan@peijnik.at>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal
	firewalls"
Date: Tue, 20 Jan 2009 19:56:20 +0100
Message-ID: <1232477780.24943.116.camel@sp-laptop3.sp-local>
References: <1232473719.24943.102.camel@sp-laptop3.sp-local>
	 <alpine.LSU.2.00.0901201916340.516@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-security-module <linux-security-module@vger.kernel.org>,
	netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, sam@synack.fr
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kappa.sp-its.at ([83.65.62.72]:56713 "EHLO kappa.sp-its.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753815AbZATS4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 13:56:44 -0500
In-Reply-To: <alpine.LSU.2.00.0901201916340.516@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-20 at 19:24 +0100, Jan Engelhardt wrote:
> On Tuesday 2009-01-20 18:48, Stephan Peijnik wrote:
> >
> >A personal firewall should implement per-application mandatory access
> >control for sockets. In short this means that such a program decides
> >every time a call to either socket(), accept(), bind(), connect() or
> >listen()[...]
> 
> Without reading any further (yet), that sounds like
> http://www.synack.fr/project/cn_net/cn_net.html

Yes, it does, and it's exactly that. However, as a LSM it can only be
used whilst no other LSM is enabled. 
Samir Bellabes has been involved in the discussion at
linux-security-module too.
Even though I like the implementation personally I'm unsure about
whether this should be dubbed "the one" way to do this or whether there
should be an API for alternative implementations.

> >And yet another approach was suggested: hooking socket-related calls
> >directly in net/socket.c. This would mean that the personal firewall
> >code is called directly from net/socket.c and can this way work in
> >process-context, without using the LSM framework.
> >On the other hand this would add, besides the LSM calls that are in
> >place in net/socket.c a few extra calls which might not be what we want.[...]
> 
> My opinion up to here would be to split LSM into the LSM category
> {selinux, apparmor, tomoyo} and the other, new LSM category
> {networking stuff}, just as a potential idea to get over the
> stacking / single LSM use  issue.

The problem here is that all of your three examples do use the LSM
networking hooks too. If two functions are to be called from the LSM
core (ie. the generic LSM one and the networking-LSM one) we get pretty
much the same problem back as if we multiple generic LSMs enabled.

> >Implementations using the LSM approach are TuxGuardian [0] and snet [1].
> >Code implementing the last mentioned approach can be found in git over
> >at [2] in the sactl-direct branch.
> >
> >[0] http://tuxguardian.sourceforge.net/
> 
> tuxguardian is probably regardable as obsoleted by cn_net (if it's
> finished someday, or is it?) -- Samir probably knows more.

The tuxguardian developers seem to be interested in picking up
development again and as I wrote Samir has already been involved in this
discussion.

-- Stephan

