From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCHv2] net: Define enum for the bits used in features.
Date: Wed, 25 May 2011 11:43:50 +0200
Message-ID: <BANLkTik4KYrR4vYm1R_hYNbwFjQ79FEoHQ@mail.gmail.com>
References: <1306263162-2022-1-git-send-email-maheshb@google.com> <1306288567-1773-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:47513 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317Ab1EYJoL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 05:44:11 -0400
Received: by qyg14 with SMTP id 14so4373614qyg.19
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 02:44:10 -0700 (PDT)
In-Reply-To: <1306288567-1773-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/25 Mahesh Bandewar <maheshb@google.com>:
> Little bit cleanup by defining enum for all bits used. Also use those=
 enum
> values to redefine flags.
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> Changes since v1:
> =A0Split the patch into two pieces.
>
> =A0include/linux/netdevice.h | =A0100 +++++++++++++++++++++++++++++++=
-------------
> =A01 files changed, 70 insertions(+), 30 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index ca333e7..b4520b2 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -51,6 +51,7 @@
> =A0#ifdef CONFIG_DCB
> =A0#include <net/dcbnl.h>
> =A0#endif
> +#include <linux/netdev_features.h>

This should go to other part.

> =A0struct vlan_group;
> =A0struct netpoll_info;
> @@ -981,6 +982,49 @@ struct net_device_ops {
> =A0};
>
> =A0/*
> + * Net device feature bits; if you change something,
> + * also update netdev_features_strings[] in ethtool.c
> + */
> +enum netdev_features {
[...]

> + =A0 =A0 =A0 RESERVED16_BIT, =A0 =A0 =A0 =A0 /* the GSO_MASK reserve=
d bit 16 */
> + =A0 =A0 =A0 RESERVED17_BIT, =A0 =A0 =A0 =A0 /* the GSO_MASK reserve=
d bit 17 */
> + =A0 =A0 =A0 RESERVED18_BIT, =A0 =A0 =A0 =A0 /* the GSO_MASK reserve=
d bit 18 */
> + =A0 =A0 =A0 RESERVED19_BIT, =A0 =A0 =A0 =A0 /* the GSO_MASK reserve=
d bit 19 */
> + =A0 =A0 =A0 RESERVED20_BIT, =A0 =A0 =A0 =A0 /* the GSO_MASK reserve=
d bit 20 */
> + =A0 =A0 =A0 RESERVED21_BIT, =A0 =A0 =A0 =A0 /* the GSO_MASK reserve=
d bit 21 */
> + =A0 =A0 =A0 RESERVED22_BIT, =A0 =A0 =A0 =A0 /* the GSO_MASK reserve=
d bit 22 */
> + =A0 =A0 =A0 RESERVED23_BIT, =A0 =A0 =A0 =A0 /* the GSO_MASK reserve=
d bit 23 */

This could also define NETIF_F_GSO_SHIFT and name TSO and others.
Maybe like this:


NETIF_F_GSO_SHIFT, /* must =3D=3D 16, for now */
GSO_RESERVED0_BIT =3D NETIF_F_GSO_SHIFT,
GSO_RESERVED1_BIT,
=2E..
GSO_RESERVED7_BIT,
=2E.. (other bits)
> + =A0 =A0 =A0 /* Add you bit above this */

your.

> + =A0 =A0 =A0 ND_FEATURE_NUM_BITS, =A0 =A0 /* (LAST VALUE) Total bits=
 in use */

And here GSO aliases:

TSO_BIT =3D NETIF_F_GSO_SHIFT + SKB_GSO_TCPV4,
UFO_BIT =3D NETIF_F_GSO_SHIFT + SKB_GSO_UDP,
=2E..

Afther this is done, I can convert the feature-names table in
ethtool.c to use C99 array assignments, so that no one else will trip
on a missing comma or wrong entries order there.

About the bit names: NETIF_F_xxx_BIT?

Best Regards,
Micha=B3 Miros=B3aw
