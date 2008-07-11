From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] IPv4 Multicast: prevent reception of mcast frames from unjoined groups
Date: Fri, 11 Jul 2008 20:48:01 +0400
Message-ID: <20080711164801.GA31161@ms2.inr.ac.ru>
References: <20080711152112.GA4534@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	dlstevens@us.ibm.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:55813 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753993AbYGKQsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 12:48:20 -0400
Content-Disposition: inline
In-Reply-To: <20080711152112.GA4534@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> The current ipv4 multicast code incorrectly allows frames destined to any
> multicast group to be received on any socket that is bound to INADDR_ANY,

Yes, it used to behave this way.

And this is more fresh (than reference to practice in days of yore :-))
rationale given by David Stevens:


> Subject: Re: [PATCH] make ipv4 multicast packets only get delivered to sockets	that
>  are joined to group
> From: David Stevens <dlstevens@us.ibm.com>
> Date: Thu, 14 Sep 2006 08:39:39 -0700
> 
> Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote on 09/14/2006 03:30:37 AM:
> 
> > Hello!
> > 
> > >         No, it returns 1 (allow) if there are no filters to explicitly
> > > filter it. I wrote that code. :-)
> > 
> > I see. It did not behave this way old times.
> > 
> > From your mails I understood that current behaviour matches another
> > implementations (BSD whatever), is it true?
> 
> Hi, Alexey,
> 
> If you mean IPv6 code in current BSD derivatives, I don't know.
> 
> The IPv6 behaviour was different from IPv4 on Linux and was changed for
> compatibility with IPv4 (discussion on netdev agreed that binding
> should determine socket delivery, not group membership, or simply
> that there was no reason to be different from long-standing IPv4 
> practice).
> 
> The IPv4 code is that way for compatibility with everything else since
> about ~4.3BSD (with the possible exception of Solaris 8, apparently).
> 
> FWIW, I think Deering's original interpretation is correct. Adding
> a multicast address to an interface by joining a group is little
> different from adding a unicast address via SIOCSIFADDR, which
> certainly does affect packets delivered to the machine and to any
> INADDR_ANY-bound socket. Binding to the multicast address and not
> INADDR_ANY will give you only packets for that group, if that's
> what you want, just as in the unicast address-specific bind.
> 
>                                                         +-DLS
