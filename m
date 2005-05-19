From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Ethernet Bridging: Enable Hardware Checksumming
Date: Thu, 19 May 2005 12:41:07 +1000
Message-ID: <E1DYayB-0005Sk-00@gondolin.me.apana.org.au>
References: <20050518235329.GA17946@us.ibm.com>
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jdmason@us.ibm.com (Jon Mason)
In-Reply-To: <20050518235329.GA17946@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> wrote:
> 
> checksum and scatter gather as features of the bridge device.  In the 
> case that the physical ethernet device does not support scatter 
> gather or hardware checksum, dev_queue_xmit() will check the
> dev->features and do the necessary linearization and calculate the
> checksum.

Unfortunately skb_linearize is a lot more expensive than not
generating the non-linear skb's in the first place.

So this is going to hurt people using the bridge devices over
physical devices that don't support SG.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
