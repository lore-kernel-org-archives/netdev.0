From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [v2 2/9] dpaa_eth: add support for DPAA Ethernet
Date: Sat, 08 Aug 2015 10:38:34 -0700
Message-ID: <55C63E9A.5010704@gmail.com>
References: <1438789289-16304-1-git-send-email-madalin.bucur@freescale.com> <1438789289-16304-3-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, scottwood@freescale.com,
	igal.liberman@freescale.com, ppc@mindchasers.com, joe@perches.com,
	pebolle@tiscali.nl, joakim.tjernlund@transmode.se
To: madalin.bucur@freescale.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438789289-16304-3-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 08/05/15 08:41, Madalin Bucur a =C3=A9crit :
> This introduces the Freescale Data Path Acceleration Architecture
> (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> the Freescale DPAA QorIQ platforms.
>=20
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> ---
[snip]
> +
> +if FSL_DPAA_ETH
> +
> +config FSL_DPAA_CS_THRESHOLD_1G
> +	hex "Egress congestion threshold on 1G ports"
> +	range 0x1000 0x10000000
> +	default "0x06000000"

This sounds like something you would want to be able to configure at
runtime, either via private sysfs attributes, or better, using ethtool
and either a newly introduced set of tunables, or creating a private
driver API for this.

> +	---help---
> +	  The size in bytes of the egress Congestion State notification thr=
eshold on 1G ports.
> +	  The 1G dTSECs can quite easily be flooded by cores doing Tx in a =
tight loop
> +	  (e.g. by sending UDP datagrams at "while(1) speed"),
> +	  and the larger the frame size, the more acute the problem.
> +	  So we have to find a balance between these factors:
> +	       - avoiding the device staying congested for a prolonged time=
 (risking
> +                 the netdev watchdog to fire - see also the tx_timeo=
ut module param);
> +               - affecting performance of protocols such as TCP, whi=
ch otherwise
> +	         behave well under the congestion notification mechanism;
> +	       - preventing the Tx cores from tightly-looping (as if the co=
ngestion
> +	         threshold was too low to be effective);
> +	       - running out of memory if the CS threshold is set too high.
> +
> +config FSL_DPAA_CS_THRESHOLD_10G
> +	hex "Egress congestion threshold on 10G ports"
> +	range 0x1000 0x20000000
> +	default "0x10000000"
> +	---help ---
> +	  The size in bytes of the egress Congestion State notification thr=
eshold on 10G ports.
> +
> +config FSL_DPAA_INGRESS_CS_THRESHOLD
> +	hex "Ingress congestion threshold on FMan ports"
> +	default "0x10000000"
> +	---help---
> +	  The size in bytes of the ingress tail-drop threshold on FMan port=
s.
> +	  Traffic piling up above this value will be rejected by QMan and d=
iscarded by FMan.

Same here.
--=20
=46lorian
