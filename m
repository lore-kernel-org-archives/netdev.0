From: Vasiliy Kulikov <segooon@gmail.com>
Subject: Re: [PATCH] net: core: sock: fix information leak to userland
Date: Sat, 30 Oct 2010 18:49:51 +0400
Message-ID: <20101030144951.GA25135@albatros>
References: <1288448801-6303-1-git-send-email-segooon@gmail.com>
 <1288449350.2680.970.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1288449350.2680.970.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 30, 2010 at 16:35 +0200, Eric Dumazet wrote:
> Le samedi 30 octobre 2010 =E0 18:26 +0400, Vasiliy Kulikov a =E9crit =
:
> > "Address" variable might be not fully initialized in sock->ops->get=
_name().
> > The only current implementation is get_name(), it leaves some paddi=
ng
> > fields of sockaddr_tipc uninitialized.  It leads to leaking of cont=
ents
> > of kernel stack memory.
> >=20
> > Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
> > ---
> >  Compile tested.
> >=20
> >  net/core/sock.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 3eed542..759dd81 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -930,6 +930,7 @@ int sock_getsockopt(struct socket *sock, int le=
vel, int optname,
> >  	{
> >  		char address[128];
> > =20
> > +		memset(&address, 0, sizeof(address));
> >  		if (sock->ops->getname(sock, (struct sockaddr *)address, &lv, 2)=
)
> >  			return -ENOTCONN;
> >  		if (lv < len)
>=20
> ???
>=20
> Please fix the real bug.

What if somebody want to create his own implementation of getname()?
IMO it's much safer to introduce memset() here and relax getname()'s
responsibilities.  Quite many drivers "forget" to initialize outputs
structures.  E.g. new net_device's private field is kzalloc'ed to
simplify driver's code.

--=20
Vasiliy
