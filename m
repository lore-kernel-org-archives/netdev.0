From: Julia Lawall <julia@diku.dk>
Subject: Re: question about nla_nest_cancel
Date: Thu, 27 Jan 2011 19:18:35 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1101271918250.13796@pc-004.diku.dk>
References: <Pine.LNX.4.64.1101271804530.13796@pc-004.diku.dk>
 <87pqrikzd6.fsf@benpfaff.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Ben Pfaff <blp@cs.stanford.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:43896 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000Ab1A0SSl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 13:18:41 -0500
In-Reply-To: <87pqrikzd6.fsf@benpfaff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Jan 2011, Ben Pfaff wrote:

> Julia Lawall <julia@diku.dk> writes:
> 
> > I find numerous occurrences of code like the following, in which nest ends 
> > up with the value NULL and then nla_nest_cancel is called with nest as the 
> > second argument.  But nla_nest_cancel just calls nlmsg_trim with the same 
> > second argument, and nlmsg_trim does nothing if its second argument is 
> > NULL.  Is there any reason to keep these calls?
> 
> I think that you are missing that NLA_PUT() contains an internal
> "goto nla_put_failure;".  If that branch is taken, then
> nla_nest_cancel() trims off the nested attribute.  So just
> removing the call to nla_nest_cancel() would change behavior in
> that case.

Indeed.  Thank you for the explanation.

julia
