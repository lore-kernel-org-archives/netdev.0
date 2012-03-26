From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: [PATCH] net/vlan: withdraw VLAN ID attribute from GVRP on VLAN
 device stop
Date: Mon, 26 Mar 2012 13:29:45 +0200
Message-ID: <4F705329.10208@dti2.net>
References: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu> <1332715437-16278-2-git-send-email-david.ward@ll.mit.edu>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:57061 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932171Ab2CZL3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 07:29:49 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.2)
	with ESMTP id md50021704946.msg
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 13:29:47 +0200
In-Reply-To: <1332715437-16278-2-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 26/03/2012 0:43, David Ward escribi=F3:
> When a VLAN device is stopped which has VLAN_FLAG_GVRP set, the VLAN
> ID attribute that was previously declared by GVRP must be withdrawn.
>=20

	Hmm, maybe I am missing something but I think it only makes sense to w=
ithdrawn
the attribute when you delete the interface, and vlan_dev_stop() it's c=
alled if
you just put the interface down. It's better for the network convergenc=
e to not
signal the switches just for this. IMHO.


> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> ---
>  net/8021q/vlan_dev.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 9988d4a..df86dd0 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -319,6 +319,9 @@ static int vlan_dev_stop(struct net_device *dev)
>  	struct vlan_dev_priv *vlan =3D vlan_dev_priv(dev);
>  	struct net_device *real_dev =3D vlan->real_dev;
> =20
> +	if (vlan->flags & VLAN_FLAG_GVRP)
> +		vlan_gvrp_request_leave(dev);
> +
>  	dev_mc_unsync(real_dev, dev);
>  	dev_uc_unsync(real_dev, dev);
>  	if (dev->flags & IFF_ALLMULTI)
