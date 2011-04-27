From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: linux-next: ibmveth runtime errors
Date: Wed, 27 Apr 2011 12:36:22 +0200
Message-ID: <20110427103622.GA22781@rere.qmqm.pl>
References: <20110427144901.4c3f79b3.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ppc-dev <linuxppc-dev@lists.ozlabs.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110427144901.4c3f79b3.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2011 at 02:49:01PM +1000, Stephen Rothwell wrote:
> For the last couple of days, linux-next booting on a few of our Power
> partitions (but not all) have produced this error (over and over):
>=20
> ibmveth 3000000b: eth0: tx: h_send_logical_lan failed with rc=3D-4
>=20
> Linus' tree seems to boot fine on these partitions.  The only commit
> directly affecting ibmveth in linux-next is b9367bf3ee6d ("net: ibmve=
th:
> convert to hw_features") which first appeared in next-20110421 which =
is
> also the first one that failed.

Please test the following patch. It's just a blind guess, as this error
is not descriptive.

Best Regards,
Micha=B3 Miros=B3aw

---

net: ibmveth: force reconfiguring checksum settings on startup

Commit b9367bf3ee6d ("net: ibmveth: convert to hw_features") accidental=
ly
removed call to ibmveth_set_csum_offload() in ibmveth_probe(). Put the
call back where it was, but with additional error checking provided
by ibmveth_set_features().

Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>

---
 drivers/net/ibmveth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 4855f1f..0d1fea2 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1397,6 +1397,8 @@ static int __devinit ibmveth_probe(struct vio_dev=
 *dev,
=20
 	netdev_dbg(netdev, "registering netdev...\n");
=20
+	ibmveth_set_features(dev, dev->features);
+
 	rc =3D register_netdev(netdev);
=20
 	if (rc) {
--=20
1.7.2.5
