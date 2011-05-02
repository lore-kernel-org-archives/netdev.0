From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V3 2/8] Add a new zerocopy device flag
Date: Mon, 2 May 2011 13:42:57 +0300
Message-ID: <20110502104257.GA21625@redhat.com>
References: <1303328216.19336.18.camel@localhost.localdomain>
 <1303328648.19336.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1303328648.19336.24.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 20, 2011 at 12:44:08PM -0700, Shirley Ma wrote:
> This zerocopy flag is used to support device DMA userspace buffers.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ---
> 
>  include/linux/netdevice.h |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 0249fe7..0998d3d 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1067,6 +1067,9 @@ struct net_device {
>  #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
>  #define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
>  
> +/* bit 29 is for device to map userspace buffers -- zerocopy */

This comment should specify what exactly is the promise the
device makes by setting this flag. Specifically, the
condition is that no skb fragments are used
after the uinfo callback has been called.

The way it's implemented, it probably means the device
should not use any of skb_clone, expand head etc.

> +#define NETIF_F_ZEROCOPY	(1 << 29)
> +
>  	/* Segmentation offload features */
>  #define NETIF_F_GSO_SHIFT	16
>  #define NETIF_F_GSO_MASK	0x00ff0000
> 
