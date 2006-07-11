From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Netchannel: default, find, add to socket
Date: Tue, 11 Jul 2006 09:57:08 +0400
Message-ID: <20060711055708.GA3935@2ka.mipt.ru>
References: <200607111539.25458.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:12009 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932314AbWGKF5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 01:57:23 -0400
To: Kelly Daly <kelly@au1.ibm.com>
Content-Disposition: inline
In-Reply-To: <200607111539.25458.kelly@au.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 11, 2006 at 03:39:25PM +1000, Kelly Daly (kelly@au1.ibm.com) wrote:
> Implement finding of correct netchannel for buffer, default netchannel and 
> attach a netchannel to a socket
> 
> Signed-off-by:  Kelly Daly <kelly@au.ibm.com>

Hi Kelly.

You have a typo in the code commented below.
I have a question regarsing your netchannel design - as far as I can
see, you steal data in interrupts and then convert it into skb and run
through usual netif_receive_skb(). Thus you dedicate one thread (one
CPU) to do the whole processing for all sockets which do not have
netchannels bound to them. Did you benchmarked such approach both with
and without netchannel bound to the socket?

> +/* Find the channel for a packet, or return default channel. */
> +struct netchannel *find_netchannel(const struct netchannel_buftrailer *bp)
> +{
> +	struct sock *sk = NULL;
> +	int datalen = netchan_data_len(bp);
> +
> +	switch (bp->netchan_buf_proto) {
> +	case __constant_htons(ETH_P_IP): {
> +		struct iphdr *ip = (void *)bp - datalen;
> +		int iphl = ip->ihl * 4;
> +
> +		/* FIXME: Do sanity checks, parse packet. */
> +
> +		if (datalen >+ (iphl + 4) && iphl == sizeof(struct iphdr)) {

A typo ">+" instead of ">=".

-- 
	Evgeniy Polyakov
