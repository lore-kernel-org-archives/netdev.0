From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 23:20:47 +0200
Message-ID: <20060630212047.GP14627@postel.suug.ch>
References: <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch> <20060630171348.GI14627@postel.suug.ch> <1151701767.5270.289.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:60862 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932950AbWF3VU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 17:20:27 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151701767.5270.289.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-30 17:09
> On Fri, 2006-30-06 at 19:13 +0200, Thomas Graf wrote:
> > Index: net-2.6.git/drivers/net/ifb.c
> > ===================================================================
> > --- net-2.6.git.orig/drivers/net/ifb.c
> > +++ net-2.6.git/drivers/net/ifb.c
> > @@ -158,19 +158,23 @@ static int ifb_xmit(struct sk_buff *skb,
> >  	stats->tx_packets++;
> >  	stats->tx_bytes+=skb->len;
> >  
> > -	if (!from || !skb->input_dev) {
> > +	if (!from || !skb->iif) {
> 
> Can you have something similar to what you did in
> tcf_match_indev above?
> 
> i.e grab dev by skb->iif so as to increment refcount - if it doesnt
> exist it becomes equivalent to !skb->input_dev and if it exists you drop
> the ref inside the else below after changing input_dev 

A non-existant iif is already equivalent to !iif since it jumps
into the same branch. Grabing a reference is completely pointless,
the netdevice represented by skb->iif is at this point until the
packet gets queued covered by a reference taken in netif_rx().
