From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: ibmveth runtime errors
Date: Thu, 28 Apr 2011 12:11:24 +1000
Message-ID: <20110428121124.39c036ff.sfr@canb.auug.org.au>
References: <20110427144901.4c3f79b3.sfr@canb.auug.org.au>
	<20110427103622.GA22781@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ppc-dev <linuxppc-dev@lists.ozlabs.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110427103622.GA22781@rere.qmqm.pl>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Micha=C5=82,

On Wed, 27 Apr 2011 12:36:22 +0200 Micha=C5=82 Miros=C5=82aw <mirq-linu=
x@rere.qmqm.pl> wrote:
>
> Please test the following patch. It's just a blind guess, as this err=
or
> is not descriptive.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
>=20
> ---
>=20
> net: ibmveth: force reconfiguring checksum settings on startup
>=20
> Commit b9367bf3ee6d ("net: ibmveth: convert to hw_features") accident=
ally
> removed call to ibmveth_set_csum_offload() in ibmveth_probe(). Put th=
e
> call back where it was, but with additional error checking provided
> by ibmveth_set_features().
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
>=20
> ---
>  drivers/net/ibmveth.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
> index 4855f1f..0d1fea2 100644
> --- a/drivers/net/ibmveth.c
> +++ b/drivers/net/ibmveth.c
> @@ -1397,6 +1397,8 @@ static int __devinit ibmveth_probe(struct vio_d=
ev *dev,
> =20
>  	netdev_dbg(netdev, "registering netdev...\n");
> =20
> +	ibmveth_set_features(dev, dev->features);
> +
>  	rc =3D register_netdev(netdev);
> =20
>  	if (rc) {

This worked after I changed both "dev"s to "netdev".  And the boot
succedded.  I will apply this patchg to linux-next today and hopefully
Dave can apply it to the net tree.  I have added a copy fo the patch I
used below.

=46rom: =3D?UTF-8?q?Micha=3DC5=3D82=3D20Miros=3DC5=3D82aw?=3D <mirq-lin=
ux@rere.qmqm.pl>
Date: Thu, 28 Apr 2011 11:59:15 +1000
Subject: [PATCH] net: ibmveth: force reconfiguring checksum settings on
 startup
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

Commit b9367bf3ee6d ("net: ibmveth: convert to hw_features") accidental=
ly
removed call to ibmveth_set_csum_offload() in ibmveth_probe(). Put the
call back where it was, but with additional error checking provided
by ibmveth_set_features().

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
[sfr: dev -> netdev]
Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ibmveth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 4855f1f..be3fe71 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1397,6 +1397,8 @@ static int __devinit ibmveth_probe(struct vio_dev=
 *dev,
=20
 	netdev_dbg(netdev, "registering netdev...\n");
=20
+	ibmveth_set_features(netdev, netdev->features);
+
 	rc =3D register_netdev(netdev);
=20
 	if (rc) {
--=20
1.7.4.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
