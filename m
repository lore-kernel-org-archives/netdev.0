From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: Re: [PATCH] net: phy: fix auto-negotiation stall due to unavailable interrupt
Date: Wed, 19 Apr 2017 19:53:24 +0300
Message-ID: <EA84802B-82E6-4485-A92E-E2751A84D4D0@gmail.com>
References: <1492609604-16359-1-git-send-email-al.kochet@gmail.com> <24E19B31-CCD8-4032-B17B-D226D4DB881D@gmail.com> <754f7cfe-6914-570a-d0e5-4a26b6787281@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        andrew@lunn.ch, Roger Quadros <rogerq@ti.com>, nsekhar@ti.com,
        kyle.roeschley@ni.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <754f7cfe-6914-570a-d0e5-4a26b6787281@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 19 =D0=B0=D0=BF=D1=80. 2017 =D0=B3., =D0=B2 19:32, Florian Fainelli =
<f.fainelli@gmail.com> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0):=

>=20
> http://patchwork.ozlabs.org/patch/743773/
>=20
> Roger can you also test Alexander's patch?

If MAC use phy_start_aneg() instead of phy_start() my patch will not =
work as
expected. Roger, if patch don=E2=80=99t work for you please check what =
MAC bring up PHY using
phy_start():

http://patchwork.ozlabs.org/patch/752308/

Is it correct to start PHY inside MAC probe using phy_start_aneg()? Or =
phy_start() must be used?

And probably this tags should be added for my patch:
Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change =
and not polling.")
Cc: stable <stable@vger.kernel.org> # v4.9+

Because I bisected to commit 529ed1275263 ("net: phy: phy drivers
should not set SUPPORTED_[Asym_]Pause=C2=BB) that looks pretty good.

Also, there is another issue I found. link_timeout doesn=E2=80=99t work =
for interrupt driven PHY.
It is possible to implement timer to handle this case.
Florian, what do you think? Should this be fixed?

Alexander.
