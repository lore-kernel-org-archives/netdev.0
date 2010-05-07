From: nhorman@mail.tuxdriver.com
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer (v2)
Date: Thu, 6 May 2010 20:02:06 -0400
Message-ID: <E1OAB1B-0002ar-Dp@smtp.tuxdriver.com>
References: <1273180085.2222.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46615 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab0EGACT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 20:02:19 -0400
In-Reply-To: <1273180085.2222.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 6 May 2010 17:08:05 -0400, Eric Dumazet wrote:

> Le jeudi 06 mai 2010 =E0 16:29 -0400, Neil Horman a =E9crit :
> > Version 2 of this patch, taking Erics comment about making the rt_g=
enid non-zero
> > when a netns is created.  This makes sense, and helps prevent attac=
kers from
> > guessing our initial secret value
> >=20
> >=20
> >=20
> > A while back there was a discussion regarding the rt_secret_interva=
l timer.
> > Given that we've had the ability to do emergency route cache rebuil=
ds for awhile
> > now, based on a statistical anal> > cache, the use of the flush tim=
er is somewhat redundant.  This patch removes the
> > rt_secret_interval sysctl, allowing us to rely solely on the statis=
tical
> > analysis mechanism to determine the need for route cache flushes.
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >=20
>=20
> > -
> > -static __net_init int rt_secret_timer_init(struct net *net)
> > +static __net_init int rt_genid_init(struct net *net)
> >  {
> > -	atomic_set(&net->ipv4.rt_genid,
> > -			(int) ((num_physpages ^ (num_physpages>>8)) ^
> > -			(jiffies ^ (jiffies >> 7))));
> > -
>=20
>=20
> > +	/*
> > +	 * This just serves to start off each new net namespace
> > +	 * with a non-zero rt_genid value, making it harder to guess
> > +	 */
> > +	rt_cache_invalidate(net);
> >  	return 0;
> >  }
> > =20
>=20
> I am _sorry_ to be such a paranoiac guy.
>=20
Don't be sorry, I think your concern is valid, I just don't want to kee=
p old code around when=20
> Could you please feed more than 8 bits here ?
>=20
> like :
>=20
> get_random_bytes(&net->ipv4.rt_genid, sizeof(net->ipv4.rt_genid));
>=20
Sure, I'm good with that. I'm not at my desk right now, but ill do that=
 in the morning.

> There is no need to comment this in the code, this kind of rnd init i=
s
> very common in net tree.
>
Ok, copy that, ill fix that up at the same time. =20

Thanks & regards
Neil

>=20
>=20
>=20
>=20
>=20

