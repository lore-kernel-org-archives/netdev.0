From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Mon, 28 Feb 2011 12:26:20 +0800
Message-ID: <20110228042620.GA16224@gondor.apana.org.au>
References: <20110225.112019.48513284.davem@davemloft.net> <20110226005718.GA19889@gondor.apana.org.au> <20110227110205.GE9763@canuck.infradead.org> <20110227110614.GA6246@gondor.apana.org.au> <AANLkTinxv4JC20YepcMvWi8SL_VTX2sXcRMydD62TT6x@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	wsommerfeld@google.com, daniel.baluta@gmail.com,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:34893 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252Ab1B1E0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 23:26:34 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTinxv4JC20YepcMvWi8SL_VTX2sXcRMydD62TT6x@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 27, 2011 at 07:45:55PM -0800, Tom Herbert wrote:
> That sounds promising, but receive side will still have problems.
> There is lock contention on the queue as well as cache line bouncing
> on the sock structures.  Also multiple threads sleeping on same socket
> typically leads to asymmetric load across the threads (and
> degenerative cases where receiving thread is woken up and other
> threads have already processed all the packets).  TCP listener threads
> suffer from these same problems.

IOW this is something that we have to solve anyway.  I'm just
being overly cautious here because user-space API changes are
something that we should not enter into lightly.

If this patch was completely internal to the kernel, then I would
have much less of an objection as we can always revert/change it
later on.  With a user-space API we don't have that flexibility.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
