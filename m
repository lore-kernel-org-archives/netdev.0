From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent,
 and testmgr build issues
Date: Thu, 24 Jan 2013 10:43:37 +0100
Message-ID: <20130124094337.GJ9147@secunet.com>
References: <1776726593.108228.1358952383104.JavaMail.root@elliptictech.com>
 <20130123173510.14986sla4qsstz8k@www.dalek.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom St Denis <tstdenis@elliptictech.com>,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130123173510.14986sla4qsstz8k@www.dalek.fi>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 23, 2013 at 05:35:10PM +0200, Jussi Kivilinna wrote:
> 
> Problem seems to be that PFKEYv2 does not quite work with IKEv2, and
> XFRM API should be used instead. There is new numbers assigned for
> IKEv2: https://www.iana.org/assignments/ikev2-parameters/ikev2-parameters.xml#ikev2-parameters-7
> 
> For new SADB_X_AALG_*, I'd think you should use value from "Reserved
> for private use" range. Maybe 250?

This would be an option, but we have just a few slots for private
algorithms.

> 
> But maybe better solution might be to not make AES-CMAC (or other
> new algorithms) available throught PFKEY API at all, just XFRM?
> 

It is probably the best to make new algorithms unavailable for pfkey
as long as they have no official ikev1 iana transform identifier.

But how to do that? Perhaps we can assign SADB_X_AALG_NOPFKEY to
the private value 255 and return -EINVAL if pfkey tries to register
such an algorithm. The netlink interface does not use these
identifiers, everything should work as expected. So it should be
possible to use these algoritms with iproute2 and the most modern
ike deamons.
