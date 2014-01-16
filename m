From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v3 4/5] net-sysfs: add support for
	device-specific rx queue sysfs attributes
Date: Thu, 16 Jan 2014 18:57:30 +0000
Message-ID: <1389898650.11912.65.camel@bwh-desktop.uk.level5networks.com>
References: <1389865126-26225-1-git-send-email-mwdalton@google.com>
	<1389865126-26225-4-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, Eric
	Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389865126-26225-4-git-send-email-mwdalton@google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-01-16 at 01:38 -0800, Michael Dalton wrote:
[...]
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
[...]
> @@ -2401,6 +2416,23 @@ static inline int netif_copy_real_num_queues(struct net_device *to_dev,
>  #endif
>  }
>  
> +#ifdef CONFIG_SYSFS
> +static inline unsigned int get_netdev_rx_queue_index(
> +		struct netdev_rx_queue *queue)
> +{
> +	struct net_device *dev = queue->dev;
> +	int i;
> +
> +	for (i = 0; i < dev->num_rx_queues; i++)
> +		if (queue == &dev->_rx[i])
> +			break;

Why write a loop when you can do:
	i = queue - dev->_rx;

Ben.

> +	BUG_ON(i >= dev->num_rx_queues);
> +
> +	return i;
> +}
> +#endif

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
