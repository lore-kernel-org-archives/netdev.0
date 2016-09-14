From: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 13/16] IB/pvrdma: Add the main driver module for PVRDMA
Date: Wed, 14 Sep 2016 19:38:02 +0300
Message-ID: <20160914163802.GC3216@yuval-lap.Home>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-14-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org,
        georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org
To: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1473655766-31628-14-git-send-email-aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 11, 2016 at 09:49:23PM -0700, Adit Ranadive wrote:
+
> +static void pvrdma_netdevice_event_handle(struct pvrdma_dev *dev,
> +					  unsigned long event)
> +{
> +	struct net_device *netdev;
> +
> +	netdev = dev->netdev;

Please remove the above two lines.

> +	switch (event) {
> +	case NETDEV_REBOOT:
> +	case NETDEV_DOWN:
> +		pvrdma_dispatch_event(dev, 1, IB_EVENT_PORT_ERR);
> +		break;
> +	case NETDEV_UP:
> +		pvrdma_dispatch_event(dev, 1, IB_EVENT_PORT_ACTIVE);
> +		break;
> +	default:
> +		dev_dbg(&dev->pdev->dev, "ignore netdevice event %ld on %s\n",
> +			event, dev->ib_dev.name);
> +		break;
> +	}
> +}
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
