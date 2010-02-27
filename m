From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/13] bridge: Allow tail-call on br_pass_frame_up
Date: Sat, 27 Feb 2010 23:36:07 +0800
Message-ID: <20100227153607.GA3176@gondor.apana.org.au>
References: <20100226153410.GA26419@gondor.apana.org.au> <E1Nl2Db-0006v3-21@gondolin.me.apana.org.au> <20100227.031451.21192400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59159 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S968435Ab0B0PgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 10:36:12 -0500
Content-Disposition: inline
In-Reply-To: <20100227.031451.21192400.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 27, 2010 at 03:14:51AM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 26 Feb 2010 23:35:07 +0800
> 
> > @@ -20,9 +20,9 @@
> >  /* Bridge group multicast address 802.1d (pg 51). */
> >  const u8 br_group_address[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
> >  
> > -static void br_pass_frame_up(struct net_bridge *br, struct sk_buff *skb)
> > +static int br_pass_frame_up(struct sk_buff *skb)
> >  {
> > -	struct net_device *indev, *brdev = br->dev;
> > +	struct net_device *indev, *brdev = BR_INPUT_SKB_CB(skb)->brdev;
> >  
> 
> You use this new BR_INPUT_SKB_CB() here in patch #2, but you only
> start setting ->brdev it in patch #4.

Actually this patch does work as is.  The brdev setting in #4 is
for the bridge device's local xmit path.  br_pass_frame_up is not
used on the local xmit path (since that would create a packet loop).

It's only used for packets originating from bridge ports, where
patch #2 ensures that BR_INPUT_SKB_CB is set correctly.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
