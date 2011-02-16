From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: Off-by-one error in net/8021q/vlan.c
Date: Wed, 16 Feb 2011 13:51:33 +0100
Message-ID: <AANLkTinBOk8ZNQvRpMqZQE_vOu63QVzDZ4ceRRUDvJD_@mail.gmail.com>
References: <4D5BADCF.5000804@ka9q.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org
To: Phil Karn <karn@ka9q.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48018 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754941Ab1BPMvf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 07:51:35 -0500
Received: by eye27 with SMTP id 27so728569eye.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 04:51:34 -0800 (PST)
In-Reply-To: <4D5BADCF.5000804@ka9q.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 16, 2011 at 11:58 AM, Phil Karn <karn@ka9q.net> wrote:
> The range check on vlan_id in register_vlan_device is off by one, and=
 it
> prevents the creation of a vlan interface for vlan ID 4095. (OSX allo=
ws
> this, I checked.)

Then OSX should fix their code. 4095 is reserved.

//richard

> Here's the trivial patch:
>
> --- linux-2.6.37/net/8021q/vlan.c~ =A0 =A0 =A02011-01-04 16:50:19.000=
000000 -0800
> +++ linux-2.6.37/net/8021q/vlan.c =A0 =A0 =A0 2011-02-16 02:43:13.988=
812958 -0800
> @@ -239,7 +239,7 @@
> =A0 =A0 =A0 =A0char name[IFNAMSIZ];
> =A0 =A0 =A0 =A0int err;
>
> - =A0 =A0 =A0 if (vlan_id >=3D VLAN_VID_MASK)
> + =A0 =A0 =A0 if (vlan_id > VLAN_VID_MASK)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ERANGE;
>
> =A0 =A0 =A0 =A0err =3D vlan_check_real_dev(real_dev, vlan_id);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Thanks,
//richard
