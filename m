From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] eth_type_trans() can access stale data
Date: Thu, 16 Jan 2014 12:15:45 -0800
Message-ID: <1389903345.31367.424.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389743541.31367.279.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140115.154805.1403628531019301276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:61267 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbaAPUPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 15:15:48 -0500
Received: by mail-yh0-f44.google.com with SMTP id f73so204812yha.3
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 12:15:48 -0800 (PST)
In-Reply-To: <20140115.154805.1403628531019301276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 15:48 -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 14 Jan 2014 15:52:21 -0800
> 
> > @@ -194,7 +194,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
> >  	 *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
> >  	 *      won't work for fault tolerant netware but does for the rest.
> >  	 */
> > -	if (unlikely(skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF))
> > +	if (unlikely(skb_headlen(skb) >= 2 &&
> > +		     *(unsigned short *)(skb->data) == 0xFFFF))
> >  		return htons(ETH_P_802_3);
> 
> I think using skb_header_pointer() will essentially have the same cost,
> why not use it instead?

Yes, we can try this, I'll send a patch, thanks.
