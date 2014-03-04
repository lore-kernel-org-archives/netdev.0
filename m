From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] bridge: multicast: add sanity check for query
	source addresses
Date: Tue, 4 Mar 2014 21:00:10 +0100
Message-ID: <20140304200010.GA26307@order.stressinduktion.org>
References: <1393901855-18231-1-git-send-email-linus.luessing@web.de>
	<20140304090614.GA3952@order.stressinduktion.org>
	<20140304104032.GB5090@Linus-Debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jan Stancek <jstancek@redhat.com>
To: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20140304104032.GB5090@Linus-Debian>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 04, 2014 at 11:43:55AM +0100, Linus L=C3=BCssing wrote:
> On Tue, Mar 04, 2014 at 10:06:14AM +0100, Hannes Frederic Sowa wrote:
> > > diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> > > index ef66365..fb0e36f 100644
> > > --- a/net/bridge/br_multicast.c
> > > +++ b/net/bridge/br_multicast.c
> > > @@ -1235,6 +1235,12 @@ static int br_ip6_multicast_query(struct net=
_bridge *br,
> > >  	    (port && port->state =3D=3D BR_STATE_DISABLED))
> > >  		goto out;
> > > =20
> > > +	/* RFC2710+RFC3810 (MLDv1+MLDv2) require link-local source addres=
ses */
> > > +	if (!(ipv6_addr_type(&ip6h->saddr) & IPV6_ADDR_LINKLOCAL)) {
> > > +		err =3D -EINVAL;
> > > +		goto out;
> > > +	}
> > > +
> >=20
> > Shouldn't we allow empty source address, here?
> >=20
> > Routers are supposed to drop them but bridges care. Linux uses ::
> > as source address as long as no valid LL addresses are available,
> > e.g. at boot-up (RFC3810 5.2.13.).
>=20
> RFC3810, 5.2.13. refers to MLD reports, not queries, so that
> shouldn't be relevant, section 5.1.14 should apply. Also the
> bridge code only issues queries with a valid link-local source
> address (see br_ip6_multicast_alloc_query() in
> net/bridge/br_multicast.c). Where does Linux use :: for queries?

Sorry, I confused queries with reports.
Your patch looks good, same check as in igmp6_event_query.

Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Bye,

  Hannes
