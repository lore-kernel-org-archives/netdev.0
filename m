From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Transparent Proxying
Date: Wed, 4 Aug 2004 13:27:56 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804032756.GA2388@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave:

I need to implement a semi-transparent TCP proxy for work.  The requirement
is that it'll intercept all TCP connections passing through and redirect
them to a local port.  Once there the connection will be forwarded through
a non-TCP protocol (that's why it's only semi-transparent, in fact it's
only a half-TCP proxy :)

Redirecting is easy through the REDIRECT netfilter target.  But the tricky
bit is getting the original destination address so that we can forward this
information to our peer who will turn the connection back into TCP.  Since
this proxy has to be completely generic it cannot rely on ULP-specific
information to deduce the destination address.

I looked around and found the TPROXY patch which is part of pom-ng.
It is capable of providing the information I need via a getsockopt()
call.

The only catch is that you seem to have some objections to it :)

So I'd like to know your objections against the patch and how they
might be overcome.  If you know another way of getting the destination
information then that would be good to (apart from the obvious one
of parsing /proc/net/ip_conntrack :)

Thanks in advance,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
