From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next V8] net: introduce ethernet teaming device
Date: Thu, 17 Nov 2011 00:01:27 +0100
Message-ID: <CAHXqBFKZqMSXFygxtfrhgtcfEZMWvhda46d1=J5oZDJ=BsQbTg@mail.gmail.com>
References: <1321085808-6871-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com, fbl@redhat.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com, ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:64307 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669Ab1KPXBt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 18:01:49 -0500
Received: by ggnb2 with SMTP id b2so304484ggn.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 15:01:49 -0800 (PST)
In-Reply-To: <1321085808-6871-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/12 Jiri Pirko <jpirko@redhat.com>:
> This patch introduces new network device called team. It supposes to =
be
> very fast, simple, userspace-driven alternative to existing bonding
> driver.
[...]
> +#define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NETIF_F_FRAGLIS=
T | NETIF_F_ALL_TSO | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NETIF_F_HIGHDMA=
 | NETIF_F_LRO)
> +
> +static void __team_compute_features(struct team *team)
> +{
> + =A0 =A0 =A0 struct team_port *port;
> + =A0 =A0 =A0 u32 vlan_features =3D TEAM_VLAN_FEATURES;
> + =A0 =A0 =A0 unsigned short max_hard_header_len =3D ETH_HLEN;
> +
> + =A0 =A0 =A0 list_for_each_entry(port, &team->port_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_features =3D netdev_increment_feat=
ures(vlan_features,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 port->dev->vlan_features,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 TEAM_VLAN_FEATURES);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (port->dev->hard_header_len > max_ha=
rd_header_len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 max_hard_header_len =3D=
 port->dev->hard_header_len;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 team->dev->vlan_features =3D vlan_features;
> + =A0 =A0 =A0 team->dev->hard_header_len =3D max_hard_header_len;
> +
> + =A0 =A0 =A0 netdev_change_features(team->dev);
> +}
> +
> +static void team_compute_features(struct team *team)
> +{
> + =A0 =A0 =A0 spin_lock(&team->lock);
> + =A0 =A0 =A0 __team_compute_features(team);
> + =A0 =A0 =A0 spin_unlock(&team->lock);
> +}
[...]

I just noticed that you missed ndo_fix_features in the driver. If you
look at bonding driver it should be easy to see how it should work.

Best Regards,
Micha=B3 Miros=B3aw
