From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] act_nat: fix the wrong checksum when addr isn't in
	old_addr/mask
Date: Sun, 30 May 2010 22:58:11 +1000
Message-ID: <20100530125811.GA8120@gondor.apana.org.au>
References: <1275179219-10424-1-git-send-email-xiaosuo@gmail.com> <1275223421.3587.0.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:48326 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752569Ab0E3M62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 08:58:28 -0400
Content-Disposition: inline
In-Reply-To: <1275223421.3587.0.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 30, 2010 at 08:43:41AM -0400, jamal wrote:
> 
> Copying Herbert, taking linux-kernel off...

Thanks Jamal.

> On Sun, 2010-05-30 at 08:26 +0800, Changli Gao wrote:
> > fix the wrong checksum when addr isn't in old_addr/mask
> > 
> > For TCP and UDP packets, when addr isn't in old_addr/mask we don't do SNAT or
> > DNAT, and we should not update layer 4 checksum.
> > 
> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> > ----
> >  net/sched/act_nat.c |    4 ++++
> >  1 file changed, 4 insertions(+)
> > diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
> > index d885ba3..5709494 100644
> > --- a/net/sched/act_nat.c
> > +++ b/net/sched/act_nat.c
> > @@ -159,6 +159,9 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
> >  			iph->daddr = new_addr;
> >  
> >  		csum_replace4(&iph->check, addr, new_addr);
> > +	} else if ((iph->frag_off & htons(IP_OFFSET)) ||
> > +		   iph->protocol != IPPROTO_ICMP) {
> > +		goto out;
> >  	}

Yes the patch is correct.

However, the fact that you need this patch means that your act_nat
setup isn't perfect.  Ideally all the unNATed packets should be
filtered out before you hit act_nat.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
