From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 10/13] net/socket.c::sys_bind() cleanup.
Date: Thu, 25 Nov 2004 21:19:51 +1100
Message-ID: <E1CXGj9-00068Z-00@gondolin.me.apana.org.au>
References: <OFF45FF067.1B428792-ON88256F56.0078D794-88256F56.007926F9@us.ibm.com>
Cc: lcapitulino@conectiva.com.br, akpm@osdl.org, davem@davemloft.net,
        jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com (David Stevens)
In-Reply-To: <OFF45FF067.1B428792-ON88256F56.0078D794-88256F56.007926F9@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens <dlstevens@us.ibm.com> wrote:
> It's just a style issue, so maybe you'll disagree, but I prefer:
> 
>        if (!sock)
>                return err;
> 
> to your
> 
>        if (!sock)
>                goto out;
> ...
> out:
>        return err;
> 
>        I think "return err" is more readable than "goto out/return err" 
> for
> that path and having another "return err" for the out-with-put case isn't 
> a
> terrible thing.

When used in isolation you would be right.  However when there
are multiple exit points then the goto is better because it
means that we have only one exit path.  When you have multiple
exit paths it's very easy to get memory leaks and missing unlock's.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
