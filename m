From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 3/6] flow_dissector: Add hash_extra field to
 flow_keys struct
Date: Sat, 28 Feb 2015 21:31:19 +0100
Message-ID: <20150228203119.GA7687@breakpoint.cc>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
 <1425093109-1077-4-git-send-email-therbert@google.com>
 <1425109054.5130.77.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50520 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751714AbbB1UbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 15:31:23 -0500
Content-Disposition: inline
In-Reply-To: <1425109054.5130.77.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2015-02-27 at 19:11 -0800, Tom Herbert wrote:
> 
> > diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> > index c605d30..d41a034 100644
> > --- a/include/net/sch_generic.h
> > +++ b/include/net/sch_generic.h
> > @@ -252,7 +252,7 @@ struct qdisc_skb_cb {
> >  	unsigned int		pkt_len;
> >  	u16			slave_dev_queue_mapping;
> >  	u16			_pad;
> > -#define QDISC_CB_PRIV_LEN 20
> > +#define QDISC_CB_PRIV_LEN 24
> >  	unsigned char		data[QDISC_CB_PRIV_LEN];
> >  };
> >  
> 
> This change breaks kernel build : We already are at the cb[] limit.
> 
> Please check commit 257117862634d89de33fec74858b1a0ba5ab444b
> ("net: sched: shrink struct qdisc_skb_cb to 28 bytes")

I've been toying around with reducing skb->cb[] to 44 bytes,
Seems Tom could integrate following patch from my test branch:

http://git.breakpoint.cc/cgit/fw/net-next.git/commit/?h=skb_cb_44_01&id=29d711e1a71244b71940c2d1e346500bef4d6670

It makes sfq use a smaller flow key state.
