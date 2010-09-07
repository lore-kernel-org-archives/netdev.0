From: Miloslav Trmac <mitr@redhat.com>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 10:52:03 -0400 (EDT)
Message-ID: <695962299.1087031283871123333.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
References: <834983542.1086561283871074929.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:51052 "EHLO
	mx02.colomx.prod.int.phx2.redhat.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751830Ab0IGOwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 10:52:07 -0400
In-Reply-To: <834983542.1086561283871074929.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- "Herbert Xu" <herbert@gondor.hengli.com.au> wrote:
> On Tue, Sep 07, 2010 at 10:34:25AM -0400, Miloslav Trmac wrote:
> >
> > > > > 	/* These may also be set through sendmsg(2) cmsgs. */
> > > > > 	op = ALG_AEAD_OP_ENCRYPT;
> > > > > 	setsockopt(opfd, SOL_ALG, ALG_AEAD_OP, op, sizeof(op));
> > > > > 	setsockopt(opfd, SOL_ALG, ALG_AEAD_SET_IV, iv, ivlen);
> > > > So that is 8 syscalls to initialize a single AEAD operation.
> > > 
> > > If this interface is fast enough for TCP, it ought to be fast
> > > enough for crypto.
> > Crypto has much smaller granularity than TCP.  A single TLS
> handshake involves something on the order of 20 separate crypto
> operations in addition to setting up the four transforms used
> throughout the life of the session.
> > 
> > A single SHA-256 password verification is more than 5000 hash
> operations by default.
> 
> If you're processing a small amount of data the last thing you want
> is to go through the kernel if you care about performance.
> 
> Now on the other hand if you had to go through the kernel for
> certification reasons then why are you talking about performance?

Because in the real world people want both certification, features _and_ performance.  If all they cared about is certification they could just as well buy a pencil.
     Mirek
