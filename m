From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATH] dev: reusing unregistered ifindex values in net_device
Date: Thu, 18 Nov 2010 16:37:08 +0100
Message-ID: <1290094628.2781.195.camel@edumazet-laptop>
References: <AANLkTinx6Ww4ZwRUTyYD_STPSRsSFck8O=W5yeJSbBs_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "Voravit T." <voravit@kth.se>,
	Robert Olsson <robert@herjulf.net>
To: Daniel Turull <daniel.turull@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61586 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759047Ab0KRPh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 10:37:29 -0500
Received: by eye27 with SMTP id 27so1998746eye.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 07:37:28 -0800 (PST)
In-Reply-To: <AANLkTinx6Ww4ZwRUTyYD_STPSRsSFck8O=W5yeJSbBs_@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 novembre 2010 =C3=A0 16:25 +0100, Daniel Turull a =C3=A9cri=
t :
> When a new index is going to be assigned in register_netdevice,
> the dev_new_index starts to search possible values from the last inde=
x
> given to a device although there might be some free ifindex that has =
been
> previously unregistered.  This behaviour may create gap(s) in the ifi=
ndex list.
>=20
> This patch checks for unused values from 1 and gives to the new devic=
e the
> first available value. This limits the maximum ifindex to a smaller v=
alue.
>=20
> The ifindex will still be unique since the old value is no longer in =
use.
>=20
> Reported-by: Voravit Tanyingyong  <voravit@kth.se>
> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
>=20
> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 381b8e2..a7babab 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4871,7 +4871,7 @@ int dev_ioctl(struct net *net, unsigned int cmd=
,
> void __user *arg)
>   */
>  static int dev_new_index(struct net *net)
>  {
> -	static int ifindex;
> +	int ifindex;
>  	for (;;) {
>  		if (++ifindex <=3D 0)
>  			ifindex =3D 1;
> --

NACK

Two bugs=20

1) ifindex is not initialized : you'll be suprised of random values

2) ifindex should not be reused. You'll be surprised so applications ca=
n
break. SNMP comes to mind.



