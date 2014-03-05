From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next V2 1/2] net: Utility function to get affinity_hint
 by policy
Date: Wed, 05 Mar 2014 18:42:30 +0400
Message-ID: <531737D6.6070604@cogentembedded.com>
References: <1394014159-18801-1-git-send-email-amirv@mellanox.com> <1394014159-18801-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Prarit Bhargava <prarit@redhat.com>,
	Govindarajulu Varadarajan <gvaradar@cisco.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:61250 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340AbaCEOm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 09:42:28 -0500
Received: by mail-lb0-f174.google.com with SMTP id u14so750463lbd.19
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 06:42:27 -0800 (PST)
In-Reply-To: <1394014159-18801-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05-03-2014 14:09, Amir Vadai wrote:

> This function sets the affinity_mask according to a numa aware policy.
> affinity_mask could be used as an affinity hint for the IRQ related to
> this rx queue.
> Current policy is to spread rx queues accross cores - local cores first.
> It could be extended in the future.

> CC: Prarit Bhargava <prarit@redhat.com>
> CC: Govindarajulu Varadarajan <gvaradar@cisco.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
[...]

> diff --git a/net/core/dev.c b/net/core/dev.c
> index b1b0c8d..0b22f67 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2116,6 +2116,62 @@ int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq)
>   EXPORT_SYMBOL(netif_set_real_num_rx_queues);
>   #endif
>
> +/* netif_set_rx_queue_affinity_hint - set affinity hint of rx queue

    This should be a comment in the kernel-doc style, starting with /** on a 
line of its own.

> + * @rxq: index of rx queue
> + * @numa_node: prefered numa_node
> + * @affinity_mask: the relevant cpu bit is set according to the policy
> + *
> + * This function sets the affinity_mask according to a numa aware policy.
> + * affinity_mask coulbe used as an affinity hint for the IRQ related to this
> + * rx queue.
> + * The policy is to spread rx queues accross cores - local cores first.
> + *
> + * Returns 0 on success, or a negative error code.
> + */
> +int netif_set_rx_queue_affinity_hint(int rxq, int numa_node,
> +				     cpumask_var_t affinity_mask)
> +{
> +	const struct cpumask *p_numa_cores_mask;
> +	cpumask_var_t non_numa_cores_mask = NULL;
> +	int affinity_cpu;
> +	int ret = 0;
> +
> +	rxq = rxq % num_online_cpus();

    Why not:

	rxq %= num_online_cpus();

WBR, Sergei
