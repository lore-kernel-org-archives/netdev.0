From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [patch net-next v6 2/3] net: core: add SW stats to if_stats_msg
Date: Tue, 16 Aug 2016 12:47:00 +0000
Message-ID: <DB5PR05MB18957F335F5A8EA36FED991EAC130@DB5PR05MB1895.eurprd05.prod.outlook.com>
References: <1470777912-2227-1-git-send-email-jiri@resnulli.us>
 <1470777912-2227-3-git-send-email-jiri@resnulli.us>
 <57AAC4E9.4010407@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"sd@queasysnail.net" <sd@queasysnail.net>,
	"Eran Ben Elisha" <eranbe@mellanox.com>,
	"ast@plumgrid.com" <ast@plumgrid.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0059.outbound.protection.outlook.com ([104.47.2.59]:58496
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751260AbcHPQVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 12:21:50 -0400
In-Reply-To: <57AAC4E9.4010407@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Roopa Prabhu [mailto:roopa@cumulusnetworks.com]
> Sent: Wednesday, August 10, 2016 9:09 AM
> To: Jiri Pirko <jiri@resnulli.us>
> Cc: netdev@vger.kernel.org; davem@davemloft.net; Nogah Frankel
> <nogahf@mellanox.com>; Ido Schimmel <idosch@mellanox.com>; Elad
> Raz <eladr@mellanox.com>; Yotam Gigi <yotamg@mellanox.com>; Or
> Gerlitz <ogerlitz@mellanox.com>; nikolay@cumulusnetworks.com;
> linville@tuxdriver.com; tgraf@suug.ch; gospo@cumulusnetworks.com;
> sfeldma@gmail.com; sd@queasysnail.net; Eran Ben Elisha
> <eranbe@mellanox.com>; ast@plumgrid.com; edumazet@google.com;
> hannes@stressinduktion.org; f.fainelli@gmail.com;
> dsa@cumulusnetworks.com
> Subject: Re: [patch net-next v6 2/3] net: core: add SW stats to if_stats_=
msg
>=20
> On 8/9/16, 2:25 PM, Jiri Pirko wrote:
> > From: Nogah Frankel <nogahf@mellanox.com>
> >
> > Add a nested attribute of SW stats to if_stats_msg
> > under IFLA_STATS_LINK_SW_64.
> >
> > Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> > Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> > ---
> >  include/uapi/linux/if_link.h |  1 +
> >  net/core/rtnetlink.c         | 21 +++++++++++++++++++++
> >  2 files changed, 22 insertions(+)
> >
> > diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.=
h
> > index a1b5202..1c9b808 100644
> > --- a/include/uapi/linux/if_link.h
> > +++ b/include/uapi/linux/if_link.h
> > @@ -825,6 +825,7 @@ enum {
> >  	IFLA_STATS_LINK_64,
> >  	IFLA_STATS_LINK_XSTATS,
> >  	IFLA_STATS_LINK_XSTATS_SLAVE,
> > +	IFLA_STATS_LINK_SW_64,
>=20
> sorry, don't mean to drag this discussion forever...but...
>=20
> IIRC on the switchdev call, I thought we had agreed to just put these kin=
d of
> breakdown
> stats in one more layer of nesting.. which can be extended for everybody.
>=20
> IFLA_STATS_LINK_DRIVER_XSTATS   (or some other name) [
>                 IFLA_STATS_LINK_SW_64  (struct rtnl_link_stats64)    <---=
- you get
> the well defined struct here as you wanted.
>                 IFLA_STATS_LINK_HW_ACL_DROPS  /* u64 */        <----- we =
can
> keep extending this for other stats people want.
>=20
>                 /* just keeps it extensible */
> ]
>=20
> because in addition to all other reasons I have mentioned before,
> technically IFLA_STATS_LINK_64 (top-level aggregate stats)
> are also software only stats for say most logical devices etc.
>=20
>=20
> and instead of adding one ndo for your software only stats now and then
> again for other ethtool
> like hw stats from all drivers, it could also be like the below:
>=20
> new ndo_get_hw_stats
>=20
> IFLA_STATS_LINK_HW_XSTATS   (or some other name) [
>                 IFLA_STATS_LINK_CPU_64  (struct rtnl_link_stats64)    <--=
-- you
> get the well defined struct here as you wanted.
>                 IFLA_STATS_LINK_HW_ACL_DROPS  /* u64 */              <---=
-- we can
> keep extending this for other stats people want.
>                 /* just keeps it extensible */
> ]
>=20
> It gets you what you want and keeps the api extensible IMO. your call.
>=20

I don't think extra nesting is a good idea because when we are called for=20
IFLA_STATS_LINK_DRIVER_XSTATS  we can't distinguish between subtypes of it.
So for each driver stats we are going to need different XSTATS types anyway=
.

We shouldn't return all the stats a driver can provide when we are asked fo=
r one.
HW_ACL_DROPS shouldn't be queried when user want SW stats nor the  other
way around.
 (And I think that stats exposed here should be well defined so they could=
=20
be exposed to ifstat. The place for not well define stats is in ethtool)

> >  	__IFLA_STATS_MAX,
> >  };
> >
> > diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> > index 189cc78..910f802 100644
> > --- a/net/core/rtnetlink.c
> > +++ b/net/core/rtnetlink.c
> > @@ -3583,6 +3583,21 @@ static int rtnl_fill_statsinfo(struct sk_buff
> *skb, struct net_device *dev,
> >  		dev_get_stats(dev, sp);
> >  	}
> >
> > +	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_SW_64,
> *idxattr)) {
> > +		if (dev_have_sw_stats(dev)) {
> > +			struct rtnl_link_stats64 *sp;
> > +
> > +			attr =3D nla_reserve_64bit(skb,
> IFLA_STATS_LINK_SW_64,
> > +						 sizeof(struct
> rtnl_link_stats64),
> > +						 IFLA_STATS_UNSPEC);
> > +			if (!attr)
> > +				goto nla_put_failure;
> > +
> > +			sp =3D nla_data(attr);
> > +			dev_get_sw_stats(dev, sp);
> > +		}
> > +	}
> > +
> >  	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS,
> *idxattr)) {
> >  		const struct rtnl_link_ops *ops =3D dev->rtnl_link_ops;
> >
> > @@ -3644,6 +3659,7 @@ nla_put_failure:
> >
> >  static const struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] =
=3D {
> >  	[IFLA_STATS_LINK_64]	=3D { .len =3D sizeof(struct rtnl_link_stats64) =
},
> > +	[IFLA_STATS_LINK_SW_64] =3D { .len =3D sizeof(struct
> rtnl_link_stats64) },
> >  };
> >
> >  static size_t if_nlmsg_stats_size(const struct net_device *dev,
> > @@ -3685,6 +3701,11 @@ static size_t if_nlmsg_stats_size(const struct
> net_device *dev,
> >  		}
> >  	}
> >
> > +	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_SW_64, 0)) {
> > +		if (dev_have_sw_stats(dev))
> > +			size +=3D nla_total_size_64bit(sizeof(struct
> rtnl_link_stats64));
> > +	}
> > +
> >  	return size;
> >  }
> >
