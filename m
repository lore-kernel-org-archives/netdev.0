From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Seperate DSACK from SACK fast path
Date: Sun, 28 Jan 2007 21:28:51 -0800 (PST)
Message-ID: <20070128.212851.31444923.davem@davemloft.net>
References: <20070128052704.GH22455@galon.ev-en.org>
	<E1HBOiV-0007bt-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57019
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933136AbXA2F2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 00:28:53 -0500
In-Reply-To: <E1HBOiV-0007bt-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 29 Jan 2007 16:06:07 +1100

> Baruch Even <baruch@ev-en.org> wrote:
> >> 
> >> > Since the SACK receive cache doesn't need the data to be in host
> >> > order we also remove the ntohl in the checking loop.
> >>  ...
> >> > -   for (i = 0; i< num_sacks; i++) {
> >> > -           __u32 start_seq = ntohl(sp[i].start_seq);
> >> > -           __u32 end_seq =  ntohl(sp[i].end_seq);
> >> > +   for (i = 0; i < num_sacks; i++) {
> >> > +           __u32 start_seq = sp[i].start_seq;
> >> > +           __u32 end_seq = sp[i].end_seq;
> > 
> > Yes. The only comparison we do with recv_sack_cache entries is != and
> > that works for net-endian just fine.
> 
> In that case you need to use __be32 before Al Viro starts coming after
> you :)

Good catch, Baruch please fix this up :-)
