From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] fec_main iMX6Q DMA-API: device driver tries to free DMA
 memory it has not allocated
Date: Wed, 3 Sep 2014 06:36:58 +0000
Message-ID: <0d904edc4b834c059174f712044965d3@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1409658022-30166-1-git-send-email-moon.linux@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Anand Moon <moon.linux@yahoo.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	=?iso-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0237.outbound.protection.outlook.com ([207.46.163.237]:17813
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751201AbaICGhB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 02:37:01 -0400
In-Reply-To: <1409658022-30166-1-git-send-email-moon.linux@yahoo.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Anand Moon <moon.linux@yahoo.com> Sent: Tuesday, September 02, =
2014 7:40 PM
>To: David S. Miller; Duan Fugang-B38611; Russell King; Li Frank-B20596=
;
>Estevam Fabio-R49496; Uwe Kleine-K=F6nig
>Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Anand Moon
>Subject: [PATCH] fec_main iMX6Q DMA-API: device driver tries to free D=
MA
>memory it has not allocated
>
>Changes fix below warning:
>
>[  167.331417] ------------[ cut here ]------------ [  167.331456] WAR=
NING:
>CPU: 0 PID: 1887 at lib/dma-debug.c:1080 check_unmap+0x7e4/0xb90()
>[  167.331469] fec 2188000.ethernet: DMA-API: device driver tries to f=
ree
>DMA memory it has not allocated [device address=3D0x0000000000000000]
>[size=3D54 bytes] [  167.331477] Modules linked in: zram lz4_compress =
rfcomm
>bnep bluetooth arc4 rt2800usb rt2800lib rt2x00usb rt2x00lib mac80211
>cfg80211 crc_ccitt rfkill rtc_snvs
>[  167.331560] CPU: 0 PID: 1887 Comm: sshd Tainted: G        W 3.17.0-=
rc3-
>armv7-x1 #1
>[  167.331592] [<c001990c>] (unwind_backtrace) from [<c00141bc>]
>(show_stack+0x20/0x24) [  167.331618] [<c00141bc>] (show_stack) from
>[<c0a8601c>] (dump_stack+0x9c/0xbc) [  167.331647] [<c0a8601c>]
>(dump_stack) from [<c005586c>] (warn_slowpath_common+0x80/0x9c)
>[  167.331665] [<c005586c>] (warn_slowpath_common) from [<c00558c8>]
>(warn_slowpath_fmt+0x40/0x48) [  167.331682] [<c00558c8>]
>(warn_slowpath_fmt) from [<c05c377c>] (check_unmap+0x7e4/0xb90)
>[  167.331699] [<c05c377c>] (check_unmap) from [<c05c3b98>]
>(debug_dma_unmap_page+0x70/0x78) [  167.331725] [<c05c3b98>]
>(debug_dma_unmap_page) from [<c07678f0>] (fec_enet_rx_napi+0x5dc/0x8bc=
)
>[  167.331751] [<c07678f0>] (fec_enet_rx_napi) from [<c0919ce0>]
>(net_rx_action+0x170/0x36c) [  167.331769] [<c0919ce0>] (net_rx_action=
)
>from [<c005acbc>] (__do_softirq+0x1a0/0x558) [  167.331783] [<c005acbc=
>]
>(__do_softirq) from [<c005b3d0>] (irq_exit+0xd0/0x114) [  167.331804]
>[<c005b3d0>] (irq_exit) from [<c001064c>] (handle_IRQ+0x54/0xa0)
>[  167.331820] [<c001064c>] (handle_IRQ) from [<c0008868>]
>(gic_handle_irq+0x3c/0x6c) [  167.331839] [<c0008868>] (gic_handle_irq=
)
>from [<c0a8ef84>] (__irq_svc+0x44/0x5c) [  167.331849] Exception
>stack(0xe41fbc40 to 0xe41fbc88) [  167.331862] bc40: c00abd3c c0a8e0f0
>00000000 00000000 a0000013 c1aa83c0 c1aa83c0 c1aa83c0 [  167.331874] b=
c60:
>00000001 000005b4 00000002 e41fbc9c c117d6e0 e41fbc88 c00abadc c0a8e0f=
4
>[  167.331883] bc80: 60000013 ffffffff [  167.331899] [<c0a8ef84>]
>(__irq_svc) from [<c0a8e0f4>] (_raw_spin_unlock_irqrestore+0x44/0x6c)
>[  167.331918] [<c0a8e0f4>] (_raw_spin_unlock_irqrestore) from [<c00d8=
464>]
>(mod_timer+0x13c/0x2c0) [  167.331938] [<c00d8464>] (mod_timer) from
>[<c08ff824>] (sk_reset_timer+0x28/0x50) [  167.331957] [<c08ff824>]
>(sk_reset_timer) from [<c0978008>] (tcp_rearm_rto+0xa0/0x104)
>[  167.331973] [<c0978008>] (tcp_rearm_rto) from [<c097b574>]
>(tcp_event_new_data_sent+0xa0/0xa4)
>[  167.331989] [<c097b574>] (tcp_event_new_data_sent) from [<c097d518>=
]
>(tcp_write_xmit+0x1cc/0xd2c) [  167.332004] [<c097d518>] (tcp_write_xm=
it)
>from [<c097e450>] (tcp_push_one+0x44/0x50) [  167.332018] [<c097e450>]
>(tcp_push_one) from [<c096f3b8>] (tcp_sendmsg+0xbf8/0xd68) [  167.3320=
39]
>[<c096f3b8>] (tcp_sendmsg) from [<c09a17fc>] (inet_sendmsg+0x15c/0x25c=
)
>[  167.332064] [<c09a17fc>] (inet_sendmsg) from [<c08f9e74>]
>(sock_aio_write+0xf8/0x118) [  167.332091] [<c08f9e74>] (sock_aio_writ=
e)
>from [<c01e9560>] (do_sync_write+0x90/0xb8) [  167.332108] [<c01e9560>=
]
>(do_sync_write) from [<c01ea12c>] (vfs_write+0x158/0x1e0) [  167.33212=
3]
>[<c01ea12c>] (vfs_write) from [<c01ea7e4>] (SyS_write+0x54/0xb0)
>[  167.332140] [<c01ea7e4>] (SyS_write) from [<c000fc20>]
>(ret_fast_syscall+0x0/0x48) [  167.332150] ---[ end trace
>e95c276a4fb5c451 ]---
>
>Signed-off-by: Anand Moon <moon.linux@yahoo.com>
>---
> drivers/net/ethernet/freescale/fec_main.c | 15 ++++++++++-----
> 1 file changed, 10 insertions(+), 5 deletions(-)
>
>diff --git a/drivers/net/ethernet/freescale/fec_main.c
>b/drivers/net/ethernet/freescale/fec_main.c
>index 89355a7..b1d9b79 100644
>--- a/drivers/net/ethernet/freescale/fec_main.c
>+++ b/drivers/net/ethernet/freescale/fec_main.c
>@@ -444,8 +444,9 @@ dma_mapping_error:
> 	bdp =3D fep->cur_tx;
> 	for (i =3D 0; i < frag; i++) {
> 		bdp =3D fec_enet_get_nextdesc(bdp, fep);
>-		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
>-				bdp->cbd_datlen, DMA_TO_DEVICE);
>+		if (bdp->cbd_bufaddr > 0)
>+			dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
>+					bdp->cbd_datlen, DMA_TO_DEVICE);
> 	}
I don't think there need to check cbd_bufaddr ?

