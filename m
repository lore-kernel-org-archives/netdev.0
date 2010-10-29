From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Fri, 29 Oct 2010 18:32:58 +0100
Message-ID: <20101029173258.GW19804@ZenIV.linux.org.uk>
References: <20101028.112231.232747062.davem@davemloft.net>
 <AANLkTinAzvfrRHwW-w-Ppdu7LWd7nGTa4EWP=e6pKV2F@mail.gmail.com>
 <1288360820.2092.34.camel@dan>
 <AANLkTikeaXncdUohUiGF2EkhujYETK5dtyOJASffz2qR@mail.gmail.com>
 <AANLkTi=sUDRzGnkp57OCQUi9APHWLYLShhiTVHLyq1eV@mail.gmail.com>
 <20101029164532.GV19804@ZenIV.linux.org.uk>
 <AANLkTi=zieMoDdHgB_aY4xN=A6ErrjUWpaME1WwWrvnL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	Dan Rosenberg <drosenberg@vsecurity.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:50241 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755065Ab0J2RdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 13:33:02 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=zieMoDdHgB_aY4xN=A6ErrjUWpaME1WwWrvnL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 29, 2010 at 10:01:19AM -0700, Linus Torvalds wrote:
> On Fri, Oct 29, 2010 at 9:45 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > I don't see anything obviously broken (and we obviously have allowed
> > iov_len == 0 cases all along, so if anything, breakage won't be new).
> > However, I wonder if things like sendmsg() for datagrams have warranties
> > against silent truncation. ?Davem?
> 
> You missed that discussion - my argument is that anybody who thinks
> that they can send a single packet that is 2GB+ in size are already
> screwed. And the packet protocol will have some inherent upper limit
> anyway (possibly introduced by just allocation issues, but quite
> likely inherent to the protocol itself)

Sure, but... do we want to send something truncated in that case or
should we just fail?  Note that with your change previously deliberately
b0rken iovecs (anything with sum of lengths equal to 1<<31 on 32bit)
will get a chance to be accepted *OR* (much more likely) get rejected with
unexpected error value.  It may well be OK, but I'd like to hear from
network folks...
