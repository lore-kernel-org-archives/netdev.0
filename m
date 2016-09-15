From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix overflow in __tcp_retransmit_skb()
Date: Thu, 15 Sep 2016 09:35:29 -0700
Message-ID: <1473957329.22679.52.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473952353.22679.25.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DB00FDAFC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33764 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751827AbcIOQfa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 12:35:30 -0400
Received: by mail-pf0-f196.google.com with SMTP id 128so2416121pfb.0
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 09:35:30 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB00FDAFC@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-15 at 15:52 +0000, David Laight wrote:
> From: Eric Dumazet
> > Sent: 15 September 2016 16:13
> > If a TCP socket gets a large write queue, an overflow can happen
> > in a test in __tcp_retransmit_skb() preventing all retransmits.
> ...
> >  	if (atomic_read(&sk->sk_wmem_alloc) >
> > -	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
> > +	    min_t(u32, sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2),
> > +		  sk->sk_sndbuf))
> >  		return -EAGAIN;
> 
> Might it also be better to split that test to (say):
> 
> 	u32 wmem_alloc = atomic_read(&sk->sk_wmem_alloc);
> 	if (unlikely((wmem_alloc > sk->sk_sndbuf))
> 		return -EAGAIN;
> 	if (unlikely(wmem_alloc > sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2)))
> 		return -EAGAIN;

Well, I find the existing code more readable, but this is just an
opinion.

Thanks.
