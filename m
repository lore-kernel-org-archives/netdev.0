From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v3] tcp: splice as many packets as possible at once
Date: Tue, 27 Jan 2009 07:54:18 +0000
Message-ID: <20090127075418.GB4197@ff.dom.local>
References: <20090125.212203.15909648.davem@davemloft.net> <20090127071130.GA29125@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:6096 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbZA0HyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 02:54:25 -0500
Content-Disposition: inline
In-Reply-To: <20090127071130.GA29125@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 06:11:30PM +1100, Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Thu, 22 Jan 2009 09:04:42 +0000
> > 
> >> It seems this sk_sndmsg_page usage (refcounting) isn't consistent.
> >> I used here tcp_sndmsg() way, but I think I'll go back to this question
> >> soon.
> > 
> > Indeed, it is something to look into, as well as locking.
> > 
> > I'll try to find some time for this, thanks Jarek.
> 
> After a quick look it seems to be OK to me.  The code in the patch
> is called from tcp_splice_read, which holds the socket lock.  So as
> long as the patch uses the usual TCP convention it should work.

Yes, but ip_append_data() (and skb_append_datato_frags() for
NETIF_F_UFO only, so currently not a problem), uses this differently,
and these pages in sk->sk_sndmsg_page could leak or be used after
kfree. (I didn't track locking in these other places).

Thanks,
Jarek P.
