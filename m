From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 22 Sep 2004 07:35:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095852956.1048.47.camel@jzny.localdomain>
References: <20040919215915.GB9573@gondor.apana.org.au>
	 <1095633569.1047.107.camel@jzny.localdomain>
	 <20040919231734.GA10124@gondor.apana.org.au>
	 <1095647944.1046.206.camel@jzny.localdomain>
	 <20040920025802.GA11567@gondor.apana.org.au>
	 <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net>
	 <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net>
	 <1095821624.1045.6.camel@jzny.localdomain>
	 <20040922034634.GA14928@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040922034634.GA14928@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-21 at 23:46, Herbert Xu wrote:
> 
> Well I haven't seen any with IPsec.  Can you please provide a strace
> of a failed tc dump so that I know what I'm looking for?

Try explicitly reducing the socket buffer size and see what happens

Heres a script i use (you would need to compile tc action gact and have
the latest iproute2):

---
#!/bin/sh

tc qdisc del dev eth1 ingress
tc qdisc add dev eth1 ingress

for ((i = 1 ; i <= $1 ; i++))
do
        tc actions add action drop index $i
done
----

set i to 10000 or a little more

to dump: tc actions ls action drop

cheers,
jamal
