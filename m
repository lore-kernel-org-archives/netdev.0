From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 15:03:26 +0300
Message-ID: <4BB0970E.7060405@iki.fi>
References: <20100329084018.GA22547@gondor.apana.org.au> <4BB06C36.9060105@iki.fi> <20100329090927.GA22899@gondor.apana.org.au> <4BB07BF6.6000505@iki.fi> <20100329102639.GA23414@gondor.apana.org.au> <4BB082B8.9030400@iki.fi> <20100329111025.GA23927@gondor.apana.org.au> <4BB08D96.8090909@iki.fi> <20100329113225.GA24159@gondor.apana.org.au> <4BB09178.8050501@iki.fi> <20100329115701.GA24367@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f222.google.com ([209.85.219.222]:65350 "EHLO
	mail-ew0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943Ab0C2MDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 08:03:32 -0400
Received: by ewy22 with SMTP id 22so1787416ewy.37
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 05:03:31 -0700 (PDT)
In-Reply-To: <20100329115701.GA24367@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> I'm not talking about the flow cache.  The current flow cache
> code doesn't even take the lock.
>
> I'm talking about the other places that you have to convert in
> order to make this into an atomic_t.

Did you check the other places?

All other places do:
  fox x policies:
    lock(x)
    pol_dead |= x->walk.dead;
    unlock(x)
  if pol_dead
    abort

or similar.

And some cases don't even bother to lock the policy currently
when reading walk.dead.

All of the code treats the walk.dead as a hint. It does not need
strong synchronization with a lock.
