From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH net] bridge: fix igmp / mld query parsing
Date: Wed, 4 May 2016 16:59:11 +0200
Message-ID: <20160504145911.GA2604@otheros>
References: <1462306734-4183-1-git-send-email-linus.luessing@c0d3.blue>
	<20160503132623.59cf54fb@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Simon Wunderlich <sw@simonwunderlich.de>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	"David S . Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160503132623.59cf54fb@xeon-e3>
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

On Tue, May 03, 2016 at 01:26:23PM -0700, Stephen Hemminger wrote:
> On Tue,  3 May 2016 22:18:54 +0200
> Linus L=C3=BCssing <linus.luessing@c0d3.blue> wrote:
>=20
> > diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> > index 03661d9..7105cdf 100644
> > --- a/net/bridge/br_multicast.c
> > +++ b/net/bridge/br_multicast.c
> > @@ -1271,6 +1271,7 @@ static int br_ip4_multicast_query(struct net_br=
idge *br,
> >  	unsigned long max_delay;
> >  	unsigned long now =3D jiffies;
> >  	__be32 group;
> > +	int offset =3D skb_transport_offset(skb);
> shouldn't this be unsigned?

Yes, should always be unsigned here.

Ok, I'm changing that (even though skb_transport_offset() is "static
inline int").
