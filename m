From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 05/10] net: Disable NOCACHE_COPY by default
Date: Wed, 13 Jul 2011 17:44:44 -0700
Message-ID: <CA+mtBx-zKBV+gd-1gNJTV4SBZtcQUpoYbxvOKn0eeOO36hoMpg@mail.gmail.com>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	<245234f4964a304e6b427b7f1895d2c30d38aabd.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:32487 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab1GNAos convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 20:44:48 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p6E0ik4v017539
	for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 17:44:46 -0700
Received: from pva4 (pva4.prod.google.com [10.241.209.4])
	by kpbe17.cbf.corp.google.com with ESMTP id p6E0ii62004567
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 17:44:44 -0700
Received: by pva4 with SMTP id 4so7655663pva.16
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 17:44:44 -0700 (PDT)
In-Reply-To: <245234f4964a304e6b427b7f1895d2c30d38aabd.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2011 at 5:10 PM, Micha=C5=82 Miros=C5=82aw
<mirq-linux@rere.qmqm.pl> wrote:
>
> Disable NOCACHE_COPY by default as there's no reliable way to tell
> in advance what device(s) will take the packet. Also, allow the
> setting to be inherited by VLAN devices.
>

What problem is this addressing?  Is this just to get rid of the
NETIF_NO_CSUM bit, or is there an issue with nocachecopy being enabled
by default?

Tom

> This is the last use of NETIF_F_NO_CSUM.
>
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
> =C2=A0net/core/dev.c | =C2=A0 11 +++++------
> =C2=A01 files changed, 5 insertions(+), 6 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index e57be02..7b9e2f4 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5480,13 +5480,12 @@ int register_netdevice(struct net_device *dev=
)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->features |=3D NETIF_F_SOFT_FEATURES;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->wanted_features =3D dev->features & d=
ev->hw_features;
>
> - =C2=A0 =C2=A0 =C2=A0 /* Turn on no cache copy if HW is doing checks=
um */
> + =C2=A0 =C2=A0 =C2=A0 /* Allow changing no-cache copy but disable it=
 by default
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* as there's no reliable way to tell wha=
t device(s) will take
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* the packet. Allow the setting to be in=
herited to VLANs.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->hw_features |=3D NETIF_F_NOCACHE_COPY=
;
> - =C2=A0 =C2=A0 =C2=A0 if ((dev->features & NETIF_F_ALL_CSUM) &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !(dev->features & NETIF_F_NO_CSU=
M)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->wanted_featur=
es |=3D NETIF_F_NOCACHE_COPY;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->features |=3D=
 NETIF_F_NOCACHE_COPY;
> - =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 dev->vlan_features |=3D NETIF_F_NOCACHE_COPY;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Make NETIF_F_HIGHDMA inheritable to VLA=
N devices.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> --
> 1.7.5.4
>
