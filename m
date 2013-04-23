From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v2] Net: mac802154: comparision issue of type cast, finding
 by EXTRA_CFLAGS=-W
Date: Tue, 23 Apr 2013 19:22:57 +0800
Message-ID: <51766F11.6080201@asianux.com>
References: <5174DB87.3010908@asianux.com> <51754485.6040708@cogentembedded.com> <5175DFBC.7040000@asianux.com> <5175F7F7.7000703@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	David Miller <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:43296 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754424Ab3DWLXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 07:23:44 -0400
In-Reply-To: <5175F7F7.7000703@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I will send patch v3 for properly capitalizing my comments' sentences
and subject.

On 2013=E5=B9=B404=E6=9C=8823=E6=97=A5 10:54, Chen Gang wrote:
>=20
> need change ~(u8)0 to 0xff, or in mac802154_wpan_xmit(), "u8 chan"
> will never =3D=3D MAC802154_CHAN_NONE.
>=20
> the related warning:
>   net/mac802154/wpan.c:325:2: warning: comparison is always false
>   due to limited range of data type [-Wtype-limits]
>=20
> related unit test:
>   cc -Wall -O2 -o test test.c
>   ./test
>   will output 'different'
>=20
>   (after use '0xff' instead of '~(u8)0', it will output 'equal')
>=20
> -----------------------test code begin-------------------------------=
-
>=20
> #include <stdio.h>
>=20
> typedef unsigned char u8;
>=20
> int main()
> {
> 	u8 uc =3D 0xff;
>=20
> 	if (uc =3D=3D ~(u8)0)
> 		printf("\nequal\n");
> 	else
> 		printf("\ndifferent\n");
>=20
> 	return 0;
> }
>=20
> -----------------------test code end---------------------------------=
-
>=20
>=20
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  net/mac802154/mac802154.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
> index 5c9e021..d48422e 100644
> --- a/net/mac802154/mac802154.h
> +++ b/net/mac802154/mac802154.h
> @@ -88,7 +88,7 @@ struct mac802154_sub_if_data {
> =20
>  #define mac802154_to_priv(_hw)	container_of(_hw, struct mac802154_pr=
iv, hw)
> =20
> -#define MAC802154_CHAN_NONE		(~(u8)0) /* No channel is assigned */
> +#define MAC802154_CHAN_NONE		0xff /* No channel is assigned */
> =20
>  extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
>  extern struct ieee802154_mlme_ops mac802154_mlme_wpan;
>=20


--=20
Chen Gang

Asianux Corporation
