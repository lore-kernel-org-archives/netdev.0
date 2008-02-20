From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] SUNRPC: Mark buffer used for debug printks
	with	__maybe_unused
Date: Wed, 20 Feb 2008 09:23:24 -0800
Message-ID: <1203528204.7181.193.camel@localhost>
References: <47BC3303.2040101@openvz.org>
	 <1203521357.7181.163.camel@localhost> <1203521514.7181.167.camel@localhost>
	 <47BC48C6.3050208@trash.net>  <1203525398.7181.178.camel@localhost>
	 <1203526956.13125.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Pavel Emelyanov <xemul@openvz.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1176 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbYBTRYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 12:24:15 -0500
In-Reply-To: <1203526956.13125.14.camel@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-20 at 12:02 -0500, Trond Myklebust wrote:
> > #ifdef DEBUG
> > #define some_print_wrapper(fmt, arg...) \
> >         do { if (0) printk(KERN_DEBUG fmt, ##arg); } while (0)
> > #else
> > #define some_print_wrapper(fmt, arg...) \
> > 	printk(KERN_DEBUG fmt, ##arg)
> > #endif
> Have you actually read include/linux/sunrpc/debug.h?

Yes, I have.

What's there:

#define dfprintk(fac, args...) do ; while (0)

vs what's suggested:

#define dfprintk(fac, args...) \
	do  { if (0) printk(##args); } while (0);

No argument verification is done to args

There has been code that fails to compile with -DDEBUG when
the code use two different #ifdef DEBUG #else macros.
I think some of the USB code was reworked because of that.

The extra verification is just a guard against bad arguments
when compiled normally.  It's similar to what's done in kernel.h
pr_debug without the __attribute__((format(printf,x,y))) so
that calls made as arguments to functions aren't called
unnecessarily.

cheers, Joe

