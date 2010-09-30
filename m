From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/2] genetlink: introduce pre_doit/post_doit hooks
Date: Fri, 01 Oct 2010 00:49:15 +0200
Message-ID: <1285886955.5137.31.camel@jlt3.sipsolutions.net>
References: <20100930211013.472957770@sipsolutions.net>
	 <20100930211131.021309930@sipsolutions.net>
	 <AANLkTik9+zA4PPPx=q6CRM-sgOjjECJdtJTgkCG9pGAY@mail.gmail.com>
	 <1285886690.5137.28.camel@jlt3.sipsolutions.net>
	 <1285886821.5137.29.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	tgraf@suug.ch
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:49527 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216Ab0I3Wsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 18:48:40 -0400
In-Reply-To: <1285886821.5137.29.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-10-01 at 00:47 +0200, Johannes Berg wrote:
> On Fri, 2010-10-01 at 00:44 +0200, Johannes Berg wrote:
> > On Fri, 2010-10-01 at 08:41 +1000, Julian Calaby wrote:
> > 
> > > >  d) include two private pointers in each info
> > > >    struct passed between all these operations
> > > >    including doit(). (It's two because I'll
> > > >    need two in nl80211 -- can be extended.)
> > > 
> > > Stupid question:
> > > 
> > > Why not have a priv struct rather than an arbitrary array of two pointers?
> > 
> > It'd have to be dynamically allocated, and the "arbitrary" array of two
> > pointers can be on the stack.
> 
> Maybe I should elaborate -- a priv struct basically means just a single
> pointer, and then I'd have to allocate something to hold two pointers in
> nl80211 and assign it to that single pointer.

Come to think of it -- I could get away with a single pointer, since, if
both are assigned,

user_ptr[0] == wiphy_to_rdev(((netdev *)user_ptr[1])->ieee80211_ptr->wiphy)

but that's a lot of pointy things, and some functions only have the rdev
so it gets more complex. I think allowing two private pointers is a
decent compromise.

johannes

