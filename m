From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Fri, 23 Nov 2007 14:35:05 +1100
Message-ID: <200711231435.05788.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de> <200711231125.12832.rusty@rustcorp.com.au> <200711230236.22759.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41122 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752351AbXKWDfI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 22:35:08 -0500
In-Reply-To: <200711230236.22759.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 23 November 2007 12:36:22 Andi Kleen wrote:
> On Friday 23 November 2007 01:25, Rusty Russell wrote:
> > That's my point.  If there's a whole class of modules which can use a
> > symbol, why are we ruling out external modules?
>
> The point is to get cleaner interfaces.

But this doesn't change interfaces at all.  It makes modules fail to load 
unless they're on a permitted list, which now requires maintenance.

> Anything which is kind of internal 
> should only be used by closely related in tree modules which can be
> updated.

Is there evidence that this is a problem for us?  Are there any interfaces 
you've restricted so far which are causing problems?

> Point of is not to be some kind of license enforcer or similar, 
> there are already other mechanisms for that. Just to get the set of really
> public kernel interfaces down to a manageable level.

Why do we care what a "really public"?  We treat them all the same, as 
changeable interfaces.  ie.  None of them are "really public".

For example, you put all the udp functions in the "udp" namespace.  But what 
have we gained?  What has become easier to maintain?  All those function 
start with "udp_": are people having trouble telling what they're for?

If you really want to reduce "public interfaces" then it's much simpler to 
mark explicitly what out-of-tree modules can use.  We can have a list of 
symbol names in include/linux/public-exports.h.

I just don't see what problems this separation solves.
Rusty.
