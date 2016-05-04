From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH net-next 4/5] treewide: replace dev->trans_start update
 with helper
Date: Wed, 4 May 2016 17:03:01 +0530
Message-ID: <5729DDED.6030106@ti.com>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
 <1462285994-31983-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <user-mode-linux-devel@lists.sourceforge.net>,
	<linux-xtensa@linux-xtensa.org>,
	<linux1394-devel@lists.sourceforge.net>,
	<linux-rdma@vger.kernel.org>, <MPT-FusionLinux.pdl@broadcom.com>,
	<linux-scsi@vger.kernel.org>, <linux-can@vger.kernel.org>,
	<linux-parisc@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<linux-hams@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<linux-wireless@vger.kernel.org>, <linux-s390@vger.kernel.org>,
	<devel@driverdev.osuosl.org>, <b.a.t.m.a.n@lists.open-mesh.org>,
	<linux-bluetooth@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>, <netdev@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1462285994-31983-1-git-send-email-fw@strlen.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 03 May 2016 08:03 PM, Florian Westphal wrote:
> Replace all trans_start updates with netif_trans_update helper.
> change was done via spatch:
> 
> struct net_device *d;
> @@
> - d->trans_start = jiffies
> + netif_trans_update(d)
> 
> Compile tested only.
> 
> Cc: user-mode-linux-devel@lists.sourceforge.net
> Cc: linux-xtensa@linux-xtensa.org
> Cc: linux1394-devel@lists.sourceforge.net
> Cc: linux-rdma@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: MPT-FusionLinux.pdl@broadcom.com
> Cc: linux-scsi@vger.kernel.org
> Cc: linux-can@vger.kernel.org
> Cc: linux-parisc@vger.kernel.org
> Cc: linux-omap@vger.kernel.org
> Cc: linux-hams@vger.kernel.org
> Cc: linux-usb@vger.kernel.org
> Cc: linux-wireless@vger.kernel.org
> Cc: linux-s390@vger.kernel.org
> Cc: devel@driverdev.osuosl.org
> Cc: b.a.t.m.a.n@lists.open-mesh.org
> Cc: linux-bluetooth@vger.kernel.org
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

snip...


> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 0fa75a8..3d4662d 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1381,7 +1381,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
>  	struct cpsw_priv *priv = netdev_priv(ndev);
>  	int ret;
>  
> -	ndev->trans_start = jiffies;
> +	netif_trans_update(ndev);
>  
>  	if (skb_padto(skb, CPSW_MIN_PACKET_SIZE)) {
>  		cpsw_err(priv, tx_err, "packet pad failed\n");

for cpsw

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
