From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net 1/3] bonding:record primary when modify it via sysfs
Date: Mon, 11 Jun 2012 21:38:32 +0200
Message-ID: <4FD64938.6080009@gmail.com>
References: <cover.1339404887.git.wpan@redhat.com> <84a4e0e6bbdc9206baefb1454324f4759a98b80e.1339404887.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Weiping Pan <wpan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35579 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891Ab2FKThj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 15:37:39 -0400
Received: by eaak11 with SMTP id k11so1948039eaa.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 12:37:38 -0700 (PDT)
In-Reply-To: <84a4e0e6bbdc9206baefb1454324f4759a98b80e.1339404887.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/06/2012 11:00, Weiping Pan a =C3=A9crit :
> If we modify primary via sysfs and it is not a valid slave,
> we should record it for future use, and this behavior is the same wit=
h
> bond_check_params().
>
> Signed-off-by: Weiping Pan<wpan@redhat.com>
> ---
>   drivers/net/bonding/bond_sysfs.c |    8 ++++++--
>   1 files changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/b=
ond_sysfs.c
> index aef42f0..485bedb 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -1082,8 +1082,12 @@ static ssize_t bonding_store_primary(struct de=
vice *d,
>   		}
>   	}
>
> -	pr_info("%s: Unable to set %.*s as primary slave.\n",
> -		bond->dev->name, (int)strlen(buf) - 1, buf);
> +	strncpy(bond->params.primary, ifname, IFNAMSIZ);
> +	bond->params.primary[IFNAMSIZ - 1] =3D 0;
> +
> +	pr_info("%s: Recording %s as primary, "
> +		"but it has not been enslaved to %s yet.\n",
> +		bond->dev->name, ifname, bond->dev->name);
>   out:
>   	write_unlock_bh(&bond->curr_slave_lock);
>   	read_unlock(&bond->lock);

I like this one, because it tend to relax the current constraints one s=
hould respect on the order to=20
write into sysfs to setup bonding.

May I suggest we have a better info message, suggesting there might hav=
e a typo on the name of the=20
primary ?

 > +	pr_info("%s: Recording %s as primary, "
 > +		"but it has not been enslaved to %s yet. Possible typo?\n",
 > +		bond->dev->name, ifname, bond->dev->name);

Except from this cosmetic,

Acked-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>

	Nicolas.
