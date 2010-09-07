From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 22:41:36 +0800
Message-ID: <20100907144136.GB7448@gondor.apana.org.au>
References: <1847066281.1081601283869883727.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com> <421339997.1082251283870065826.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Miloslav Trmac <mitr@redhat.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <421339997.1082251283870065826.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 07, 2010 at 10:34:25AM -0400, Miloslav Trmac wrote:
>
> > > > 	/* These may also be set through sendmsg(2) cmsgs. */
> > > > 	op = ALG_AEAD_OP_ENCRYPT;
> > > > 	setsockopt(opfd, SOL_ALG, ALG_AEAD_OP, op, sizeof(op));
> > > > 	setsockopt(opfd, SOL_ALG, ALG_AEAD_SET_IV, iv, ivlen);
> > > So that is 8 syscalls to initialize a single AEAD operation.
> > 
> > If this interface is fast enough for TCP, it ought to be fast
> > enough for crypto.
> Crypto has much smaller granularity than TCP.  A single TLS handshake involves something on the order of 20 separate crypto operations in addition to setting up the four transforms used throughout the life of the session.
> 
> A single SHA-256 password verification is more than 5000 hash operations by default.

You're clearly one of those crazy security people.

If you're processing a small amount of data the last thing you want
is to go through the kernel if you care about performance.

Now on the other hand if you had to go through the kernel for
certification reasons then why are you talking about performance?

> The data will in the usual case be in user-space memory, not in file descriptors.  Existing low-level crypto libraries have no access to the file descriptors that are used to work with the data.  And even in the case of TLS where the data does come through a file descriptor, a MAC is then computed on it - so at most half of the (steady-state) crypto is coming through a file descriptor.

man vmsplice

Also learn to wrap your lines please.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
