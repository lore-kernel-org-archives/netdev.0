From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Sat, 9 Apr 2005 10:31:08 +1000
Message-ID: <20050409003108.GA21962@gondor.apana.org.au>
References: <20050408221629.GA21125@gondor.apana.org.au> <200504082356.j38Ntr7k010144@death.nxdomain.ibm.com> <20050409002137.GA21726@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20050409002137.GA21726@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Apr 09, 2005 at 10:21:37AM +1000, herbert wrote:
> 
> Personally I'd rather we aimed for a proper solution that will be in
> 2.6.13 since the current symptom is only a warning which doesn't
> really hurt anyone.

Actually there is another reason why we need to move the MAC setting
to process context rather than simply patching up the rtnetlink code.

The driver implementation for set_mac_address may well want to sleep
since it needs to communicate with the hardware.

In fact I just looked at some USB net drivers and the very first one
(zd1201) wants to sleep in there badly :)

So if you want a quick and dirty fix, why not make bonding call
dev_set_mac_address from a work queue?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
