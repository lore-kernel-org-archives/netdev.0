From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: IPv4: Attempt to release TCP socket in state 1
Date: Thu, 14 Mar 2013 23:56:26 +0100
Message-ID: <1363301786.29475.40.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1303041547080.7811@localhost6.localdomain6>
	    <51356AC1.4090302@gmail.com>
	  <1362460046.15793.111.camel@edumazet-glaptop>
	   <alpine.DEB.2.02.1303042138330.7811@localhost6.localdomain6>
	  <1362494795.15793.113.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303061631290.6723@dflat>
	 <1362663990.15793.208.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303141359080.16308@dflat>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dormando <dormando@rydia.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1303141359080.16308@dflat>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-03-14 at 14:21 -0700, dormando wrote:
> >
> > diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> > index 68f6a94..1d4d97e 100644
> > --- a/net/ipv4/af_inet.c
> > +++ b/net/ipv4/af_inet.c
> > @@ -141,8 +141,9 @@ void inet_sock_destruct(struct sock *sk)
> >  	sk_mem_reclaim(sk);
> >
> >  	if (sk->sk_type == SOCK_STREAM && sk->sk_state != TCP_CLOSE) {
> > -		pr_err("Attempt to release TCP socket in state %d %p\n",
> > -		       sk->sk_state, sk);
> > +		pr_err("Attempt to release TCP socket family %d in state %d %p\n",
> > +		       sk->sk_family, sk->sk_state, sk);
> > +		WARN_ON_ONCE(1);
> >  		return;
> >  	}
> >  	if (!sock_flag(sk, SOCK_DEAD)) {
> 
> [58377.436522] IPv4: Attempt to release TCP socket family 2 in state 1
> ffff8813fbad9500

There is no stack information on the WARN_ON_ONCE(1) ?
