From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Panic in sk_stream_wait_memory() while doing iSCSI testing
Date: Fri, 29 Apr 2005 17:05:03 +1000
Message-ID: <E1DRPYd-0005RO-00@gondolin.me.apana.org.au>
References: <1114726972.26913.711.camel@dyn318077bld.beaverton.ibm.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pbadari@us.ibm.com (Badari Pulavarty)
In-Reply-To: <1114726972.26913.711.camel@dyn318077bld.beaverton.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Badari Pulavarty <pbadari@us.ibm.com> wrote:
> 
> I ran into panic in sk_stream_wait_memory() while doing iSCSI
> testing on 2.6.12-rc2. The problem seems to be while doing
> 
>        set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
> 
> sk->sk_socket seems to be NULL. Can this happen ? Do we need

If sk->sk_socket is NULL, then either the socket hasn't been
initialised yet or it has already been freed.  Either way you've
got socket life-cycle management issues in your code.

Basically, while you're in sk_stream_wait_memory, you must arrange
it so that the socket does not go away under you.  Normally this is
done by holding a reference on the socket, either directly or
indirectly through a file descriptor.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
