From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 3/3] x25_create initializing socket data twice
Date: Sat, 05 Mar 2005 19:47:49 +1100
Message-ID: <E1D7Uwv-0003Ju-00@gondolin.me.apana.org.au>
References: <200503041237.j24Cbdbm026482@shell0.pdx.osdl.net>
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        herbert@13thfloor.at
To: akpm@osdl.org
In-Reply-To: <200503041237.j24Cbdbm026482@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> 
> x25_create() [net/x25/af_x25.c] is calling sock_init_data() twice ...  once
> indirectly via x25_alloc_socket() and a second time directly via
> sock_init_data(sock, sk);
> 
> while this might not look as critical as it seems, it can easily break
> stuff which assumes that sock_init_data() isn't called twice on the same
> socket.

As someone pointed out on LKML, this is broken since the sock_init_data
in x25_alloc_socket() is called with the first argument set to NULL.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
