From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Mon, 26 Nov 2007 10:25:33 -0800
Message-ID: <20071126102533.1c774870@freepuppy.rosehill.pdx.hemminger.net>
References: <20071122343.446909000@suse.de>
	<adatznarrzc.fsf@cisco.com>
	<200711261228.15155.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757726AbXKZS1C@vger.kernel.org>
In-Reply-To: <200711261228.15155.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Nov 2007 12:28:14 +1100
Rusty Russell <rusty@rustcorp.com.au> wrote:

> On Monday 26 November 2007 07:27:03 Roland Dreier wrote:
> >  > This patch allows to export symbols only for specific modules by
> >  > introducing symbol name spaces. A module name space has a white
> >  > list of modules that are allowed to import symbols for it; all others
> >  > can't use the symbols.
> >  >
> >  > It adds two new macros:
> >  >
> >  > MODULE_NAMESPACE_ALLOW(namespace, module);
> >
> > I definitely like the idea of organizing exported symbols into
> > namespaces.  However, I feel like it would make more sense to have
> > something like
> >
> > MODULE_NAMESPACE_IMPORT(namespace);
> 
> Except C doesn't have namespaces and this mechanism doesn't create them.  So 
> this is just complete and utter makework; as I said before, noone's going to 
> confuse all those udp_* functions if they're not in the udp namespace.
> 
> For better or worse, this is not C++.
> 


Agreed. On first glance, I was intrigued but:

1) Why is everyone so concerned that export symbol space is large?
	- does it cost cpu or running memory?
	- does it cause bugs?
	- or are you just worried about "evil modules"?

2) These aren't real namespaces
	- all global names still have to be unique
	- still have to handle the "non-modular build" namespace conflicts
	- there isn't a big problem with conflicting symbols today.

So why bother adding complexity.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