> 	return NETDEV_TX_OK;
> }
>@@ -1106,7 +1107,8 @@ fec_enet_tx(struct net_device *ndev)
>
> 		skb =3D fep->tx_skbuff[index];
> 		fep->tx_skbuff[index] =3D NULL;
>-		if (!IS_TSO_HEADER(fep, bdp->cbd_bufaddr))
>+		if (!IS_TSO_HEADER(fep, bdp->cbd_bufaddr) &&
>+				bdp->cbd_bufaddr > 0)
> 			dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
> 					bdp->cbd_datlen, DMA_TO_DEVICE);
> 		bdp->cbd_bufaddr =3D 0;
>@@ -2111,8 +2113,11 @@ static void fec_enet_free_buffers(struct net_de=
vice
>*ndev)
> 		skb =3D fep->rx_skbuff[i];
> 		fep->rx_skbuff[i] =3D NULL;
> 		if (skb) {
>-			dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
>-					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
>+			if (bdp->cbd_bufaddr > 0)
>+				dma_unmap_single(&fep->pdev->dev,
>+						bdp->cbd_bufaddr,
>+						FEC_ENET_RX_FRSIZE,
>+						DMA_FROM_DEVICE);
> 			dev_kfree_skb(skb);
> 		}
> 		bdp =3D fec_enet_get_nextdesc(bdp, fep);
>--
>1.9.1

Thanks,
Andy
