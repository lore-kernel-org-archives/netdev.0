From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Fri, 1 Sep 2006 15:10:45 -0700
Message-ID: <20060901221045.GB13975@bougret.hpl.hp.com>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157093640.2878.26.camel@ux156> <20060901163558.GB13815@bougret.hpl.hp.com> <200609012055.48799.mb@bu3sch.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:50130 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1751081AbWIAWLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 18:11:24 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200609012055.48799.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2006 at 08:55:48PM +0200, Michael Buesch wrote:
> 
> > 	Note that one thing that worry me with your approach is
> > footprint. I've used various embedded devices over the years, such as
> > the Gumstix (4MB Flash), and this is why WE was optimised for
> > footprint.
> 
> Can you please explain in more detail, how WE + the WE-netlink wrapper
> has lower footprint than this netlink-only layer?

	WE-netlink is optional. And WE-ioctl could be made optional
(still on the todo list). You can also disable WE-event and WE-iwspy
for further footprint reduction.

> > > The real
> > > problem with WE is, as I previously said, the ill-defined semantics of
> > > both the user-space API and the in-kernel API.
> > 
> > 	I don't understand why you say it's ill defined, it 100%
> > documented in the iwconfig man page.
> 
> It is horribly documented.
> There is one big union and one magic "extra" parameter.
> You have to guess (or look at other implementations) to find
> out which element of the union or even if and how to use the extra
> parameter. That's a real pain.
> And after you found out which element to use, you have to figure
> out somehow how to actually use that element. That's nontrivial,
> escpecially because some flags (that are not documented) may
> magically change the whole semantics of the contents.

	If you are trying to write WE without reading any other code,
that's true. But that's not the way sane people work. Sane people
cut'n'paste from other drivers, and then check the source code of
iwconfig (which is fully commented) in case of doubt.
	It's strange, many driver authors are not afraid of asking me
questions, but some can't manage to do that.

> In my opinion this
> "One function signature fits all" design used in WE is simply
> broken by design.

	So, are you saying that the 'syscal' design is broken by
nature ? I've never seen the kernel and glibc people complaining about
it.
	It was designed this way on purpose, because you get low
footprint and very good scalability. And I've yet to see anyone
tripped by it.

> Greetings Michael.

	Jean

-- 
VGER BF report: U 0.5
