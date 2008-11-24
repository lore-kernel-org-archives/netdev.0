From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: FYI - TCP/IP thin stream latency
Date: Mon, 24 Nov 2008 16:00:16 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0810290125300.7092@wrl-59.cs.helsinki.fi>
References: <20081016095518.749ae6e9@speedy> <20081022.221410.139436406.davem@davemloft.net>
 <Pine.LNX.4.64.0810231516220.7072@wrl-59.cs.helsinki.fi>
 <20081028.154814.179119403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, doug.leith@nuim.ie,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44981 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbYKXOAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:00:18 -0500
In-Reply-To: <20081028.154814.179119403.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0811241554531.28566@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'll post this rexmit combining again along with the other
tcp changes... Commenting your concerns below.

On Tue, 28 Oct 2008, David Miller wrote:

> Small error:
> 
> > +static int tcp_can_collapse(struct sock *sk, struct sk_buff *skb)
> > +{
> > +	if (tcp_skb_pcount(skb) > 1)
> > +		return 0;
> > +	/* Once recombining for SACK completes this check could be made
> > +	 * less strict by reusing those parts.
> > +	 */
> > +	if (skb_shinfo(skb)->nr_frags != 0)
> > +		return 0;
> > +	if (skb_cloned(skb))
> > +		return 0;
> > +	if (skb == tcp_send_head(sk))
> > +		return 0;
> > +	/* Some heurestics for collapsing over SACK'd could be invented */
> > +	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
> > +		return 0;
> > +
> > +	return 1;
> > +}
> 
> For the "skb === tcp_send_head()" test, we're not interested if
> "skb" is equal, but rather whether next_skb is equal.

But that's what's actually happening... We'll terminate the loop
at that skb where it matches without doing any useful work for it,
so I'm just using a different way of "saying" the same as you.

> But the structure looks fine and when you send me a tested version
> of this patch I'll apply it to net-next-2.6, thanks!

Tested along with the other recombining things posting in couple of
minutes.

-- 
 i.
