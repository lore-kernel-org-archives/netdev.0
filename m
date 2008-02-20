From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SUNRPC: Mark buffer used for debug printks
	with	__maybe_unused
Date: Wed, 20 Feb 2008 12:41:45 -0500
Message-ID: <1203529305.13766.13.camel@heimdal.trondhjem.org>
References: <47BC3303.2040101@openvz.org>
	 <1203521357.7181.163.camel@localhost> <1203521514.7181.167.camel@localhost>
	 <47BC48C6.3050208@trash.net>  <1203525398.7181.178.camel@localhost>
	 <1203526956.13125.14.camel@heimdal.trondhjem.org>
	 <1203528204.7181.193.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Pavel Emelyanov <xemul@openvz.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:54864 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443AbYBTRlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 12:41:55 -0500
In-Reply-To: <1203528204.7181.193.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-02-20 at 09:23 -0800, Joe Perches wrote:
> On Wed, 2008-02-20 at 12:02 -0500, Trond Myklebust wrote:
> > > #ifdef DEBUG
> > > #define some_print_wrapper(fmt, arg...) \
> > >         do { if (0) printk(KERN_DEBUG fmt, ##arg); } while (0)
> > > #else
> > > #define some_print_wrapper(fmt, arg...) \
> > > 	printk(KERN_DEBUG fmt, ##arg)
> > > #endif
> > Have you actually read include/linux/sunrpc/debug.h?
> 
> Yes, I have.
> 
> What's there:
> 
> #define dfprintk(fac, args...) do ; while (0)
> 
> vs what's suggested:
> 
> #define dfprintk(fac, args...) \
> 	do  { if (0) printk(##args); } while (0);
> 
> No argument verification is done to args
> 
> There has been code that fails to compile with -DDEBUG when
> the code use two different #ifdef DEBUG #else macros.
> I think some of the USB code was reworked because of that.
> 
> The extra verification is just a guard against bad arguments
> when compiled normally.  It's similar to what's done in kernel.h
> pr_debug without the __attribute__((format(printf,x,y))) so
> that calls made as arguments to functions aren't called
> unnecessarily.

RPC_DEBUG is on by default if SYSCTL is compiled in, so it is not as if
we're having any trouble typechecking the arguments. In fact, most of
the major distros also tend to enable RPC_DEBUG, since it does come in
handy when their customers report rpc/nfs problems.

As you can see, there is already a macro RPC_IFDEBUG to deal with simple
code that depends on whether or not RPC_DEBUG is set. Using that will
make it obvious to a reader exactly when the declaration will be
optimised away, and why, without compromising gcc's ability to warn us
if it were to be unused due to some future code change.


