From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Bug#595265: linux-image-2.6.32-5-686: Nerwork card fails to come up again after suspend
Date: Wed, 20 Oct 2010 01:06:47 +0200
Message-ID: <20101019230647.GA17384@electric-eye.fr.zoreil.com>
References: <20100902154312.12515.10390.reportbug@bird.umass.edu>
 <201009211624.12744.aboelens@engin.umass.edu>
 <1286760421.2955.287.camel@localhost>
 <201010171116.00514.aboelens@engin.umass.edu>
 <1287361431.20865.133.camel@localhost>
 <20101018214536.GA14344@electric-eye.fr.zoreil.com>
 <1287442257.2361.11.camel@edumazet-laptop>
Reply-To: Francois Romieu <romieu@fr.zoreil.com>, 595265@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Ben Hutchings <ben@decadent.org.uk>,
        Arnout Boelens <aboelens@engin.umass.edu>, 595265@bugs.debian.org,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <bounce-debian-kernel=glddk-debian-kernel=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.595265.B595265.12875296632292@bugs.debian.org>
Content-Disposition: inline
In-Reply-To: <1287442257.2361.11.camel@edumazet-laptop>
List-URL: <http://lists.debian.org/debian-kernel/>
List-Post: <mailto:debian-kernel@lists.debian.org>
List-Help: <mailto:debian-kernel-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-kernel-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-kernel-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> :
> Le lundi 18 octobre 2010 =C3=A0 23:45 +0200, Francois Romieu a =C3=A9cr=
it :
[...]
> > Something like the patch made by Stanislaw at :
> > https://bugzilla.redhat.com/show_bug.cgi?id=3D502974
> >=20
>=20
> Seems to be down at this moment, patch is also here (and included in
> 2.6.36-rc8 ) :
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3Daeb19f6052b5e5c8a24aa444fbff73b84341beac

It's from the same author but it is not included in 2.6.36-stg yet :

Subject: [PATCH] r8169 init phy when resume

For unknown reasons some r8169 devices after resume operate at
100 Mb/s speed instead of 1000 Mb/s like before suspend. To fix
reset phy during resume.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 17382c3..a4ce127 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4847,6 +4847,9 @@ static int rtl8169_resume(struct device *device)
 {
 	struct pci_dev *pdev =3D to_pci_dev(device);
 	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct rtl8169_private *tp =3D netdev_priv(dev);
+
+	rtl8169_init_phy(dev, tp);
=20
 	if (!netif_running(dev))
 		goto out;
--=20
1.7.1
