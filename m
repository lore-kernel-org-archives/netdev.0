From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH 2/2] r8169: allow true forced mode setting
Date: Sat, 16 May 2009 14:50:38 +0200
Message-ID: <200905161450.38281.jdelvare@suse.de>
References: <20090514214605.GB6374@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Vincent Steenhoute <vsteenhoute@novell.com>,
	Martin Michlmayr <tbm@cyrius.com>,
	Xose Vazquez Perez <xose.vazquez@gmail.com>,
	Ivan Vecera <ivecera@redhat.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60612 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755178AbZEPMuk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 08:50:40 -0400
In-Reply-To: <20090514214605.GB6374@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fran=E7ois,

Le jeudi 14 mai 2009, Francois Romieu a =E9crit=A0:
> Due to mostly historic reasons, including a lack of reliability
> of the link handling (especially with the older 8169), the
> current r8169 driver emulates forced mode setting by limiting
> the advertised modes.
>=20
> With this change the driver allows real 10/100 forced mode
> settings on the 8169 and 8101/8102.
>=20
> Original idea by Vincent Steenhoute. The RTL_GIGA_MAC_VER_03
> tweak was extracted from Realtek's v6.009.00 driver.

If I read the code correctly, Realtek's driver (v6.010.00) only
applies the quirk for RTL8169S and RTL8110S chips (what I have) and
not the original RTL8169. Your code applies the quirk to all 3
chips. Is this on purpose? Or am I missing something?

> (...)
> +	if (tp->mac_version <=3D RTL_GIGA_MAC_VER_03) {
> +		if ((speed =3D=3D SPEED_100) && (autoneg !=3D AUTONEG_ENABLE)) {
> +			mdio_write(ioaddr, 0x17, 0x2138);
> +			mdio_write(ioaddr, 0x0e, 0x0260);
> +		} else {
> +			mdio_write(ioaddr, 0x17, 0x2108);
> +			mdio_write(ioaddr, 0x0e, 0x0000);
> +		}
> +	}
> +
>  	return 0;
>  }

Thanks,
--=20
Jean Delvare
Suse L3
