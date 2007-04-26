From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [Security] [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 23:26:01 -0700
Message-ID: <20070426062601.GH2819@sequoia.sous-sol.org>
References: <20070425183856.GA6028@ms2.inr.ac.ru> <alpine.LFD.0.98.0704251311270.9964@woody.linux-foundation.org> <20070426052912.GA17402@kroah.com> <20070425.223201.108808547.davem@davemloft.net> <20070426054420.GA18057@kroah.com> <20070426054842.GA18630@kroah.com> <20070426055259.GF2819@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: security@kernel.org, netdev@vger.kernel.org, jaco@kroon.co.za,
	kuznet@ms2.inr.ac.ru, torvalds@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:50446 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754775AbXDZG2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 02:28:37 -0400
Content-Disposition: inline
In-Reply-To: <20070426055259.GF2819@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Chris Wright (chrisw@sous-sol.org) wrote:
> * Greg KH (greg@kroah.com) wrote:
> > fyi, here's the patch that I applied, perhaps 2.6.20 needed something
> > else too?
> <snip>
> > @@ -809,7 +815,7 @@ static void nl_fib_input(struct sock *sk
> >  
> >  	nl_fib_lookup(frn, tb);
> >  	
> > -	pid = nlh->nlmsg_pid;           /*pid of sending process */
> > +	pid = NETLINK_CB(skb).pid;       /* pid of sending process */
> 
> That's the important bit.  I'm testing against 2.6.20.8 right now.

Working fine here.  Any chance you booted a stale kernel?
If not, what's your nl_fib_input+0xe4.  Any chance that's
actually in nl_fib_lookup?
