From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 17 Jan 2005 17:36:26 -0500
Message-ID: <1106001385.1036.7.camel@jzny.localdomain>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
	 <1105363092.1041.146.camel@jzny.localdomain>
	 <1105917038.1091.1041.camel@jzny.localdomain>
	 <200501171404.19451.hasso@estpak.ee> <41EC3680.7060108@tpack.net>
	 <41EC3894.9090304@pantasys.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tommy Christensen <tommy.christensen@tpack.net>,
        Hasso Tepper <hasso@estpak.ee>, Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Buckingham <peter@pantasys.com>
In-Reply-To: <41EC3894.9090304@pantasys.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi there,

The solution that Tommy and myself have been batting around is a lot
more cleaner than this (however still doesnt solve the issue 100%)

cheers,
jamal

On Mon, 2005-01-17 at 17:13, Peter Buckingham wrote:
> Hi,
> 
> Tommy Christensen wrote:
> > A proper solution would take care of both these issues: "stale packets"
> > and "socket blocking". They are pretty much related.
> > 
> > Using a socket for each interface *ought* not be needed.
> > Carrier detection sounds like a good thing in its own right.
> 
> I came across this same problem with multicast/unicast with an e1000. 
> For a quick hack we just check to see whether the carrier is ok, if it's 
> not we just drop the packet. this might do some nasty things with tcp 
> and it may be better to check to see wither the socket buffer is full, 
> but this works for me here... (this is against a 2.6.9ish kernel)
> 
> peter
> 
> Index: net/core/dev.c
> ===================================================================
> --- net/core/dev.c
> +++ net/core/dev.c
> @@ -1379,6 +1379,11 @@
>   #ifdef CONFIG_NET_CLS_ACT
>   	skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
>   #endif
> +	if (!netif_carrier_ok(dev)) {
> +		rc = NET_XMIT_DROP;
> +		goto out_kfree_skb;
> +	}
> +
>   	if (q->enqueue) {
>   		/* Grab device queue */
>   		spin_lock(&dev->queue_lock);
> 
> 
