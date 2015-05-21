From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [PATCH 0/7] crypto: Convert all AEAD users to new interface
Date: Thu, 21 May 2015 14:29:10 +0200
Message-ID: <6790442.0xoTQWpjSd@tauon>
References: <20150521103938.GA23035@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150521103938.GA23035@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, 21. Mai 2015, 18:39:39 schrieb Herbert Xu:

Hi Herbert,

>Hi:
>
>This series of patches convert all in-tree AEAD users that I
>could find to the new single SG list interface.  For IPsec it
>also adopts the new explicit IV generator scheme.
>
>To recap, the old AEAD interface takes an associated data (AD)
>SG list in addition to the plain/cipher text SG list(s).  That
>forces the underlying AEAD algorithm implementors to try to stitch
>those two lists together where possible in order to maximise the
>contiguous chunk of memory passed to the ICV/hash function.  Things
>get even more hairy for IPsec as it has a third piece of memory,
>the generated IV (giv) that needs to be hashed.  One look at the
>nasty things authenc does for example is enough to make anyone
>puke :)
>
>In fact the interface is just getting in our way because for the
>main user IPsec the data is naturally contiguous as the protocol
>was designed with this in mind.
>
>So the new AEAD interface gets rid of the separate AD SG list
>and instead simply requires the AD to be at the head of the src
>and dst SG lists.  There is further provision for optional space
>between the AD and the plain/cipher text for ease of implementation.

Wouldn't algif_aead be also a candiate for the transition? The current 
implementation of aead_recvmsg() splits the one SGL it received from user 
space into two: one for AD and one for the ciphertext.

I would assume that this split now can be completely eliminated by removing 
the for loop in aead_recvmsg entirely.

Ciao
Stephan
