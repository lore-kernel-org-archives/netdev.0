From: Julia Lawall <julia@diku.dk>
Subject: Re: question about nla_nest_cancel
Date: Thu, 27 Jan 2011 18:25:36 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1101271825040.13796@pc-004.diku.dk>
References: <Pine.LNX.4.64.1101271804530.13796@pc-004.diku.dk>
 <20110127172118.GA331@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:36568 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751520Ab1A0RZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 12:25:41 -0500
In-Reply-To: <20110127172118.GA331@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Jan 2011, Kurt Van Dijck wrote:

> On Thu, Jan 27, 2011 at 06:08:34PM +0100, Julia Lawall wrote:
> > 
> > I find numerous occurrences of code like the following, in which nest ends 
> > up with the value NULL and then nla_nest_cancel is called with nest as the 
> > second argument.  But nla_nest_cancel just calls nlmsg_trim with the same 
> > second argument, and nlmsg_trim does nothing if its second argument is 
> > NULL.  Is there any reason to keep these calls?
> I just learned this:
> nla_nest_start() adds data to the skb.
> nla_nest_end() 'commits' the proper length.
> nla_nest_cancel() reverts skb to the state before nla_nest_start(),
> as if nothing happened.

Yes, I can see this as well.  But in this case, it seems to me taht 
nothing has happened, because nla_nest_star has returned NULL?

julia
