From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] tls: kernel TLS support
Date: Fri, 26 May 2017 07:16:59 -0700
Message-ID: <1495808219.6465.118.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1495642647.git.davejwatson@fb.com>
         <20170524162708.GA24215@davejwatson-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Tom Herbert <tom@herbertland.com>, herbert@gondor.apana.org.au,
        linux-crypto@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        nmav@gnults.org, fridolin.pokorny@gmail.com
To: Dave Watson <davejwatson@fb.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170524162708.GA24215@davejwatson-mba.local>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-05-24 at 09:27 -0700, Dave Watson wrote:
> Software implementation of transport layer security, implemented using ULP
> infrastructure.  tcp proto_ops are replaced with tls equivalents of sendmsg and
> sendpage.

...

> +
> +int tls_sw_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
> +{
	...
> +
> +	lock_sock(sk);
> +
> +	/* Only one writer at a time is allowed */
> +	if (sk->sk_write_pending)
> +		return -EBUSY;

Ouch...
