From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] ipsec: Fix aborted xfrm policy dump crash
Date: Mon, 23 Oct 2017 13:08:50 +0200
Message-ID: <20171023110849.GF3323@secunet.com>
References: <CAHqykcSO0vQvh0uXwDNgXr0ZpP8m4AGZ=ks9FNshJZw0=GWHpw@mail.gmail.com>
 <CANn89iLBO2RzqMzb61Qn=HFncsfYLnXLcUfSqFsDTPakQ2o4FQ@mail.gmail.com>
 <20171017061832.GA3323@secunet.com>
 <CANn89iJmtPQ=HV6xLjTaLS6WnVmiN+PgaObmWWnevcEzLitRTQ@mail.gmail.com>
 <20171018151159.GA5188@gondor.apana.org.au>
 <CANn89iL_QRZUTDXdci+Nsn=oM471N4r6im0zLgHkJANx_X6wbQ@mail.gmail.com>
 <20171019092625.GA12863@gondor.apana.org.au>
 <20171019095704.GA13459@gondor.apana.org.au>
 <20171019143320.00f787bd@vostro.util.wtbts.net>
 <20171019125109.GA13775@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Timo Teras <timo.teras@iki.fi>, Eric Dumazet <edumazet@google.com>,
        <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:55078 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751268AbdJWLIx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Oct 2017 07:08:53 -0400
Content-Disposition: inline
In-Reply-To: <20171019125109.GA13775@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 08:51:10PM +0800, Herbert Xu wrote:
> On Thu, Oct 19, 2017 at 02:33:20PM +0300, Timo Teras wrote:
> >
> > > Fixes: 4c563f7669c1 ("[XFRM]: Speed up xfrm_policy and xfrm_state...")
> > 
> > This is not correct. The original commit works just fine.
> 
> OK, I'll change it.
> 
> > At that time there was no .start which got added just few years ago. I
> > suggest to do the same fix for SA side since it had same issue fixed on
> > the other commit. Your approach with defining the .start is cleaner.
> 
> No we can't use the start on the SA side because as it is start
> is not allowed to fail.
> 
> Thanks,
> 
> ---8<---
> An independent security researcher, Mohamed Ghannam, has reported
> this vulnerability to Beyond Security's SecuriTeam Secure Disclosure
> program.
> 
> The xfrm_dump_policy_done function expects xfrm_dump_policy to
> have been called at least once or it will crash.  This can be
> triggered if a dump fails because the target socket's receive
> buffer is full.
> 
> This patch fixes it by using the cb->start mechanism to ensure that
> the initialisation is always done regardless of the buffer situation.
> 
> Fixes: 12a169e7d8f4 ("ipsec: Put dumpers on the dump list")
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot Herbert!
