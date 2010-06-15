From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: implements ethtool_ops.get_drvinfo
Date: Tue, 15 Jun 2010 13:58:11 +0930
Message-ID: <201006151358.12071.rusty@rustcorp.com.au>
References: <4C11915E.6090201@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33403 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193Ab0FOE2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 00:28:14 -0400
In-Reply-To: <4C11915E.6090201@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jun 2010 10:59:02 am Taku Izumi wrote:
> This patch implements ethtool_ops.get_drvinfo interface of virtio_net driver.
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

Hi Taku!

   Does this have any useful effect?

Thanks,
Rusty.

> ---
>  drivers/net/virtio_net.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> Index: net-next.35/drivers/net/virtio_net.c
> ===================================================================
> --- net-next.35.orig/drivers/net/virtio_net.c
> +++ net-next.35/drivers/net/virtio_net.c
> @@ -701,6 +701,18 @@ static int virtnet_close(struct net_devi
>  	return 0;
>  }
> 
> +static void virtnet_get_drvinfo(struct net_device *dev,
> +				struct ethtool_drvinfo *drvinfo)
> +{
> +	struct virtnet_info *vi = netdev_priv(dev);
> +	struct virtio_device *vdev = vi->vdev;
> +
> +	strncpy(drvinfo->driver, KBUILD_MODNAME, 32);
> +	strncpy(drvinfo->version, "N/A", 32);
> +	strncpy(drvinfo->fw_version, "N/A", 32);
> +	strncpy(drvinfo->bus_info, dev_name(&vdev->dev), 32);
> +}
> +
>  static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> @@ -813,6 +825,7 @@ static void virtnet_vlan_rx_kill_vid(str
>  }
> 
>  static const struct ethtool_ops virtnet_ethtool_ops = {
> +	.get_drvinfo = virtnet_get_drvinfo,
>  	.set_tx_csum = virtnet_set_tx_csum,
>  	.set_sg = ethtool_op_set_sg,
>  	.set_tso = ethtool_op_set_tso,
> 
