From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv3 net-next-2.6 3/5] XFRM,IPv6: Add IRO src/dst address
	remapping XFRM types and i/o handlers
Date: Sun, 3 Oct 2010 23:12:02 +0800
Message-ID: <20101003151202.GA11963@gondor.apana.org.au>
References: <cover.1285749610.git.arno@natisbad.org> <fd4eec3c9486c46b535e89ceed479c7536f51fb9.1285749610.git.arno@natisbad.org> <20100929.201618.241458205.davem@davemloft.net> <87iq1k99vk.fsf@small.ssi.corp> <20101002103205.GA3879@gondor.apana.org.au> <87iq1j5r7z.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47085 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904Ab0JCPMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 11:12:17 -0400
Content-Disposition: inline
In-Reply-To: <87iq1j5r7z.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 03, 2010 at 03:41:04PM +0200, Arnaud Ebalard wrote:
>
> After your reply, I took a (too long) look at the history of
> xfrm6_input_addr() to understand why it is as it is. If it can spare you
> some time, here is what I think happened:

...

>  - Then, as you wrote, the state lock was moved in all input handlers
>    (commit 0ebea8ef, Nov 13 2007), including RH2/HAO ones:

...

>    With that commit, I think a deadlock was introduced in MIPv6 code
>    because xfm6_input_addr() was left unchanged, i.e. x->type->input()
>    was called with the lock held. Am I correct?
> 
>  - The code of xfrm6_input_addr() was then optimized by commit a002c6fd
>    in such a way that x->type->input() was then put outside the
>    protection of the lock, which (if I am not mistaken) removed the
>    deadlock: 

...

>    I don't know if this is was intentional.

Indeed MIPv6 was completely out of action for three months and
nobody noticed :)

>    But the main question remains on the position of the lock. Here,
>    checks are done on the status of the state, lock is released,
>    reacquired in the input handler to do additional check and then
>    released again, to be reacquired later in the function to act on
>    statistics. Is my reading of the code correct?

When I moved the lock down I chose the safest option and added
it to every single input function.  So it may well be the case
that the lock isn't needed at all on the MIPv6 path.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
