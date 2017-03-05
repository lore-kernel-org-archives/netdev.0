From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net 3/7] bnx2x: fix possible overrun of VFPF multicast
 addresses array
Date: Sun, 5 Mar 2017 09:55:42 +0000
Message-ID: <BL2PR07MB230637FFDAFE26D2052B269F8D2D0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
 <20170303160834.4125-4-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>
To: Michal Schmidt <mschmidt@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0081.outbound.protection.outlook.com ([104.47.41.81]:16897
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751003AbdCEKdf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 5 Mar 2017 05:33:35 -0500
In-Reply-To: <20170303160834.4125-4-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -883,6 +883,15 @@ int bnx2x_vfpf_set_mcast(struct net_device *dev)
>  	/* Get Rx mode requested */
>  	DP(NETIF_MSG_IFUP, "dev->flags =3D %x\n", dev->flags);
>=20
> +	/* We support PFVF_MAX_MULTICAST_PER_VF mcast addresses tops
> */
> +	if (netdev_mc_count(dev) > PFVF_MAX_MULTICAST_PER_VF) {
> +		DP(NETIF_MSG_IFUP,
> +		   "VF supports not more than %d multicast MAC
> addresses\n",
> +		   PFVF_MAX_MULTICAST_PER_VF);
> +		rc =3D -EINVAL;
> +		goto out;
> +	}
> +
>  	netdev_for_each_mc_addr(ha, dev) {
>  		DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
>  		   bnx2x_mc_addr(ha));

You can push it even higher; It's a simply sanity and can be done
prior to bnx2x_vfpf_prep(), in which case you'd be able to simply return
instead of touching the goto label and passing through
the prep()/finalize() sequence.

BTW, just to mention that this is artificial limitation due to the HW chann=
el.
If we'd be really motivated we can have VFs that can configure as many
approx. multicasts addresses as they want [similar to PFs], although that
would require a new PF driver as well [that supports a revised implementati=
on].
