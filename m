From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 01 Sep 2009 17:28:26 +0200
Message-ID: <4A9D3D9A.1030500@gmail.com>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1> <4A9D2DBF.8030200@trash.net> <4A9D3687.2020101@gmail.com> <alpine.DEB.1.10.0909011504030.12112@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	davem@linux-foundation.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33120 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837AbZIAP2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 11:28:33 -0400
In-Reply-To: <alpine.DEB.1.10.0909011504030.12112@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Tue, 1 Sep 2009, Eric Dumazet wrote:
>=20
>> Hmm, my bnx2 still displays correct info here (BCM5708S) ; so maybe =
Christoph has a
>> real multiqueue NIC adapter ? I thought he mentioned a mono queue NI=
C earlier.
>=20
> I have no clue if it is or not. I have never used those features.
>=20
> dmesg says:
>=20
> Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express
>=20
> Is that a multiqueue adapter?

You should see that in /proc/interrupts, if I correctly understand bnx2=
=2Ec

Just to be sure :
With following patch I got in my syslog :

[    8.789048] rx_rings=3D1 real_num_tx_queues=3D1
[    9.005700] rx_rings=3D1 real_num_tx_queues=3D1

So my bnx2 is mono-queue :(


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 06b9011..573d6b3 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6144,6 +6144,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 	bp->dev->real_num_tx_queues =3D bp->num_tx_rings;

 	bp->num_rx_rings =3D bp->irq_nvecs;
+	pr_err("rx_rings=3D%d real_num_tx_queues=3D%d\n", bp->num_rx_rings,  =
bp->num_tx_rings);
 }

 /* Called with rtnl_lock */


