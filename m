From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TSO + e1000
Date: Mon, 06 Dec 2004 12:26:26 +1100
Message-ID: <E1Cb7dy-000588-00@gondolin.me.apana.org.au>
References: <20041205232226.GA5757@krispykreme.ozlabs.ibm.com>
Cc: netdev@oss.sgi.com, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com, john.ronciak@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: anton@samba.org (Anton Blanchard)
In-Reply-To: <20041205232226.GA5757@krispykreme.ozlabs.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Anton Blanchard <anton@samba.org> wrote:
> 
> 1. tcpdump doesnt report local TSO packets, it simply prints bad-len. I
> think this is because the e1000 driver is zeroing out the IP header
> length in e1000_tso:
> 
>        skb->nh.iph->tot_len = 0;
> 
> Does the card require this for TSO to operate? Ive worked around it in 
> tcpdump for the time being.

This is a bug in e1000.  Even if it is required it isn't allowed to
modify a cloned packet.  It'll need to copy it so that other clone
users aren't affected.
 
> Now if we do a single direction test it takes forever for TSO to kick
> in. At the moment Im not sure why this is happening, tcp_current_mss
> seems to grow correctly in both cases. Is there somewhere else we are
> capping TSO packets?

What call does your application use to do the sending?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
