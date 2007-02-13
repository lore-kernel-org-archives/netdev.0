From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic:
 swapper/0x10000100/0
Date: Tue, 13 Feb 2007 15:54:46 -0800
Message-ID: <20070213155446.2f423782@freekitty>
References: <20070209133802.01286bbb.akpm@linux-foundation.org>
	<20070213202905.GA26818@gospo.rdu.redhat.com>
	<200702132226.l1DMQS22009230@death.nxdomain.ibm.com>
	<20070213.143243.78711492.davem@davemloft.net>
	<20070213230803.GB26818@gospo.rdu.redhat.com>
	<200702132333.l1DNX022012433@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, lpiccilli@gelre.com.br,
	bugme-daemon@bugzilla.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:33041 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456AbXBMXzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 18:55:31 -0500
In-Reply-To: <200702132333.l1DNX022012433@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> >/**
> > * bond_rtnl_wrapper - take the rtnl_lock if needed
> > * @x:         function with args
> > *
> > */
> >#define RTNL_WRAPPER(x)                \
> >({                                     \
> >       int __rc__;                     \
> >       if (rtnl_trylock()) {           \
> >               __rc__ = x;             \
> >               rtnl_unlock();          \
> >       } else {                        \
> >               __rc__ = x;             \
> >       }                               \
> >       __rc__;                         \
> >})
> >
> >
> >and wrapped it around the calls to dev_set_mac_address.  I wasn't
> >pleased with it, but it seemed like it worked pretty well based on the
> >testing I did.
> 
> 	The problem with this is that it'll cause failures in the case
> that some other unrelated entity holds rtnl ("x" will be performed
> concurrently with whomever actually holds rtnl).
> 
> 	-J

It is also a crap macro.
