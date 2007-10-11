From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: skb_clone SMP race?
Date: Thu, 11 Oct 2007 10:06:57 +0800
Message-ID: <E1IfnRx-0003Vu-00@gondolin.me.apana.org.au>
References: <dfad5c650710100200s1369fd96x50ffc5fbffb2e6d9@mail.gmail.com>
Cc: netdev@vger.kernel.org
To: sfa.linux@gmail.com (Santiago Font Arquer)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4557 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755397AbXJKCHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 22:07:02 -0400
In-Reply-To: <dfad5c650710100200s1369fd96x50ffc5fbffb2e6d9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Santiago Font Arquer <sfa.linux@gmail.com> wrote:
>
>   If an skb with fast clone available (first "if" true) has
> references in different CPUs (skb->users>1) (I do not find explicit
> checks for this to be impossible), if skb_clone is called
> simultaneously over that skb, both callers can get the same clone (the
> "fast" clone) and different problems follow: wrong "clone_skb->users"
> (1 as expected by the caller, but it should be, to be true, 2),
> fclone_ref set to 3 involving further problems, ...

Fast clones are only used by TCP where the original skb is
never given to the outside world.  This plus the fact that
a given TCP socket is single-threaded makes it safe.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
