From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
	implementation & Netlink protocol
Date: Thu, 2 Apr 2009 17:59:57 +0800
Message-ID: <20090402095957.GA30799@gondor.apana.org.au>
References: <20090304.030044.163418715.davem@davemloft.net> <20090402093952.GA30553@gondor.apana.org.au> <20090402.025223.242893473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, nhorman@tuxdriver.com, zbr@ioremap.net,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48523 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759520AbZDBKAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 06:00:11 -0400
Content-Disposition: inline
In-Reply-To: <20090402.025223.242893473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2009 at 02:52:23AM -0700, David Miller wrote:
>
> It has to do with how the netlink attributes get packed together
> into the messages.  It's this crap:
> 
> #define NLMSG_ALIGNTO	4
> #define NLMSG_ALIGN(len) ( ((len)+NLMSG_ALIGNTO-1) & ~(NLMSG_ALIGNTO-1) )
>  ...
> #define NLMSG_NEXT(nlh,len)	 ((len) -= NLMSG_ALIGN((nlh)->nlmsg_len), \
> 				  (struct nlmsghdr*)(((char*)(nlh)) + NLMSG_ALIGN((nlh)->nlmsg_len)))
> 
> Thus, nothing in an nlmsg can ever be more than 4 byte aligned.
> And this is hard coded into the protocol.

Ah yes, this is the killer.

I suppose we can modify in-kernel helpers like nla_parse to deal
with that by copying if it's unaligned.  Though we'll have to
figure out how to free the memory.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
