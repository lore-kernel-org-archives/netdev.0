From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Fri, 04 Mar 2005 19:31:17 +1100
Message-ID: <E1D78DN-0002te-00@gondolin.me.apana.org.au>
References: <20050304012003.GA31837@postel.suug.ch>
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20050304012003.GA31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
> The deletion of local addresses via netlink doesn't take the
> prefix length into account resulting in the deletion of
> the address that was added first given multiple addresses
> exist only varying in the prefix length.

This has the potential of breaking user-space scripts.  For example,
this won't work anymore:

ip a a dev eth0 192.168.0.1/24
ip a d dev eth0 192.168.0.1

> tgr:axs ~ ip -4 addr show dev lo
> 1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue 
>    inet 127.0.0.1/8 scope host lo
>    inet 1.1.1.1/1 scope global lo
>    inet 1.1.1.1/2 scope global lo

Do we really need to handle this case? If we do then would it be better
to consider ifa_prefixlen only when there are multiple addresses present
which match but differ by prefix length?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
