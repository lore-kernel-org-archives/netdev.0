From: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] drivers/net/wireless/iwlegacy: use strlcpy instead of
 strncpy
Date: Sun, 20 Jan 2013 17:31:35 +0800
Message-ID: <50FBB977.7080805@asianux.com>
References: <50EA5246.8060206@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50EA5246.8060206-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello all:

  sorry, after checking the details:
    I think this patch is incorrect.
      we can not assume that the parameter "char *buf" is terminated by=
 '\0'
      so we should only use strlcpy instead of strncpy, without touchin=
g 'min(...'

  since it is already integrated into main branch (at least, in next-20=
130118).
    I should send additional patch to fix it.

  please help to check, thanks.


gchen.


=D3=DA 2013=C4=EA01=D4=C207=C8=D5 12:42, Chen Gang =D0=B4=B5=C0:
>=20
>   The fields must be null-terminated, or simple_strtoul will cause is=
sue.
>=20
> Signed-off-by: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
> ---
>  drivers/net/wireless/iwlegacy/3945-mac.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/w=
ireless/iwlegacy/3945-mac.c
> index d604b40..3726cd6 100644
> --- a/drivers/net/wireless/iwlegacy/3945-mac.c
> +++ b/drivers/net/wireless/iwlegacy/3945-mac.c
> @@ -3273,7 +3273,7 @@ il3945_store_measurement(struct device *d, stru=
ct device_attribute *attr,
> =20
>  	if (count) {
>  		char *p =3D buffer;
> -		strncpy(buffer, buf, min(sizeof(buffer), count));
> +		strlcpy(buffer, buf, sizeof(buffer));
>  		channel =3D simple_strtoul(p, NULL, 0);
>  		if (channel)
>  			params.channel =3D channel;
>=20


--=20
Chen Gang

Asianux Corporation
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
