From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Bug in ipv6_ifa_notify?
Date: Mon, 8 Nov 2004 17:15:29 +1100
Message-ID: <20041108061529.GA1774@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi:

I'm reviewing the changes between 2.6.8.1 and 2.6.9.  The following
change caught my eye:

# ChangeSet
#   2004/08/17 11:25:16+09:00 yoshfuji@linux-ipv6.org
#   [IPV6] refer inet6 device via corresponding local route from address structure.

In particular, it changed the handling of RTM_NEWADDR in ipv6_ifa_notify.
Previously if you received duplicate RTM_NEWADDR notifications
ip6_rt_addr_add would allocate a new rt and then free it since
ip6_ins_rt would fail.

With the new code, it will call ip6_ins_rt on the *same* rt
again which will cause it to be dst_free'd.  I don't see any
way for this to lead to dst underflows yet, but it'll certainly
corrupt the routing table since dst_free modifies rt->u.next.

Now the question is is it possible to get dupliate RTM_NEWADDR
notifications?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
