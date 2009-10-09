From: "Gole, Anant" <anantgole-l0cyMroinI0@public.gmane.org>
Subject: RE: [PATCH] can: make the number of echo skb's configurable
Date: Fri, 9 Oct 2009 14:31:09 +0530
Message-ID: <2A3DCF3DA181AD40BDE86A3150B27B6B02F67E1776@dbde02.ent.ti.com>
References: <4ACEF187.207@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Sebastian-XecQL68PM4x789tOGE2Ojw@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, Linux Netdev List
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4ACEF187.207-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Wolfgang Grandegger [mailto:wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org]
>Sent: Friday, October 09, 2009 1:47 PM
>To: Linux Netdev List
>Cc: SocketCAN Core Mailing List; Gole, Anant; Sebastian Haas
>Subject: [PATCH] can: make the number of echo skb's configurable
>
>This patch allows the CAN controller driver to define the number of echo
>skb's used for the local loopback (echo), as suggested by Kurt Van
>Dijck, with the function:
>
>  struct net_device *alloc_candev(int sizeof_priv,
>                                  unsigned int echo_skb_max);
>
>The CAN drivers have been adapted accordingly. For the ems_usb driver,
>as suggested by Sebastian Haas, the number of echo skb's has been
>increased to 10, which improves the transmission performance a lot.
>
>Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
>Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
>---

[snip]

>Index: net-next-2.6/drivers/net/can/ti_hecc.c
>===================================================================
>--- net-next-2.6.orig/drivers/net/can/ti_hecc.c
>+++ net-next-2.6/drivers/net/can/ti_hecc.c
>@@ -74,10 +74,6 @@ MODULE_VERSION(HECC_MODULE_VERSION);
> #define HECC_MB_TX_SHIFT	2 /* as per table above */
> #define HECC_MAX_TX_MBOX	BIT(HECC_MB_TX_SHIFT)
>
>-#if (HECC_MAX_TX_MBOX > CAN_ECHO_SKB_MAX)
>-#error "HECC: MAX TX mailboxes should be equal or less than
>CAN_ECHO_SKB_MAX"
>-#endif
>-
> #define HECC_TX_PRIO_SHIFT	(HECC_MB_TX_SHIFT)
> #define HECC_TX_PRIO_MASK	(MAX_TX_PRIO << HECC_MB_TX_SHIFT)
> #define HECC_TX_MB_MASK		(HECC_MAX_TX_MBOX - 1)
>@@ -902,7 +898,7 @@ static int ti_hecc_probe(struct platform
> 		goto probe_exit_free_region;
> 	}
>
>-	ndev = alloc_candev(sizeof(struct ti_hecc_priv));
>+	ndev = alloc_candev(sizeof(struct ti_hecc_priv), HECC_MAX_TX_MBOX);
> 	if (!ndev) {
> 		dev_err(&pdev->dev, "alloc_candev failed\n");
> 		err = -ENOMEM;

Ack for ti_hecc driver change. Thanks for the patch.

Regards,
Anant
