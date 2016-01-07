From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: header conflict introduced by change to
 netfilter_ipv4/ip_tables.h
Date: Thu, 7 Jan 2016 21:15:17 +0200
Message-ID: <20160107191517.GC6104@lakka.kapsi.fi>
References: <20160106092007.1c5a0c75@xeon-e3>
 <88a455d4b6dc4d4398553e6529d7b94a@HQ1WP-EXMB11.corp.brocade.com>
 <20160107103040.649ab878@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:49412 "EHLO mail.kapsi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752010AbcAGTPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 14:15:25 -0500
Content-Disposition: inline
In-Reply-To: <20160107103040.649ab878@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2016 at 10:30:40AM -0800, Stephen Hemminger wrote:
> On Thu, 7 Jan 2016 07:29:50 +0000
> Mikko Rapeli <mikko.rapeli@iki.fi> wrote:
> 
> > On Wed, Jan 06, 2016 at 09:20:07AM -0800, Stephen Hemminger wrote:
> > > This commit breaks compilation of iproute2 with net-next.
> > 
> > Ok, linux/if.h and libc net/if.h have overlapping defines, and this is not
> > the only one. I saw lots of them in the core dump headers.
> > 
> > How should we handle them? Another ifndef for IFNAMSIZ into kernel uapi
> > headers?
> > 
> > -Mikko
> 
> Probably need to do the same thing that was done previously for these
> kind of conflicts.  This makes make linux/if.h change to adapt to net/if.h
> being included before it.

Ok, got it. And found include/uapi/linux/libc-compat.h. Did not know about it
and was looking for solutions to these problems.

But now I feel like writing a test script for mixing of kernel uapi
and libc headers to find out how many other collitions are still there.
Not good for the pile of over 70 patches in my branch
https://github.com/torvalds/linux/compare/master...mcfrisk:headers_test_v05

> Or revert your patch.

I'm fine with this too.

-Mikko
