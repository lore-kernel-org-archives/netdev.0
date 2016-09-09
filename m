From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v8 2/3] net: core: Add offload stats to if_stats_msg
Date: Fri, 9 Sep 2016 16:23:47 +0300
Message-ID: <4B88A9EE-EF76-4C0E-A8C1-D6A11DF367E3@cumulusnetworks.com>
References: <1473315593-2078-1-git-send-email-jiri@resnulli.us> <1473315593-2078-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, nogahf@mellanox.com,
        Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
        yotamg@mellanox.com, ogerlitz@mellanox.com,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        linville@tuxdriver.com, tgraf@suug.ch,
        Andy Gospodarek <gospo@cumulusnetworks.com>, sfeldma@gmail.com,
        sd@queasysnail.net, eranbe@mellanox.com, ast@plumgrid.com,
        edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36682 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751219AbcIINXp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 09:23:45 -0400
Received: by mail-wm0-f43.google.com with SMTP id b187so31326887wme.1
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 06:23:44 -0700 (PDT)
In-Reply-To: <1473315593-2078-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Sep 8, 2016, at 9:19 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>=20
> From: Nogah Frankel <nogahf@mellanox.com>
>=20
> Add a nested attribute of offload stats to if_stats_msg
> named IFLA_STATS_LINK_OFFLOAD_XSTATS.
> Under it, add SW stats, meaning stats only per packets that went via
> slowpath to the cpu, named IFLA_OFFLOAD_XSTATS_CPU_HIT.
>=20
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> include/uapi/linux/if_link.h |  9 ++++
> net/core/rtnetlink.c         | 97 =
++++++++++++++++++++++++++++++++++++++++++--
> 2 files changed, 102 insertions(+), 4 deletions(-)
>=20
[snip]
>=20
> +	if (stats_attr_valid(filter_mask, =
IFLA_STATS_LINK_OFFLOAD_XSTATS,
> +			     *idxattr)) {
> +		attr =3D nla_nest_start(skb, =
IFLA_STATS_LINK_OFFLOAD_XSTATS);
> +		if (!attr)
> +			goto nla_put_failure;
> +
> +		err =3D rtnl_get_offload_stats(skb, dev);
> +		if (err =3D=3D -ENODATA)
> +			nla_nest_cancel(skb, attr);
> +		else
> +			nla_nest_end(skb, attr);
> +
> +		if ((err) && (err !=3D -ENODATA))
> +			goto nla_put_failure;

Hi,
Sorry I=E2=80=99m a little late to the party, one minor nit though - =
could you please drop the extra braces here.
Overall the set looks good to me and you can add my

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Thanks,
 Nik

> +	}
> +
> 	nlmsg_end(skb, nlh);
>=20
> 	return 0;
> @@ -3712,6 +3798,9 @@ static size_t if_nlmsg_stats_size(const struct =
net_device *dev,
> 		}
> 	}
>=20
> +	if (stats_attr_valid(filter_mask, =
IFLA_STATS_LINK_OFFLOAD_XSTATS, 0))
> +		size +=3D rtnl_get_offload_stats_size(dev);
> +
> 	return size;
> }
>=20
> --=20
> 2.5.5
>=20
