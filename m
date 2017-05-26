From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] tls: kernel TLS support
Date: Fri, 26 May 2017 08:49:52 -0700
Message-ID: <1495813792.6465.120.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1495642647.git.davejwatson@fb.com>
         <20170524162708.GA24215@davejwatson-mba.local>
         <1495808219.6465.118.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170526.111852.235696953256744250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davejwatson@fb.com, ilyal@mellanox.com, aviadye@mellanox.com,
        borisp@mellanox.com, liranl@mellanox.com, matanb@mellanox.com,
        netdev@vger.kernel.org, tom@herbertland.com,
        herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        hannes@stressinduktion.org, alexei.starovoitov@gmail.com,
        nmav@gnults.org, fridolin.pokorny@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170526.111852.235696953256744250.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-05-26 at 11:18 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 26 May 2017 07:16:59 -0700
> 
> > On Wed, 2017-05-24 at 09:27 -0700, Dave Watson wrote:
> >> Software implementation of transport layer security, implemented using ULP
> >> infrastructure.  tcp proto_ops are replaced with tls equivalents of sendmsg and
> >> sendpage.
> > 
> > ...
> > 
> >> +
> >> +int tls_sw_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
> >> +{
> > 	...
> >> +
> >> +	lock_sock(sk);
> >> +
> >> +	/* Only one writer at a time is allowed */
> >> +	if (sk->sk_write_pending)
> >> +		return -EBUSY;
> > 
> > Ouch...
> 
> Well, as I understand it, it is the same restriction userspace must
> itself enforce either in the application or in the SSL library.

The problem here is to lock_sock(sk), then returning without releasing
the socket.

Some basic lock imbalance really.
