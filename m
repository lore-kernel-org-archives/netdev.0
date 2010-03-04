From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [rfc/rft][patch] should use scheduler sync hint in
 tcp_prequeue()?
Date: Thu, 4 Mar 2010 04:03:00 +0100
Message-ID: <20100304030300.GE23633@elte.hu>
References: <1267522901.25906.101.camel@marge.simson.net>
 <1267529273.2964.111.camel@edumazet-laptop>
 <20100303.060529.195713861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, efault@gmx.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:35819 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752032Ab0CDDDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 22:03:11 -0500
Content-Disposition: inline
In-Reply-To: <20100303.060529.195713861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 02 Mar 2010 12:27:53 +0100
> 
> > Le mardi 02 mars 2010 ? 10:41 +0100, Mike Galbraith a ?crit :
> >> diff --git a/include/net/tcp.h b/include/net/tcp.h
> >> index 34f5cc2..ba3fc64 100644
> >> --- a/include/net/tcp.h
> >> +++ b/include/net/tcp.h
> >> @@ -939,7 +939,7 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
> >>  
> >>  		tp->ucopy.memory = 0;
> >>  	} else if (skb_queue_len(&tp->ucopy.prequeue) == 1) {
> >> -		wake_up_interruptible_poll(sk->sk_sleep,
> >> +		wake_up_interruptible_sync_poll(sk->sk_sleep,
> >>  					   POLLIN | POLLRDNORM | POLLRDBAND);
> >>  		if (!inet_csk_ack_scheduled(sk))
> >>  			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
> >> 
>  ...
> > Ingo probably can answer to this question, since he changed
> > sock_def_readable() (and others) in commit 6f3d09291b498299
> > I suspect he missed tcp_prequeue() case, maybe not...
> 
> It definitely looks like an oversight to me and we should add
> be using wake_up_interruptible_sync_poll() in tcp_prequeue()
> as above.
> 
> Ingo?

Yeah. I remember that patch, it was minimalistic, based on the workload i 
could trigger back then.

Thanks,

	Ingo
