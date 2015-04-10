From: Ido Shamay <idos@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 01/11] net/mlx5_core: Set irq affinity hints
Date: Fri, 10 Apr 2015 11:27:26 +0300
Message-ID: <5527896E.4040604@dev.mellanox.co.il>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com> <1428504685-8945-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33539 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270AbbDJI1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 04:27:30 -0400
Received: by wiax7 with SMTP id x7so10969874wia.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 01:27:29 -0700 (PDT)
In-Reply-To: <1428504685-8945-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/2015 5:51 PM, Amir Vadai wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
>
> +	int numa_node           =
> +#if IS_ENABLED(CONFIG_NUMA)
> +		mdev->pdev->dev.numa_node;
> +#else
> +		-1;
> +#endif
Would be nicer to use dev_to_node helper here, which already checks for 
CONFIG_NUMA

include/linux/device.h:
#ifdef CONFIG_NUMA
static inline int dev_to_node(struct device *dev)
{
         return dev->numa_node;
}
static inline void set_dev_node(struct device *dev, int node)
{
         dev->numa_node = node;
}
#else
static inline int dev_to_node(struct device *dev)
{
         return -1;
}
static inline void set_dev_node(struct device *dev, int node)
{
}
#endif
