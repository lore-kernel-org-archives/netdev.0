From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Mon, 16 May 2011 20:35:18 +0100
Message-ID: <1305574518.2885.25.camel@bwh-desktop>
References: <1305574128.3456.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305574128.3456.23.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-16 at 12:28 -0700, Shirley Ma wrote:
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ---
> 
>  include/linux/netdevice.h |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a134d80..2646251 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1066,6 +1066,16 @@ struct net_device {
>  #define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
>  #define NETIF_F_LOOPBACK	(1 << 31) /* Enable loopback */
>  
> +/*
> + * Bit 31 is for device to map userspace buffers -- zerocopy
> + * Device can set this flag when it supports HIGHDMA.
> + * Device can't recycle this kind of skb buffers.
> + * There are 256 bytes copied, the rest of buffers are mapped.
> + * The userspace callback should only be called when last reference to this skb
> + * is gone.
> + */
> +#define NETIF_F_ZEROCOPY	(1 << 31)

Sorry, bit 31 is taken.  You get the job of turning features into a
wider bitmap.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
