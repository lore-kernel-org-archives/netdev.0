From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: allow all slave speeds
Date: Wed, 01 Jun 2011 23:30:02 +0200
Message-ID: <4DE6AF5A.4030402@gmail.com>
References: <1306960593-16347-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50323 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758951Ab1FAVaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 17:30:05 -0400
Received: by wya21 with SMTP id 21so170996wya.19
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2011 14:30:04 -0700 (PDT)
In-Reply-To: <1306960593-16347-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/06/2011 22:36, Jiri Pirko a =C3=A9crit :
> No need to check for 10, 100, 1000, 10000 explicitly. Just make this
> generic and check for invalid values only (similar check is in ethtoo=
l
> userspace app). This enables correct speed handling for slave devices
> with "nonstandard" speeds.
>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
> ---
>   drivers/net/bonding/bond_main.c |    9 +--------
>   1 files changed, 1 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 17b4dd9..716c852 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -629,15 +629,8 @@ static int bond_update_speed_duplex(struct slave=
 *slave)
>   		return -1;
>
>   	slave_speed =3D ethtool_cmd_speed(&etool);
> -	switch (slave_speed) {
> -	case SPEED_10:
> -	case SPEED_100:
> -	case SPEED_1000:
> -	case SPEED_10000:
> -		break;
> -	default:
> +	if (slave_speed =3D=3D 0 || slave_speed =3D=3D ((__u32) -1))
>   		return -1;
> -	}
>
>   	switch (etool.duplex) {
>   	case DUPLEX_FULL:

This makes sense to me. In particular, with Wifi slaves, this should al=
low the actual speed of the=20
wireless link to be taken into account for active slave selection. We m=
ay need to add more stuffs=20
for this to work, because Wifi link speed may change after enslavement,=
 but this is a first step in=20
the right direction.

Also, the same is true for FULL/HALF duplex. Why should we check the re=
turned value, instead of just=20
storing it?

Reviewed-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
