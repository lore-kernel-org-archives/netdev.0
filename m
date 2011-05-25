From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCHv2] net: Define enum for the bits used in features.
Date: Wed, 25 May 2011 11:05:30 -0700
Message-ID: <BANLkTiks57xLjr4qvQmqvXFjxYUkyirs4g@mail.gmail.com>
References: <1306263162-2022-1-git-send-email-maheshb@google.com>
 <1306288567-1773-1-git-send-email-maheshb@google.com> <BANLkTik4KYrR4vYm1R_hYNbwFjQ79FEoHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:56994 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722Ab1EYSGD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 14:06:03 -0400
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p4PI61v7027781
	for <netdev@vger.kernel.org>; Wed, 25 May 2011 11:06:01 -0700
Received: from bwz18 (bwz18.prod.google.com [10.188.26.18])
	by wpaz24.hot.corp.google.com with ESMTP id p4PI5mFB018826
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 25 May 2011 11:05:50 -0700
Received: by bwz18 with SMTP id 18so7686504bwz.29
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 11:05:50 -0700 (PDT)
In-Reply-To: <BANLkTik4KYrR4vYm1R_hYNbwFjQ79FEoHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 25, 2011 at 2:43 AM, Micha=C5=82 Miros=C5=82aw <mirqus@gmai=
l.com> wrote:
> 2011/5/25 Mahesh Bandewar <maheshb@google.com>:
>> Little bit cleanup by defining enum for all bits used. Also use thos=
e enum
>> values to redefine flags.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>> Changes since v1:
>> =C2=A0Split the patch into two pieces.
>>
>> =C2=A0include/linux/netdevice.h | =C2=A0100 ++++++++++++++++++++++++=
+++++++-------------
>> =C2=A01 files changed, 70 insertions(+), 30 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index ca333e7..b4520b2 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -51,6 +51,7 @@
>> =C2=A0#ifdef CONFIG_DCB
>> =C2=A0#include <net/dcbnl.h>
>> =C2=A0#endif
>> +#include <linux/netdev_features.h>
>
> This should go to other part.
>
Ahh! split mishap!

>> =C2=A0struct vlan_group;
>> =C2=A0struct netpoll_info;
>> @@ -981,6 +982,49 @@ struct net_device_ops {
>> =C2=A0};
>>
>> =C2=A0/*
>> + * Net device feature bits; if you change something,
>> + * also update netdev_features_strings[] in ethtool.c
>> + */
>> +enum netdev_features {
> [...]
>
>> + =C2=A0 =C2=A0 =C2=A0 RESERVED16_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 /=
* the GSO_MASK reserved bit 16 */
>> + =C2=A0 =C2=A0 =C2=A0 RESERVED17_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 /=
* the GSO_MASK reserved bit 17 */
>> + =C2=A0 =C2=A0 =C2=A0 RESERVED18_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 /=
* the GSO_MASK reserved bit 18 */
>> + =C2=A0 =C2=A0 =C2=A0 RESERVED19_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 /=
* the GSO_MASK reserved bit 19 */
>> + =C2=A0 =C2=A0 =C2=A0 RESERVED20_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 /=
* the GSO_MASK reserved bit 20 */
>> + =C2=A0 =C2=A0 =C2=A0 RESERVED21_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 /=
* the GSO_MASK reserved bit 21 */
>> + =C2=A0 =C2=A0 =C2=A0 RESERVED22_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 /=
* the GSO_MASK reserved bit 22 */
>> + =C2=A0 =C2=A0 =C2=A0 RESERVED23_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 /=
* the GSO_MASK reserved bit 23 */
>
> This could also define NETIF_F_GSO_SHIFT and name TSO and others.
> Maybe like this:
>
>
> NETIF_F_GSO_SHIFT, /* must =3D=3D 16, for now */
> GSO_RESERVED0_BIT =3D NETIF_F_GSO_SHIFT,
> GSO_RESERVED1_BIT,
> ...
> GSO_RESERVED7_BIT,
> ... (other bits)
>
Yes, I was thinking about that but then thought that itself will
deserve a separate patch.

>> + =C2=A0 =C2=A0 =C2=A0 /* Add you bit above this */
>
> your.
>
>> + =C2=A0 =C2=A0 =C2=A0 ND_FEATURE_NUM_BITS, =C2=A0 =C2=A0 /* (LAST V=
ALUE) Total bits in use */
>
> And here GSO aliases:
>
> TSO_BIT =3D NETIF_F_GSO_SHIFT + SKB_GSO_TCPV4,
> UFO_BIT =3D NETIF_F_GSO_SHIFT + SKB_GSO_UDP,
> ...
>
> Afther this is done, I can convert the feature-names table in
> ethtool.c to use C99 array assignments, so that no one else will trip
> on a missing comma or wrong entries order there.
>
> About the bit names: NETIF_F_xxx_BIT?
>
I thought it was getting longer so tried to trim it, but don't have
reservations against it.

--mahesh..

> Best Regards,
> Micha=C5=82 Miros=C5=82aw
>
