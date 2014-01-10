From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [RFC net-next 3/3] bonding: convert packets_per_slave to use the new option API
Date: Fri, 10 Jan 2014 12:04:37 -0800
Message-ID: <3DA1EFBB-2DA3-4DFF-ABB2-91824873A92B@cumulusnetworks.com>
References: <1389359495-9700-1-git-send-email-nikolay@redhat.com> <1389359495-9700-4-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:46459 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757857AbaAJUE7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 15:04:59 -0500
In-Reply-To: <1389359495-9700-4-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 10, 2014, at 5:11 AM, Nikolay Aleksandrov <nikolay@redhat.com> w=
rote:

> This patch adds the necessary changes so packets_per_slave would use =
the
> new bonding option API.
>=20
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> +	[BOND_OPT_PACKETS_PER_SLAVE] =3D {
> +		.id =3D BOND_OPT_PACKETS_PER_SLAVE,
> +		.name =3D "packets_per_slave",
> +		.desc =3D "Packets to send per slave in RR mode",
> +		.valtype =3D BOND_OPTVAL_INTEGER,
> +		.unsuppmodes =3D BOND_MODE_ALL_EX(BIT(BOND_MODE_ROUNDROBIN)),

This .unsuppmodes would be hard to generalize as-is since it=92s bond-s=
pecific.

(*set)() could have done the check also.  Maybe there is a (*check)() f=
unc to do pre-screening of value before (*set) is called, but after gen=
eral checks are made?

> +		.values =3D bond_pps_tbl,
> +		.set =3D bond_option_pps_set
> +	},
> 	{ }
> };
>=20
> @@ -982,28 +997,6 @@ int bond_option_lp_interval_set(struct bonding *=
bond, int lp_interval)
> 	return 0;
> }
>=20
> -int bond_option_packets_per_slave_set(struct bonding *bond,
> -				      int packets_per_slave)
> -{
> -	if (packets_per_slave < 0 || packets_per_slave > USHRT_MAX) {
> -		pr_err("%s: packets_per_slave must be between 0 and %u\n",
> -		       bond->dev->name, USHRT_MAX);
> -		return -EINVAL;
> -	}
> -
> -	if (bond->params.mode !=3D BOND_MODE_ROUNDROBIN)
> -		pr_warn("%s: Warning: packets_per_slave has effect only in balance=
-rr mode\n",
> -			bond->dev->name);
> -
> -	if (packets_per_slave > 1)
> -		bond->params.packets_per_slave =3D
> -			reciprocal_value(packets_per_slave);
> -	else
> -		bond->params.packets_per_slave =3D packets_per_slave;
> -
> -	return 0;
> -}
> -

Nice!  Good bye rambling code.
