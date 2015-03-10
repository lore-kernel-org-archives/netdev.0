From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linux-next: build warnings after merge of the crypto tree
Date: Tue, 10 Mar 2015 17:03:28 +1100
Message-ID: <20150310060328.GA14997@gondor.apana.org.au>
References: <20150310164417.540c18a4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephan Mueller <smueller@chronox.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150310164417.540c18a4@canb.auug.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 10, 2015 at 04:44:17PM +1100, Stephen Rothwell wrote:
> Hi Herbert,
> 
> After merging the crypto tree, today's (and the past few days)
> linux-next build (powerpc allyesconfig) produced these warnings:
> 
> crypto/algif_aead.c:561:2: warning: initialization from incompatible pointer type
>   .sendmsg = aead_sendmsg,
>   ^
> crypto/algif_aead.c:561:2: warning: (near initialization for 'algif_aead_ops.sendmsg')
> crypto/algif_aead.c:563:2: warning: initialization from incompatible pointer type
>   .recvmsg = aead_recvmsg,
>   ^
> crypto/algif_aead.c:563:2: warning: (near initialization for 'algif_aead_ops.recvmsg')
> 
> Introduced by commit 400c40cf78da ("crypto: algif - add AEAD support").

This is a bit of a bummer.  What happened is that net-next has
killed the kiocb argument to sendmsg/recvmsg.  However, this
change is obviously not part of the crypto tree and algif_aead
only exists in the crypto tree.

So Stephen could you fix this by hand until one of them is merged
upstream (just kill the first argument in aead_sendmsg/aead_recvmsg)?

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
