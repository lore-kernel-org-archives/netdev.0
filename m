From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] tls: kernel TLS support
Date: Fri, 26 May 2017 11:18:52 -0400 (EDT)
Message-ID: <20170526.111852.235696953256744250.davem@davemloft.net>
References: <cover.1495642647.git.davejwatson@fb.com>
        <20170524162708.GA24215@davejwatson-mba.local>
        <1495808219.6465.118.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davejwatson@fb.com, ilyal@mellanox.com, aviadye@mellanox.com,
        borisp@mellanox.com, liranl@mellanox.com, matanb@mellanox.com,
        netdev@vger.kernel.org, tom@herbertland.com,
        herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        hannes@stressinduktion.org, alexei.starovoitov@gmail.com,
        nmav@gnults.org, fridolin.pokorny@gmail.com
To: eric.dumazet@gmail.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1495808219.6465.118.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 26 May 2017 07:16:59 -0700

> On Wed, 2017-05-24 at 09:27 -0700, Dave Watson wrote:
>> Software implementation of transport layer security, implemented using ULP
>> infrastructure.  tcp proto_ops are replaced with tls equivalents of sendmsg and
>> sendpage.
> 
> ...
> 
>> +
>> +int tls_sw_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>> +{
> 	...
>> +
>> +	lock_sock(sk);
>> +
>> +	/* Only one writer at a time is allowed */
>> +	if (sk->sk_write_pending)
>> +		return -EBUSY;
> 
> Ouch...

Well, as I understand it, it is the same restriction userspace must
itself enforce either in the application or in the SSL library.
