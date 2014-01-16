From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH net-next 3/3] virtio-net: Add accelerated RFS support
Date: Thu, 16 Jan 2014 21:31:27 +0000
Message-ID: <1389907887.11912.87.camel@bwh-desktop.uk.level5networks.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
	 <1389795654-28381-4-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <therbert@google.com>,
	<edumazet@google.com>, <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:25641 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbaAPVbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 16:31:32 -0500
In-Reply-To: <1389795654-28381-4-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 22:20 +0800, Zhi Yong Wu wrote:
[...]
> +static int virtnet_init_rx_cpu_rmap(struct virtnet_info *vi)
> +{
> +	int rc = 0;
> +
> +#ifdef CONFIG_RFS_ACCEL
> +	struct virtio_device *vdev = vi->vdev;
> +	unsigned int irq;
> +	int i;
> +
> +	if (!vi->affinity_hint_set)
> +		goto out;
> +
> +	vi->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(vi->max_queue_pairs);
> +	if (!vi->dev->rx_cpu_rmap) {
> +		rc = -ENOMEM;
> +		goto out;
> +	}
> +
> +	for (i = 0; i < vi->max_queue_pairs; i++) {
> +		irq = virtqueue_get_vq_irq(vdev, vi->rq[i].vq);
> +		if (irq == -1)
> +			goto failed;

Jumping into an if-statement is confusing.  Also do you really want to
return 0 in this case?

Otherwise this looks fine.

Ben.

> +		rc = irq_cpu_rmap_add(vi->dev->rx_cpu_rmap, irq);
> +		if (rc) {
> +failed:
> +			virtnet_free_irq_cpu_rmap(vi);
> +			goto out;
> +		}
> +	}
> +out:
> +#endif
> +	return rc;
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
