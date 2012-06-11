From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net 3/3] bonding:force to use primary slave
Date: Mon, 11 Jun 2012 21:49:47 +0200
Message-ID: <4FD64BDB.3060003@gmail.com>
References: <cover.1339404887.git.wpan@redhat.com> <19a50a970bfa4eab890a39293fa505f90fbfc5e4.1339404887.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Weiping Pan <wpan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63663 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794Ab2FKTsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 15:48:53 -0400
Received: by eeit10 with SMTP id t10so1975199eei.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 12:48:52 -0700 (PDT)
In-Reply-To: <19a50a970bfa4eab890a39293fa505f90fbfc5e4.1339404887.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/06/2012 11:00, Weiping Pan a =C3=A9crit :
> When we set primary slave with module parameters, bond will always us=
e this
> primary slave as active slave.
>
> But when we modify primary slave via sysfs, it will call
> bond_should_change_active() and take into account primary_reselect.
>
> And I think we should use the new primary slave as the new active sla=
ve
> regardless of the value of primary_reselect.
> Thus the behavior is the same with module parameters and meets the
> administrator's expectation.
>
> Signed-off-by: Weiping Pan<wpan@redhat.com>
> ---
>   drivers/net/bonding/bond_sysfs.c |    1 +
>   1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/b=
ond_sysfs.c
> index 1b0f3cd..7256ae4 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -1077,6 +1077,7 @@ static ssize_t bonding_store_primary(struct dev=
ice *d,
>   				bond->dev->name, slave->dev->name);
>   			bond->primary_slave =3D slave;
>   			strcpy(bond->params.primary, slave->dev->name);
> +			bond->force_primary =3D true;
>   			bond_select_active_slave(bond);
>   			goto out;
>   		}

Not sure this is the right behavior. One may want to change the primary=
 without causing a switch to=20
this primary if another slave is already active, and setup primary_rese=
lect to failure or better for=20
that reason. The administrator still have the option to write into acti=
ve_slave, to force the new=20
active slave after changing the primary.

Arguably, this should be documented.

	Nicolas.
