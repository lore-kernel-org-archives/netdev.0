From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] Ethernet Bridging: Enable Hardware Checksumming
Date: Wed, 18 May 2005 17:03:51 -0700
Message-ID: <428BD7E7.5080207@us.ibm.com>
References: <20050518235329.GA17946@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <20050518235329.GA17946@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason wrote:

> Currently, locally generated ethernet traffic does not take advantage of
> hardware checksum offload when acting as a child device under a bridge
> device.  This is because the upper layers do not see the available
> features of the child devices only the features of the bridge device
> (which is empty).  
> 
> There is an easy solution for this (see patch below), include hardware
> checksum and scatter gather as features of the bridge device.  In the 
> case that the physical ethernet device does not support scatter 
> gather or hardware checksum, dev_queue_xmit() will check the
> dev->features and do the necessary linearization and calculate the
> checksum.
> 
> Signed-off-by: Jon Mason <jdmason@us.ibm.com>
> 
> --- net/bridge/br_device.c.orig	2005-05-13 11:23:02.552751024 -0500
> +++ net/bridge/br_device.c	2005-05-13 11:25:39.155943720 -0500
> @@ -101,4 +101,5 @@ void br_dev_setup(struct net_device *dev
>  	dev->tx_queue_len = 0;
>  	dev->set_mac_address = NULL;
>  	dev->priv_flags = IFF_EBRIDGE;
> +	dev->features = NETIF_F_HW_CSUM | NETIF_F_SG;
>  }

Stephen,

I think this is a good thing to have, gives us performance
gain (equivalent to using/not using checksum offload) and
has very little impact on the bridging layer, and is
independent of the virtualization stuff..

thanks,
Nivedita
