From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: suppress too verbose messages in
 tcp_send_ack()
Date: Wed, 25 Nov 2015 14:32:38 -0800
Message-ID: <1448490758.24696.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448488250.24696.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <f7t7fl5g2ao.fsf@aconole.bos.csb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Aaron Conole <aconole@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32846 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbbKYWck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 17:32:40 -0500
Received: by pabfh17 with SMTP id fh17so71809453pab.0
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 14:32:40 -0800 (PST)
In-Reply-To: <f7t7fl5g2ao.fsf@aconole.bos.csb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-25 at 17:08 -0500, Aaron Conole wrote:

> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index 7f89e4ba18d1..ead514332ae8 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -776,7 +776,7 @@ static inline int sk_memalloc_socks(void)
> >  
> >  static inline gfp_t sk_gfp_atomic(const struct sock *sk, gfp_t gfp_mask)
> >  {
> > -	return GFP_ATOMIC | (sk->sk_allocation & __GFP_MEMALLOC);
> > +	return gfp_mask | (sk->sk_allocation & __GFP_MEMALLOC);
> >  }
> >  
> 
> Sorry if I'm missing something obvious here, but with a name like
> sk_gfp_atomic, would it make sense to keep the GFP_ATOMIC mask as well?
> Otherwise, what is the _atomic is saying?

Not sure what you suggest.

Are you suggesting I remove GFP_ATOMIC from all callers ?

I am fine with this, but looks more invasive, and who knows, maybe one
caller might want to not use GFP_ATOMIC one day (like : do not attempt
to use reserves)

This sk_gfp_atomic() helper has a misleading name, since all it wanted
was to conditionally OR a caller provided flag (mostly GFP_ATOMIC one)
with __GFP_MEMALLOC for some special sockets.

Should have been sk_gfp_or_memalloc() or something...
