From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 4/x: [NETDRV] Merge register_netdev calls
Date: Fri, 11 Jun 2004 12:08:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040611020855.GA5480@gondor.apana.org.au>
References: <20040313025859.GA8186@gondor.apana.org.au> <405C294D.5040508@pobox.com> <20040520111937.GA21804@gondor.apana.org.au> <20040522074435.GA9628@gondor.apana.org.au> <20040529084109.GA13032@gondor.apana.org.au> <40BE3778.1020404@pobox.com> <20040605052737.GA27406@gondor.apana.org.au> <40C8F824.50904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40C8F824.50904@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 10, 2004 at 08:09:08PM -0400, Jeff Garzik wrote:
> 
> Unfortunately this and patch #5 are moving in the opposition direction 
> from what we want to be doing, I think.
> 
> AFAICS these patches move register_netdev() to points in each driver 
> earlier in the probe phase, when the driver is not fully set up and 
> ready to receive packets.
> 
> Am I missing something?

The only change made by these two patches is moving the call to
register_netdev() from the outer probe() function to the inner
probe() function where the the printk's are.

There is absolutely no code in between the two locations.  That is,
the driver would've immediately called register_netdev after the inner
probe() has succeeded.

In fact it's really making these ISA/MCA probe() functions more
like the ones we have for PCI.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
