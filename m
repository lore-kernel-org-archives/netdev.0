From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [patch net-next v7 2/3] net: core: Add offload stats to
 if_stats_msg
Date: Wed, 7 Sep 2016 14:31:15 +0000
Message-ID: <DB5PR05MB189531C271EEE6BF7C71848EACF80@DB5PR05MB1895.eurprd05.prod.outlook.com>
References: <1473095937-27100-1-git-send-email-jiri@resnulli.us>
 <1473095937-27100-3-git-send-email-jiri@resnulli.us>
 <57CEDEAC.1040806@cumulusnetworks.com>
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
        "dsa@cumul
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0057.outbound.protection.outlook.com ([104.47.2.57]:48284
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935930AbcIGOqE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 10:46:04 -0400
In-Reply-To: <57CEDEAC.1040806@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Roopa Prabhu [mailto:roopa@cumulusnetworks.com]
> Sent: Tuesday, September 06, 2016 6:20 PM
> To: Jiri Pirko <jiri@resnulli.us>
> Cc: netdev@vger.kernel.org; davem@davemloft.net; Nogah Frankel
> <nogahf@mellanox.com>; Ido Schimmel <idosch@mellanox.com>; Elad Raz
> <eladr@mellanox.com>; Yotam Gigi <yotamg@mellanox.com>; Or Gerlitz
> <ogerlitz@mellanox.com>; nikolay@cumulusnetworks.com;
> linville@tuxdriver.com; tgraf@suug.ch; gospo@cumulusnetworks.com;
> sfeldma@gmail.com; sd@queasysnail.net; Eran Ben Elisha
> <eranbe@mellanox.com>; ast@plumgrid.com; edumazet@google.com;
> hannes@stressinduktion.org; f.fainelli@gmail.com;
> dsa@cumulusnetworks.com
> Subject: Re: [patch net-next v7 2/3] net: core: Add offload stats to if_s=
tats_msg
>=20
> On 9/5/16, 10:18 AM, Jiri Pirko wrote:
> > From: Nogah Frankel <nogahf@mellanox.com>
> >
> > Add a nested attribute of offload stats to if_stats_msg
> > named IFLA_STATS_LINK_OFFLOAD_XSTATS.
> > Under it, add SW stats, meaning stats only per packets that went via
> > slowpath to the cpu, named IFLA_OFFLOAD_XSTATS_CPU_HIT.
> >
> > Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> > ---
> >  include/uapi/linux/if_link.h | 10 +++++
> >  net/core/rtnetlink.c         | 88
> ++++++++++++++++++++++++++++++++++++++++++--
> >  2 files changed, 94 insertions(+), 4 deletions(-)
> >
> > diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.=
h
> > index 9bf3aec..4aaa2a1 100644
> > --- a/include/uapi/linux/if_link.h
> > +++ b/include/uapi/linux/if_link.h
> > @@ -826,6 +826,7 @@ enum {
> >  	IFLA_STATS_LINK_64,
> >  	IFLA_STATS_LINK_XSTATS,
> >  	IFLA_STATS_LINK_XSTATS_SLAVE,
> > +	IFLA_STATS_LINK_OFFLOAD_XSTATS,
> >  	__IFLA_STATS_MAX,
> >  };
> >
> > @@ -845,6 +846,15 @@ enum {
> >  };
> >  #define LINK_XSTATS_TYPE_MAX (__LINK_XSTATS_TYPE_MAX - 1)
> >
> > +/* These are stats embedded into IFLA_STATS_LINK_OFFLOAD_XSTATS */
> > +enum {
> > +	IFLA_OFFLOAD_XSTATS_UNSPEC,
> > +	IFLA_OFFLOAD_XSTATS_CPU_HIT, /* struct rtnl_link_stats64 */
> > +	__IFLA_OFFLOAD_XSTATS_MAX
> > +};
> > +#define IFLA_OFFLOAD_XSTATS_MAX (__IFLA_OFFLOAD_XSTATS_MAX - 1)
> > +#define IFLA_OFFLOAD_XSTATS_FIRST (IFLA_OFFLOAD_XSTATS_UNSPEC +
> 1)
>=20
> not sure why we need a first in the uapi.

I'll move it to rtnetlink.

