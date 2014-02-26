From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Support for ECDH P-192 and P-256
Date: Thu, 27 Feb 2014 06:03:33 +0800
Message-ID: <20140226220333.GA28414@gondor.apana.org.au>
References: <88CA6BC5-E6E7-43C3-8A2A-829D27E76CE8@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40379 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbaBZWDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 17:03:45 -0500
Content-Disposition: inline
In-Reply-To: <88CA6BC5-E6E7-43C3-8A2A-829D27E76CE8@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann <marcel@holtmann.org> wrote:
> Hello,
> 
> we are looking at adding support for Bluetooth Secure Connections to the Security Manager of the Bluetooth subsystem. For that we would need support for ECDH P-256 and eventually also P-192.
> 
> Right now we are bit lost on how this could be achieved best. I saw that the symmetric_keys feature has support for public_keys, but as far as I can tell that requires that userspace loads the public keys into the kernel and the private keys stay in userspace.
> 
> What we need is to generate private/public key pairs using elliptic curve with P-192 and P-256. We only need the private/public key pair for the Bluetooth pairing. After successful pairing, we derive link keys or long term keys and we can throw the private/public key pair away. Any further authentication between Bluetooth devices is done via their link keys or long term keys.
> 
> Has anybody looked into extending the kernel crypto framework to support ECDH P-192 and P-256. If nobody has, what are the best starting points to do so.

Normally key exchange is conducted in user-space because it isn't
performance-critical so as not to bloat the kernel.  For example,
only the data-path of IPsec is implemented in the kernel, while
the key exchange protocol IKE Is done in user-space.  That's why
there is no current support for key exchange-related algorithms
in the kernel crypto API.

If there is agreement that Bluetooth's key exchange must be done
in the kernel, then we certainly start adding these algorithms.

I haven't been following this but is there a consensus from the
networking folks regarding Bluetooth's key exchange code?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
