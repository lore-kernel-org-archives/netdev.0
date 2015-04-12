From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 01/11] net/mlx5_core: Set irq affinity hints
Date: Sun, 12 Apr 2015 14:15:06 +0300
Message-ID: <CALzJLG-+zcGtvghqRcKXoCOMhDO7iwzm77CRP4ZnTxOpib6U9A@mail.gmail.com>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com>
	<1428504685-8945-2-git-send-email-amirv@mellanox.com>
	<5527896E.4040604@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>
To: Ido Shamay <idos@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:36140 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbbDLLPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 07:15:07 -0400
Received: by qku63 with SMTP id 63so121676358qku.3
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 04:15:06 -0700 (PDT)
In-Reply-To: <5527896E.4040604@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 11:27 AM, Ido Shamay <idos@dev.mellanox.co.il> wrote:
> On 4/8/2015 5:51 PM, Amir Vadai wrote:
>>
>> From: Saeed Mahameed <saeedm@mellanox.com>
>>
>> +       int numa_node           =
>> +#if IS_ENABLED(CONFIG_NUMA)
>> +               mdev->pdev->dev.numa_node;
>> +#else
>> +               -1;
>> +#endif
>
> Would be nicer to use dev_to_node helper here, which already checks for
> CONFIG_NUMA
>
> include/linux/device.h:
> #ifdef CONFIG_NUMA
> static inline int dev_to_node(struct device *dev)
> {
>         return dev->numa_node;
> }
> static inline void set_dev_node(struct device *dev, int node)
> {
>         dev->numa_node = node;
> }
> #else
> static inline int dev_to_node(struct device *dev)
> {
>         return -1;
> }
> static inline void set_dev_node(struct device *dev, int node)
> {
> }
> #endif
Right, will fix in V1
