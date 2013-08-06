From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: [PATCH] bridge: don't try to update timers in case of
 broken MLD queries
Date: Tue, 6 Aug 2013 02:32:27 +0200
Message-ID: <20130806003227.GH25436@Linus-Debian>
References: <1375741925-22179-1-git-send-email-linus.luessing@web.de>
	<20130805154222.58361734@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Paul Bolle <pebolle@tiscali.nl>, Cong Wang <amwang@redhat.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Adam Baker <linux@baker-net.org.uk>, linus.luessing@web.de,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130805154222.58361734@nehalam.linuxnetplumber.net>
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

On Mon, Aug 05, 2013 at 03:42:22PM -0700, Stephen Hemminger wrote:
> On Tue,  6 Aug 2013 00:32:05 +0200
> Linus L=C3=BCssing <linus.luessing@web.de> wrote:
>=20
> > Currently we are reading an uninitialized value for the max_delay
> > variable when snooping an MLD query message of invalid length and wou=
ld
> > update our timers with that.
> >=20
> > Fixing this by simply ignoring such broken MLD queries (just like we =
do
> > for IGMP already).
> >=20
> > This is a regression introduced by:
> > "bridge: disable snooping if there is no querier" (b00589af3b04)
> >=20
> > Reported-by: Paul Bolle <pebolle@tiscali.nl>
> > Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
> > ---
> >  net/bridge/br_multicast.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> > index 61c5e81..08e576a 100644
> > --- a/net/bridge/br_multicast.c
> > +++ b/net/bridge/br_multicast.c
> > @@ -1195,7 +1195,7 @@ static int br_ip6_multicast_query(struct net_br=
idge *br,
> >  		max_delay =3D msecs_to_jiffies(ntohs(mld->mld_maxdelay));
> >  		if (max_delay)
> >  			group =3D &mld->mld_mca;
> > -	} else if (skb->len >=3D sizeof(*mld2q)) {
> > +	} else {
> >  		if (!pskb_may_pull(skb, sizeof(*mld2q))) {
> >  			err =3D -EINVAL;
> >  			goto out;
>=20
> Why not use else if here, other than that looks great.

Because it isn't really necessary, it is basically included
in the pskb_may_pull() already, just like it is in the according IGMP
code path.

And I thought it'd be nicer to handle it the same way as in the
IGMP code path to avoid diverging too much.

Cheers, Linus
