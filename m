From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
 implementation & Netlink protocol
Date: Sun, 05 Apr 2009 02:54:48 -0700 (PDT)
Message-ID: <20090405.025448.63731537.davem@davemloft.net>
References: <20090402093952.GA30553@gondor.apana.org.au>
	<20090402.025223.242893473.davem@davemloft.net>
	<20090402095957.GA30799@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, nhorman@tuxdriver.com, zbr@ioremap.net,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33541
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756980AbZDEJy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 05:54:59 -0400
In-Reply-To: <20090402095957.GA30799@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 2 Apr 2009 17:59:57 +0800

> On Thu, Apr 02, 2009 at 02:52:23AM -0700, David Miller wrote:
> >
> > It has to do with how the netlink attributes get packed together
> > into the messages.  It's this crap:
> > 
> > #define NLMSG_ALIGNTO	4
> > #define NLMSG_ALIGN(len) ( ((len)+NLMSG_ALIGNTO-1) & ~(NLMSG_ALIGNTO-1) )
> >  ...
> > #define NLMSG_NEXT(nlh,len)	 ((len) -= NLMSG_ALIGN((nlh)->nlmsg_len), \
> > 				  (struct nlmsghdr*)(((char*)(nlh)) + NLMSG_ALIGN((nlh)->nlmsg_len)))
> > 
> > Thus, nothing in an nlmsg can ever be more than 4 byte aligned.
> > And this is hard coded into the protocol.
> 
> Ah yes, this is the killer.
> 
> I suppose we can modify in-kernel helpers like nla_parse to deal
> with that by copying if it's unaligned.  Though we'll have to
> figure out how to free the memory.

Note that this issue exists on the user side as well.  libnl has some
ugly hacks to deal with touching u64 stuff received in netlink
messages due to this.
