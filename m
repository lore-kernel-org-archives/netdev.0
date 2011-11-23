From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] isdn: make sure strings are null terminated
Date: Wed, 23 Nov 2011 08:03:31 +0100
Message-ID: <1322031811.1298.38.camel@edumazet-laptop>
References: <20111123064204.GA6871@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33568 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827Ab1KWHDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 02:03:36 -0500
In-Reply-To: <20111123064204.GA6871@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 novembre 2011 =C3=A0 09:42 +0300, Dan Carpenter a =C3=A9=
crit :
> These strings come from the user.  We strcpy() them inside
> cf_command() so we should check that they are NULL terminated and
> return an error if not.
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>=20
> diff --git a/drivers/isdn/divert/divert_procfs.c b/drivers/isdn/diver=
t/divert_procfs.c
> index 33ec9e4..0c16687 100644
> --- a/drivers/isdn/divert/divert_procfs.c
> +++ b/drivers/isdn/divert/divert_procfs.c
> @@ -242,6 +242,10 @@ static int isdn_divert_ioctl_unlocked(struct fil=
e *file, uint cmd, ulong arg)
>  		case IIOCDOCFINT:
>  			if (!divert_if.drv_to_name(dioctl.cf_ctrl.drvid))
>  				return (-EINVAL);	/* invalid driver */
> +			if (strlen(dioctl.cf_ctrl.msn) >=3D sizeof(dioctl.cf_ctrl.msn))
> +				return -EINVAL;

This looks buggy.

If string is not null terminated, how strlen() will stop you from going
out of bounds, and trigger some run time checker ?

strnlen() would be more effective...

> +			if (strlen(dioctl.cf_ctrl.fwd_nr) >=3D sizeof(dioctl.cf_ctrl.fwd_=
nr))
> +				return -EINVAL;
>  			if ((i =3D cf_command(dioctl.cf_ctrl.drvid,
>  					    (cmd =3D=3D IIOCDOCFACT) ? 1 : (cmd =3D=3D IIOCDOCFDIS) ? 0=
 : 2,
>  					    dioctl.cf_ctrl.cfproc,
> --
