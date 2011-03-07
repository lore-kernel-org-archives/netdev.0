From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] net: enhance the documentation for
 rx_handler.
Date: Mon, 7 Mar 2011 10:54:46 +0100
Message-ID: <20110307095445.GB2832@psychotron.brq.redhat.com>
References: <4D725BD9.6000706@gmail.com>
 <1299441608-25482-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	eric.dumazet@gmail.com, kaber@trash.net, fubar@us.ibm.com,
	andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?= <nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10711 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755533Ab1CGJy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 04:54:56 -0500
Content-Disposition: inline
In-Reply-To: <1299441608-25482-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Mar 06, 2011 at 09:00:08PM CET, nicolas.2p.debian@free.fr wrote:
>Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>---
>This apply on top of Jiri's last patch serie, including the last one t=
hat
>commented the RX_HANDLER_* values.
>
> include/linux/netdevice.h |   53 ++++++++++++++++++++++++++++++++++++=
++------
> net/core/dev.c            |    2 +
> 2 files changed, 47 insertions(+), 8 deletions(-)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 26e03f9..0c9dc93 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -390,15 +390,52 @@ enum gro_result {
> };
> typedef enum gro_result gro_result_t;
>=20
>+/**
>+ * enum rx_handler_result - Possible return values for rx_handlers.
>+ * @RX_HANDLER_CONSUMED: skb was consumed by rx_handler, do not proce=
ss it
>+ * further.
>+ * @RX_HANDLER_ANOTHER: Do another round in receive path. This is ind=
icated in
>+ * case skb->dev was changed by rx_handler.
>+ * @RX_HANDLER_EXACT: Force exact delivery, no wildcard.
>+ * @RX_HANDLER_PASS: Do nothing, passe the skb as if no rx_handler wa=
s called.
>+ *
>+ * rx_handlers are functions called from inside __netif_receive_skb()=
, to do
>+ * special processing of the skb, prior to delivery to protocol handl=
ers.
>+ *
>+ * Currently, a net_device can only have a single rx_handler register=
ed. Trying
>+ * to register a second rx_handler will return -EBUSY.
>+ *
>+ * To register a rx_handler on a net_device, use netdev_rx_handler_re=
gister().
>+ * To unregister a rx_handler on a net_device, use
>+ * netdev_rx_handler_unregister().
>+ *
>+ * Upon return, rx_handler is expected to tell __netif_receive_skb() =
what to
>+ * do with the skb.
>+ *
>+ * If the rx_handler consumed to skb in some way, it should return
>+ * RX_HANDLER_CONSUMED. This is appropriate when the rx_handler arran=
ged for
>+ * the skb to be delivered in some other ways.
>+ *
>+ * If the rx_handler changed skb->dev, to divert the skb to another
>+ * net_device, it should return RX_HANDLER_ANOTHER. The rx_handler fo=
r the
>+ * new device will be called if it exists.
>+ *
>+ * If the rx_handler consider the skb should be ignored, it should re=
turn
>+ * RX_HANDLER_EXACT. The skb will only be delivered to protocol handl=
ers that
>+ * are registred on exact device (ptype->dev =3D=3D skb->dev).
>+ *
>+ * If the rx_handler didn't changed skb->dev, but want the skb to be =
normally=20
>+ * delivered, it should return RX_HANDLER_PASS.
>+ *=20
>+ * A device without a registered rx_handler will behave as if rx_hand=
ler
>+ * returned RX_HANDLER_PASS.
>+ */
>+
> enum rx_handler_result {
>-	RX_HANDLER_CONSUMED,	/* skb was consumed by rx_handler,
>-				   do not process it further. */
>-	RX_HANDLER_ANOTHER,	/* Do another round in receive path.
>-				   This is indicated in case skb->dev
>-				   was changed by rx_handler */
>-	RX_HANDLER_EXACT,	/* Force exact delivery, no wildcard */
>-	RX_HANDLER_PASS,	/* Do nothing, pass the skb as if
>-				   no rx_handler was called */
>+	RX_HANDLER_CONSUMED,
>+	RX_HANDLER_ANOTHER,=09
>+	RX_HANDLER_EXACT,
>+	RX_HANDLER_PASS,
> };
> typedef enum rx_handler_result rx_handler_result_t;
> typedef rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb);
>diff --git a/net/core/dev.c b/net/core/dev.c
>index a368223..3630722 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -3060,6 +3060,8 @@ out:
>  *	on a failure.
>  *
>  *	The caller must hold the rtnl_mutex.
>+ *
>+ *	For a general description of rx_handler, see enum rx_handler_resul=
t.
>  */
> int netdev_rx_handler_register(struct net_device *dev,
> 			       rx_handler_func_t *rx_handler,
>--=20
>1.7.2.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html


Reviewed-by: Jiri Pirko <jpirko@redhat.com>

