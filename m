From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 11:12:07 -0400
Message-ID: <20090519151206.GA28034@hmsreliant.think-freely.org>
References: <20090518193559.05295fe4@nehalam> <20090519123417.GA7376@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lav@yar.ru, Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59172 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbZESPMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 11:12:37 -0400
Content-Disposition: inline
In-Reply-To: <20090519123417.GA7376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 12:34:17PM +0000, Jarek Poplawski wrote:
> On 19-05-2009 04:35, Stephen Hemminger wrote:
> > 
> > Begin forwarded message:
> > 
> > Date: Mon, 18 May 2009 14:10:20 GMT
> > From: bugzilla-daemon@bugzilla.kernel.org
> > To: shemminger@linux-foundation.org
> > Subject: [Bug 13339] New: rtable leak in ipv4/route.c
> > 
> > 
> > http://bugzilla.kernel.org/show_bug.cgi?id=13339
> ...
> > 2.6.29 patch has introduced flexible route cache rebuilding. Unfortunately the
> > patch has at least one critical flaw, and another problem.
> > 
> > rt_intern_hash calculates rthi pointer, which is later used for new entry
> > insertion. The same loop calculates cand pointer which is used to clean the
> > list. If the pointers are the same, rtable leak occurs, as first the cand is
> > removed then the new entry is appended to it.
> > 
> > This leak leads to unregister_netdevice problem (usage count > 0).
> > 
> > Another problem of the patch is that it tries to insert the entries in certain
> > order, to facilitate counting of entries distinct by all but QoS parameters.
> > Unfortunately, referencing an existing rtable entry moves it to list beginning,
> > to speed up further lookups, so the carefully built order is destroyed.
> > 
> > For the first problem the simplest patch it to set rthi=0 when rthi==cand, but
> > it will also destroy the ordering.
> 
> I think fixing this bug fast is more important than this
> ordering or counting. Could you send your patch proposal?


I agree that the corner case in which cand and rthi is a problem (although as
you point out easily fixable), and with an alteration to your proposal it can be
done without destroying the order.

As for the reordering by reference however, I don't see any move to front
heuristic being implemented anywhere in the routing path.  Where do you see this
happening?

Neil

