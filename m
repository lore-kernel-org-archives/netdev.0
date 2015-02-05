From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] netlink: Use rhashtable walk iterator
Date: Thu, 5 Feb 2015 00:25:17 +0000
Message-ID: <20150205002517.GA1685@casper.infradead.org>
References: <20150203203213.GA23177@gondor.apana.org.au>
 <E1YIkA0-00063W-Hi@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45866 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965686AbbBEAZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 19:25:20 -0500
Content-Disposition: inline
In-Reply-To: <E1YIkA0-00063W-Hi@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/15 at 07:33am, Herbert Xu wrote:
> This patch gets rid of the manual rhashtable walk in netlink
> which touches rhashtable internals that should not be exposed.
> It does so by using the rhashtable iterator primitives.
> 
> In fact the existing code was very buggy.  Some sockets weren't
> shown at all while others were shown more than once.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I tested these patches. Only thing I found are these sparse
warnings:

net/netlink/af_netlink.c:2893:12: warning: context imbalance in 'netlink_walk_start' - different lock contexts for basic block
net/netlink/af_netlink.c:2907:13: warning: context imbalance in 'netlink_walk_stop' - unexpected unlock
