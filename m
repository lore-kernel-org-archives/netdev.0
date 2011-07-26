From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 2/2] net: Audit drivers to identify those needing IFF_TX_SKB_SHARING cleared
Date: Tue, 26 Jul 2011 20:34:45 +0200
Message-ID: <m362moao1m.fsf@intrepid.localdomain>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	<1311623120-26839-1-git-send-email-nhorman@tuxdriver.com>
	<1311623120-26839-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Marcel Holtmann <marcel@holtmann.org>,
	Johannes Berg <johannes@sipsolutions.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:43749 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731Ab1GZSes convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 14:34:48 -0400
In-Reply-To: <1311623120-26839-3-git-send-email-nhorman@tuxdriver.com> (Neil
	Horman's message of "Mon, 25 Jul 2011 15:45:20 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> writes:

> After the last patch, We are left in a state in which only drivers ca=
lling
> ether_setup have IFF_TX_SKB_SHARING set (we assume that drivers touch=
ing real
> hardware call ether_setup for their net_devices and don't hold any st=
ate in
> their skbs.  There are a handful of drivers that violate this assumpt=
ion of
> course, and need to be fixed up.  This patch identifies those drivers=
, and marks
> them as not being able to support the safe transmission of skbs by cl=
earning the
> IFF_TX_SKB_SHARING flag in priv_flags

> --- a/drivers/net/wan/hdlc_fr.c
> +++ b/drivers/net/wan/hdlc_fr.c
> @@ -1074,9 +1074,10 @@ static int fr_add_pvc(struct net_device *frad,=
 unsigned int dlci, int type)
> =20
>  	used =3D pvc_is_used(pvc);
> =20
> -	if (type =3D=3D ARPHRD_ETHER)
> +	if (type =3D=3D ARPHRD_ETHER) {
>  		dev =3D alloc_netdev(0, "pvceth%d", ether_setup);
> -	else
> +		dev->priv_flags &=3D ~IFF_TX_SKB_SHARING;
> +	} else
>  		dev =3D alloc_netdev(0, "pvc%d", pvc_setup);
> =20
>  	if (!dev) {

That's right, hdlc_fr has to add an additional header.

Acked-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
--=20
Krzysztof Halasa
