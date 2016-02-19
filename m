From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: Add MDIO_INTR in GENETv2
Date: Thu, 18 Feb 2016 21:47:45 -0800
Message-ID: <56C6AC81.5020508@gmail.com>
References: <1455525733-11736-1-git-send-email-jaedon.shin@gmail.com>
 <56C2167A.1050109@gmail.com> <6BEA4AB8-F99A-4D8D-847F-C5691F3EE1DB@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Petri Gynther <pgynther@google.com>, opendmb@gmail.com
To: Jaedon Shin <jaedon.shin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34690 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756930AbcBSFrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 00:47:47 -0500
Received: by mail-pa0-f50.google.com with SMTP id fy10so44329249pac.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 21:47:47 -0800 (PST)
In-Reply-To: <6BEA4AB8-F99A-4D8D-847F-C5691F3EE1DB@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jaedon

Le 15/02/2016 19:12, Jaedon Shin a =E9crit :
>=20
> As you said, the part in bcmgenet_irq_task() is a problem.
>=20
> The bcmgenet using internal PHY should use phy_mac_interrupt() cause =
it has not
> PHY_POLL, and it depends on Ethernet MAC ISR.
>=20
> UMAC_IRQ_LINK_EVENT(LINK_UP and LINK_DOWN) was working correctly in G=
ENETv2,
> but (priv->hw_params->flags & GENET_HAS_MDIO_INTR) was blocking to ca=
ll
> phy_mac_interrupt(). I didn't find a reason through datasheet without=
 MDIO_INTR
> in GENETv2. However, I'm not sure using MDIO_INTR.
>=20
> Therefore if MDIO_INTR is not valid in GENETv2, I will send the patch=
 again=20
> to remove the first chicken GENET_HAS_MDIO_INTR after your confirm.

MDIO interrupts are wired in GENETv2, so the second part of your patch
is correct, I see now that you have submitted a proper fix for the Link
UP/DOWN event condition, and thank you for doing that. FWIW, all GENET
versions have link UP/DOWN interrupts.
