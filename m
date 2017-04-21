From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: Re: [PATCH v1] net: phy: fix auto-negotiation stall due to unavailable interrupt
Date: Fri, 21 Apr 2017 17:42:14 +0300
Message-ID: <5C544A66-7895-4543-808B-764A7B1A4E0A@gmail.com>
References: <1492686004-30527-1-git-send-email-al.kochet@gmail.com> <1492686004-30527-2-git-send-email-al.kochet@gmail.com> <2f44a2db-da7a-2ca9-ea5e-6cc551c3008c@ti.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Madalin Bucur <madalin.bucur@nxp.com>
To: Roger Quadros <rogerq@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36080 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424006AbdDUSxm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:53:42 -0400
In-Reply-To: <2f44a2db-da7a-2ca9-ea5e-6cc551c3008c@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 21 =D0=B0=D0=BF=D1=80. 2017 =D0=B3., =D0=B2 17:18, Roger Quadros =
<rogerq@ti.com> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0):
>=20
> I think the following commit broke functionality with interrupt driven =
PHYs
> 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not =
polling.")

Probably this one[1] broke, according to Alexandre=E2=80=99s commit[2].
And it was since Nov 16 2015. But it was hidden by some other commits.

For Roger problem became visible after 3c293f4e08b5 ("net: phy:
Trigger state machine on state change and not polling.=C2=BB),

For my problem became visible after 529ed1275263 ("net: phy: phy drivers
should not set SUPPORTED_[Asym_]Pause=C2=BB). As commit 529ed1275263=20
removed SUPPORTED_Pause flag from PHY advertising property and
genphy_config_aneg() began to skip PHY auto-negotiation.

Alexander.

[1] Fixes: 321beec5047a (net: phy: Use interrupts when available in =
NOLINK state)
     =
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/=
?id=3D321beec5047af83db90c88114b7e664b156f49fe
[2] =
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/=
?id=3D99f81afc139c6edd14d77a91ee91685a414a1c66
