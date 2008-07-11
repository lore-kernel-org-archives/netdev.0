From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv4 Multicast: prevent reception of mcast frames from
	unjoined groups
Date: Fri, 11 Jul 2008 13:35:49 -0400
Message-ID: <20080711173549.GC4534@hmsreliant.think-freely.org>
References: <20080711152112.GA4534@hmsreliant.think-freely.org> <OF6F2387F9.1EAA3BCD-ON88257483.005E2CF9-88257483.005EE681@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jmorris@namei.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3556 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986AbYGKRqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 13:46:04 -0400
Content-Disposition: inline
In-Reply-To: <OF6F2387F9.1EAA3BCD-ON88257483.005E2CF9-88257483.005EE681@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 11, 2008 at 10:16:41AM -0700, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 07/11/2008 08:21:13 AM:
> 
> > The current ipv4 multicast code incorrectly allows frames destined to 
> any
> > multicast group to be received on any socket that is bound to 
> INADDR_ANY,
> > regardless of weather or not that socket is subscribed to that group.
> 
> NACK. As Alexey already quoted from me, multicasting just doesn't work
> that way, since the beginning of time.
> 
>                                                                 +-DLS

So you're saying that if I take a process, call bind, specifying INADDR_ANY, and
then call setsockopt(...,IP_ADD_MEMBERSHIP,...) specifying a multicast group X,
that I can expect to recieve messages from other multicast addresses that other
processes in the system have joined to?  That doesn't seem at all correct, and
it contradicts what you and I discussed privately.  As the code currently
stands, if you do the above in process A, joining mcast group X, and then start
a second process on the same system, joining mcast group Y, process A will
recieve mcast group Y frames.

Neil

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
