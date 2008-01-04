From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 03 Jan 2008 19:36:52 -0800 (PST)
Message-ID: <20080103.193652.233777639.davem@davemloft.net>
References: <200801031813.57621.paul.moore@hp.com>
	<1199403607.4888.6.camel@localhost>
	<200801032219.04223.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, jarkao2@gmail.com, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47087
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752104AbYADDgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 22:36:53 -0500
In-Reply-To: <200801032219.04223.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Thu, 3 Jan 2008 22:19:03 -0500

> > Perhaps move the skb->cloned = 1 to just after n->cloned = 1
> > or
> > 	skb->cloned = n->cloned = 1;
> > or maybe
> > 	skb->cloned = 1;
> > 	C(cloned);
> 
> I thought about that, but I kinda like how the parent-skb-only changes are 
> grouped together at the end.  I think the distinction helps readability, but 
> then again we've already seen how subjective readability can be :)

I think either way is fine, as long as the stores are ordered
properly.  The ordering of the loads and little issues like
this skb->cloned thing are much less important.

Actually, if you look at the generated assembler, GCC makes
a mess of all of these bitfield accesses, largely destroying
the pure store stream since it does a read/modify/write on
a word for each bitfield set.
