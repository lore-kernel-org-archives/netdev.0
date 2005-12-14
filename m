From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFC][PATCH 3/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 04:12:53 -0800
Message-ID: <20051214121253.GB23393@gaz.sfgoth.com>
References: <Pine.LNX.4.58.0512140052470.31720@w-sridhar.beaverton.ibm.com> <1134559039.25663.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932467AbVLNLza@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <1134559039.25663.12.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> But your user space that would add the routes is not so protected so I'm
> not sure this is actually a solution, more of an extended fudge.

Yes, there's no 100% solution -- no matter how much memory you reserve and
how many paths you protect if you try hard enough you can come up
with cases where it'll fail.  ("I'm swapping to NFS across a tun/tap
interface to a custom userland SSL tunnel to a server across a BGP route...")

However, if the 'extended fundge' pushes a problem from "can happen, even
in a very normal setup" territory to "only happens if you're doing something
pretty weird" then is it really such a bad thing?  I think the cost in code
complexity looks pretty reasonable.

> > +#define SK_CRIT_ALLOC(sk, flags) ((sk->sk_allocation & __GFP_CRITICAL) | flags)
> 
> Lots of hidden conditional logic on critical paths.

How expensive is it compared to the allocation itself?

> > +#define CRIT_ALLOC(flags) (__GFP_CRITICAL | flags)
> 
> Pointless obfuscation

Fully agree.

-Mitch