> > +
> >  /* XDP section */
> >
> >  enum {
> > diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> > index 1dfca1c..95eb131 100644
> > --- a/net/core/rtnetlink.c
> > +++ b/net/core/rtnetlink.c
> > @@ -3577,6 +3577,74 @@ static bool stats_attr_valid(unsigned int mask,
> int attrid, int idxattr)
> >  	       (!idxattr || idxattr =3D=3D attrid);
> >  }
> >
> > +static int rtnl_get_offload_stats_attr_size(int attr_id)
> > +{
> > +	switch (attr_id) {
> > +	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
> > +		return sizeof(struct rtnl_link_stats64);
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int rtnl_get_offload_stats(struct sk_buff *skb, struct net_devi=
ce
> *dev)
> > +{
> > +	struct nlattr *attr;
> > +	int attr_id, size;
> > +	void *attr_data;
> > +	int err;
> > +
> > +	if (!(dev->netdev_ops && dev->netdev_ops->ndo_has_offload_stats
> &&
> > +	      dev->netdev_ops->ndo_get_offload_stats))
> > +		return 0;
> > +
> > +	for (attr_id =3D IFLA_OFFLOAD_XSTATS_FIRST;
> > +	     attr_id <=3D IFLA_OFFLOAD_XSTATS_MAX; attr_id++) {
> > +		size =3D rtnl_get_offload_stats_attr_size(attr_id);
> > +		if (!size)
> > +			continue;
> > +
> > +		if (!dev->netdev_ops->ndo_has_offload_stats(attr_id))
> > +			continue;
> > +
> > +		attr =3D nla_reserve_64bit(skb, attr_id, size,
> > +					 IFLA_OFFLOAD_XSTATS_UNSPEC);
> > +		if (!attr)
> > +			return -EMSGSIZE;
>=20
> you need this 64bit alignment padding only for the specific nested attrib=
ute
> your driver is adding ?. The code seems to add it unconditionally for eve=
ry
> attribute.
> But, I am guessing future attribute authors will need to adjust this some=
how.
>=20

I think it's best to wait till we have more attributes to see how to implem=
ent it.

> > +
> > +		attr_data =3D nla_data(attr);
> > +		memset(attr_data, 0, size);
> > +		err =3D dev->netdev_ops->ndo_get_offload_stats(attr_id, dev,
> > +							     attr_data);
> > +		if (err)
> > +			return err;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int rtnl_get_offload_stats_size(const struct net_device *dev)
> > +{
> > +	int size =3D 0;
> > +	int attr_id;
> > +
> > +	if (!(dev->netdev_ops && dev->netdev_ops->ndo_has_offload_stats
> &&
> > +	      dev->netdev_ops->ndo_get_offload_stats))
> > +		return nla_total_size(0);
> > +
> > +	for (attr_id =3D IFLA_OFFLOAD_XSTATS_FIRST;
> > +	     attr_id <=3D IFLA_OFFLOAD_XSTATS_MAX; attr_id++) {
> > +		if (!dev->netdev_ops->ndo_has_offload_stats(attr_id))
> > +			continue;
> > +
> > +		size +=3D rtnl_get_offload_stats_attr_size(attr_id);
> > +	}
> > +
> > +	size +=3D nla_total_size(0);
> > +
> > +	return size;
> > +}
> > +
> >  static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device =
*dev,
> >  			       int type, u32 pid, u32 seq, u32 change,
> >  			       unsigned int flags, unsigned int filter_mask,
> > @@ -3586,6 +3654,7 @@ static int rtnl_fill_statsinfo(struct sk_buff *sk=
b,
> struct net_device *dev,
> >  	struct nlmsghdr *nlh;
> >  	struct nlattr *attr;
> >  	int s_prividx =3D *prividx;
> > +	int err;
> >
> >  	ASSERT_RTNL();
> >
> > @@ -3614,8 +3683,6 @@ static int rtnl_fill_statsinfo(struct sk_buff *sk=
b,
> struct net_device *dev,
> >  		const struct rtnl_link_ops *ops =3D dev->rtnl_link_ops;
> >
> >  		if (ops && ops->fill_linkxstats) {
> > -			int err;
> > -
> >  			*idxattr =3D IFLA_STATS_LINK_XSTATS;
> >  			attr =3D nla_nest_start(skb,
> >  					      IFLA_STATS_LINK_XSTATS);
> > @@ -3639,8 +3706,6 @@ static int rtnl_fill_statsinfo(struct sk_buff *sk=
b,
> struct net_device *dev,
> >  		if (master)
> >  			ops =3D master->rtnl_link_ops;
> >  		if (ops && ops->fill_linkxstats) {
> > -			int err;
> > -
> >  			*idxattr =3D IFLA_STATS_LINK_XSTATS_SLAVE;
> >  			attr =3D nla_nest_start(skb,
> >  					      IFLA_STATS_LINK_XSTATS_SLAVE);
> > @@ -3655,6 +3720,18 @@ static int rtnl_fill_statsinfo(struct sk_buff *s=
kb,
> struct net_device *dev,
> >  		}
> >  	}
> >
> > +	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_OFFLOAD_XSTATS,
> > +			     *idxattr)) {
> > +		attr =3D nla_nest_start(skb,
> IFLA_STATS_LINK_OFFLOAD_XSTATS);
> > +		if (!attr)
> > +			goto nla_put_failure;
> > +
> > +		err =3D rtnl_get_offload_stats(skb, dev);
> > +		nla_nest_end(skb, attr);
>=20
> seems like this can result in an empty nested attribute. better thing wou=
ld be to
> cancel the nest if size from rtnl_get_offload_stats is zero ?
>=20

I'll fix it.

> > +		if (err)
> > +			goto nla_put_failure;
> > +	}
> > +
> >  	nlmsg_end(skb, nlh);
> >
> >  	return 0;
> > @@ -3712,6 +3789,9 @@ static size_t if_nlmsg_stats_size(const struct
> net_device *dev,
> >  		}
> >  	}
> >
> > +	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_OFFLOAD_XSTATS,
> 0))
> > +		size +=3D rtnl_get_offload_stats_size(dev);
> > +
> >  	return size;
> >  }
> >
