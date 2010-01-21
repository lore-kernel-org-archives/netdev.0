From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [net-next-2.6 PATCH 1/3] fs_enet: use dev_xxx instead of printk
Date: Thu, 21 Jan 2010 09:43:27 -0700
Message-ID: <fa686aa41001210843n64be77d9wd62631d7b36d7342@mail.gmail.com>
References: <1264039999-25731-1-git-send-email-agust@denx.de>
	<1264039999-25731-2-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dzu@denx.de, wd@denx.de,
	linuxppc-dev@ozlabs.org, John Rigby <jcrigby@gmail.com>,
	Piotr Ziecik <kosmo@semihalf.com>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f196.google.com ([209.85.223.196]:61280 "EHLO
	mail-iw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144Ab0AUQns convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 11:43:48 -0500
Received: by iwn34 with SMTP id 34so145826iwn.21
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2010 08:43:47 -0800 (PST)
In-Reply-To: <1264039999-25731-2-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2010 at 7:13 PM, Anatolij Gustschin <agust@denx.de> wro=
te:
> Signed-off-by: Anatolij Gustschin <agust@denx.de>
> Cc: <linuxppc-dev@ozlabs.org>
> Cc: Grant Likely <grant.likely@secretlab.ca>

Acked-by: Grant Likely <grant.likely@secretlab.ca>

> Cc: John Rigby <jcrigby@gmail.com>
> Cc: Piotr Ziecik <kosmo@semihalf.com>
> Cc: Wolfgang Denk <wd@denx.de>
> ---
> =A0drivers/net/fs_enet/fs_enet-main.c | =A0 39 +++++++++++++---------=
-------------
> =A0drivers/net/fs_enet/mac-fcc.c =A0 =A0 =A0| =A0 =A05 ++-
> =A0drivers/net/fs_enet/mac-fec.c =A0 =A0 =A0| =A0 12 ++++------
> =A0drivers/net/fs_enet/mac-scc.c =A0 =A0 =A0| =A0 =A09 +++----
> =A04 files changed, 27 insertions(+), 38 deletions(-)
>
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet=
/fs_enet-main.c
> index ec2f503..c34a7e0 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -108,9 +108,7 @@ static int fs_enet_rx_napi(struct napi_struct *na=
pi, int budget)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * the last indicator should be set.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((sc & BD_ENET_RX_LAST) =3D=3D 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING DRV=
_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s rc=
v is not +last\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->nam=
e);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(fep->dev, "rcv=
 is not +last\n");
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Check for errors.
> @@ -178,9 +176,8 @@ static int fs_enet_rx_napi(struct napi_struct *na=
pi, int budget)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0receiv=
ed++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_=
receive_skb(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
KERN_WARNING DRV_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0": %s Memory squeeze, dropping packet.\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_war=
n(fep->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0"Memory squeeze, dropping packet.\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fep->s=
tats.rx_dropped++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skbn =3D=
 skb;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -242,9 +239,7 @@ static int fs_enet_rx_non_napi(struct net_device =
*dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * the last indicator should be set.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((sc & BD_ENET_RX_LAST) =3D=3D 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING DRV=
_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s rc=
v is not +last\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->nam=
e);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(fep->dev, "rcv=
 is not +last\n");
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Check for errors.
> @@ -313,9 +308,8 @@ static int fs_enet_rx_non_napi(struct net_device =
*dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0receiv=
ed++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_=
rx(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
KERN_WARNING DRV_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0": %s Memory squeeze, dropping packet.\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_war=
n(fep->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0"Memory squeeze, dropping packet.\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fep->s=
tats.rx_dropped++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skbn =3D=
 skb;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -388,10 +382,10 @@ static void fs_enet_tx(struct net_device *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fep->stats.tx_packets+=
+;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sc & BD_ENET_TX_READY)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING DRV=
_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s HE=
Y! Enet xmit interrupt and TX_READY.\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->nam=
e);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sc & BD_ENET_TX_READY) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(fep->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"HEY=
! Enet xmit interrupt and TX_READY.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Deferred means some collisions occu=
rred during transmit,
> @@ -511,9 +505,8 @@ void fs_init_bds(struct net_device *dev)
> =A0 =A0 =A0 =A0for (i =3D 0, bdp =3D fep->rx_bd_base; i < fep->rx_rin=
g; i++, bdp++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D dev_alloc_skb(ENET_RX_FRSIZE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (skb =3D=3D NULL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING DRV=
_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s Me=
mory squeeze, unable to allocate skb\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->nam=
e);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(fep->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Mem=
ory squeeze, unable to allocate skb\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_align(skb, ENET_RX_ALIGN);
> @@ -610,8 +603,7 @@ static int fs_enet_start_xmit(struct sk_buff *skb=
, struct net_device *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Ooops. =A0All transmit buffers are =
full. =A0Bail out.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * This should not happen, since the t=
x queue should be stopped.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING DRV_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s tx queue full!.\n"=
, dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(fep->dev, "tx queue full!.\n")=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NETDEV_TX_BUSY;
> =A0 =A0 =A0 =A0}
>
> @@ -788,8 +780,7 @@ static int fs_enet_open(struct net_device *dev)
> =A0 =A0 =A0 =A0r =3D request_irq(fep->interrupt, fs_enet_interrupt, I=
RQF_SHARED,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"fs_enet-mac", dev);
> =A0 =A0 =A0 =A0if (r !=3D 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR DRV_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s Could not allocate=
 FS_ENET IRQ!", dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(fep->dev, "Could not allocate F=
S_ENET IRQ!");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (fep->fpi->use_napi)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0napi_disable(&fep->nap=
i);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> @@ -1053,7 +1044,7 @@ static int __devinit fs_enet_probe(struct of_de=
vice *ofdev,
> =A0 =A0 =A0 =A0if (ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free_bd;
>
> - =A0 =A0 =A0 printk(KERN_INFO "%s: fs_enet: %pM\n", ndev->name, ndev=
->dev_addr);
> + =A0 =A0 =A0 pr_info("%s: fs_enet: %pM\n", ndev->name, ndev->dev_add=
r);
>
> =A0 =A0 =A0 =A0return 0;
>
> diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-=
fcc.c
> index 22e5a84..dd78640 100644
> --- a/drivers/net/fs_enet/mac-fcc.c
> +++ b/drivers/net/fs_enet/mac-fcc.c
> @@ -476,8 +476,9 @@ static void clear_int_events(struct net_device *d=
ev, u32 int_events)
>
> =A0static void ev_error(struct net_device *dev, u32 int_events)
> =A0{
> - =A0 =A0 =A0 printk(KERN_WARNING DRV_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s FS_ENET ERROR(s) 0x%x\n", dev->nam=
e, int_events);
> + =A0 =A0 =A0 struct fs_enet_private *fep =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 dev_warn(fep->dev, "FS_ENET ERROR(s) 0x%x\n", int_event=
s);
> =A0}
>
> =A0static int get_regs(struct net_device *dev, void *p, int *sizep)
> diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-=
fec.c
> index ca7bcb8..a664aa1 100644
> --- a/drivers/net/fs_enet/mac-fec.c
> +++ b/drivers/net/fs_enet/mac-fec.c
> @@ -257,8 +257,7 @@ static void restart(struct net_device *dev)
>
> =A0 =A0 =A0 =A0r =3D whack_reset(fep->fec.fecp);
> =A0 =A0 =A0 =A0if (r !=3D 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR DRV_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ": %s F=
EC Reset FAILED!\n", dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(fep->dev, "FEC Reset FAILED!\n"=
);
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Set station address.
> =A0 =A0 =A0 =A0 */
> @@ -355,9 +354,7 @@ static void stop(struct net_device *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0udelay(1);
>
> =A0 =A0 =A0 =A0if (i =3D=3D FEC_RESET_DELAY)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING DRV_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s FEC timeout on gra=
ceful transmit stop\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(fep->dev, "FEC timeout on grac=
eful transmit stop\n");
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Disable FEC. Let only MII interrupts.
> =A0 =A0 =A0 =A0 */
> @@ -433,8 +430,9 @@ static void clear_int_events(struct net_device *d=
ev, u32 int_events)
>
> =A0static void ev_error(struct net_device *dev, u32 int_events)
> =A0{
> - =A0 =A0 =A0 printk(KERN_WARNING DRV_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s FEC ERROR(s) 0x%x\n", dev->name, i=
nt_events);
> + =A0 =A0 =A0 struct fs_enet_private *fep =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 dev_warn(fep->dev, "FEC ERROR(s) 0x%x\n", int_events);
> =A0}
>
> =A0static int get_regs(struct net_device *dev, void *p, int *sizep)
> diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-=
scc.c
> index 008cdd9..2d8917f 100644
> --- a/drivers/net/fs_enet/mac-scc.c
> +++ b/drivers/net/fs_enet/mac-scc.c
> @@ -367,9 +367,7 @@ static void stop(struct net_device *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0udelay(1);
>
> =A0 =A0 =A0 =A0if (i =3D=3D SCC_RESET_DELAY)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING DRV_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s SCC timeout on gra=
ceful transmit stop\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(fep->dev, "SCC timeout on grac=
eful transmit stop\n");
>
> =A0 =A0 =A0 =A0W16(sccp, scc_sccm, 0);
> =A0 =A0 =A0 =A0C32(sccp, scc_gsmrl, SCC_GSMRL_ENR | SCC_GSMRL_ENT);
> @@ -429,8 +427,9 @@ static void clear_int_events(struct net_device *d=
ev, u32 int_events)
>
> =A0static void ev_error(struct net_device *dev, u32 int_events)
> =A0{
> - =A0 =A0 =A0 printk(KERN_WARNING DRV_MODULE_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s SCC ERROR(s) 0x%x\n", dev->name, i=
nt_events);
> + =A0 =A0 =A0 struct fs_enet_private *fep =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 dev_warn(fep->dev, "SCC ERROR(s) 0x%x\n", int_events);
> =A0}
>
> =A0static int get_regs(struct net_device *dev, void *p, int *sizep)
> --
> 1.5.6.3
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
