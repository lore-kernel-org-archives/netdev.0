From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [7/7] [IPSEC] Add XFRMA_SA/XFRMA_POLICY for delete notification
Date: Sun, 8 May 2005 05:35:38 +1000
Message-ID: <20050507193538.GA28991@gondor.apana.org.au>
References: <20050507071824.GA5753@gondor.apana.org.au> <20050507071930.GC5753@gondor.apana.org.au> <20050507072058.GD5753@gondor.apana.org.au> <20050507072139.GE5753@gondor.apana.org.au> <20050507072216.GF5753@gondor.apana.org.au> <20050507072251.GG5753@gondor.apana.org.au> <20050507072349.GH5753@gondor.apana.org.au> <1115467457.19561.5.camel@localhost.localdomain> <20050507122504.GA21693@gondor.apana.org.au> <1115470004.19561.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115470004.19561.49.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, May 07, 2005 at 08:46:44AM -0400, jamal wrote:
> 
> No, this is not true. Study the tc code.
> It is nice to be able to return exactly the same detail - user space can
> then infer what exactly happened. It is nicer to be able to return more
> detail because user space doesnt have to infer anything.

This patch is making it return more detail, not less! The full
description of the deleted policy/state is still being returned,
albeit as RTA payloads.

Prior to the change, netlink users do not know whether the original
policy delete request was by selector or by id.  Now that information
is also returned.

> You describe the patch this way
> 
> ---
> This patch changes the format of the XFRM_MSG_DELSA and
> XFRM_MSG_DELPOLICY notification so that the main message
> sent is of the same format as that received by the kernel
> if the original message was via netlink.
> ----
> 
> That it only happens when you delete via netlink. Is this not so?

The same change applies even if you sent the delete via pfkey.  What
the change does is to make netlink always send a delete message that
is valid in the sense that if you sent it back to netlink then it
would delete that policy/state.

As it is the netlink delete messages sent by notification are invalid
by its own standard.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
