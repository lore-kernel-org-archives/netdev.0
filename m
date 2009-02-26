From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] addition of a dropped packet notification service
Date: Wed, 25 Feb 2009 19:01:17 -0500
Message-ID: <20090226000117.GA6970@hmsreliant.think-freely.org>
References: <20090225115419.GA16150@hmsreliant.think-freely.org> <20090225.040130.169376412.davem@davemloft.net> <20090225141841.GD16150@hmsreliant.think-freely.org> <20090225.140701.42567297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, shemminger@vyatta.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57084 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbZBZABc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 19:01:32 -0500
Content-Disposition: inline
In-Reply-To: <20090225.140701.42567297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2009 at 02:07:01PM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 25 Feb 2009 09:18:41 -0500
> 
> > On Wed, Feb 25, 2009 at 04:01:30AM -0800, David Miller wrote:
> > > From: Neil Horman <nhorman@tuxdriver.com>
> > > Date: Wed, 25 Feb 2009 06:54:19 -0500
> > > 
> > > And you need the same thing to extract the same information
> > > if you used tracepoints.
> >
> > Well, I think the above implementation can be done with or without
> > tracepoints.  The mechanism by which we get the drop information is
> > orthogonal to what we do with it.
> > 
> > Thanks for the feedback guys.  I'll start modifying my kernel
> > changes to reflect this striaght away.  If you'd like to see
> > something in the interim, let me know and I'll send you what I have.
> > Currently I've got the user space delivery mechanism working as a
> > Netlink protocol, and with your above suggestions, I expect to have
> > the drop capture piece recode and working in the next few weeks.
> 
> Don't get me wrong.
> 
> If tracepoint annotations can be manageable (Herbert's concern), and
> solve multiple useful problems in practice rather than just
> theoretically (my concern), then that's what we should use for this
> kind of stuff.
> 
> I just personally haven't been convinced of that yet.
> 

Well, I think the manageablity issue is acceptable using multiple tracepoints at
the various locations where we increment corresponding statistics (either
visible via /proc/net/[snmp|snmpv6|etc], or another tool, like tc or netstat).
By wrapping the tracepoints in the macros they are fairly scalable and invisible
to other coders.

That said, I think marking drops at kfree_skb can also be made manageable, as
long as the assumption that the set of points in which we free without dropping
(kfree_skb_clean as you called it) is small.  I'm not 100% sure of that at the
moment, given that right now it looks like there might be a few hunder places in
various net drivers that I need to modify a call (but a sed script can handle
that I think).

In the end, I'm going to guess that the ability to solve multiple useful
problems will make the kfree solution win out.  I can see alot more potential
for noting when an skb is freed than just marking a statistic (tracing skbs
through the kernel for instance).

Now that I've got the netlink delivery working and a userspace app put together
(it'll be on fedorahosted soon) its pretty easy to play with both solutions.
I'll post a status update here in a few days letting you know how the kfree
solution works (I should have some inital thoughts by friday I think).

Thanks again for the thoughts, I owe you a beer at OLS (assuming my paper get
accepted) :)
Neil

