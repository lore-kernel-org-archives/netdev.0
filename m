From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Yield in netlink_broadcast when congested
Date: Mon, 18 Oct 2004 07:31:14 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CJIcU-0007TW-00@gondolin.me.apana.org.au>
References: <20041017130838.GW21977@postel.suug.ch>
Cc: herbert@gondor.apana.org.au, pablo@eurodev.net, hadi@cyberus.ca,
        davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20041017130838.GW21977@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
>
> locking implemented in any application as far as i know, f.e. iproute2
> looks up an ifindex and uses it w/o locking so the link could
> be renamed or removed in between. If we ever implement the ietf

IMHO that particular case should be dealt with by providing a way for
the application to bind to a device and thus holding a reference on it.
This reference should then ensure that the interface name/ifindex doesn't
go away until the appliation relinquinshes it or dies (i.e., the socket
where the binding resides is closed).

> in userspace. This daemon could easly lead to multiple listeners
> in a single process. Nevertheless, I guess we can ignore it for now as

Multiple listeners in a single process should be fine as long as they're
listening to different groups.  It's only when you listen to the same
thing multiple times that you're going to overrun your time-slice and
then your receive queue.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
