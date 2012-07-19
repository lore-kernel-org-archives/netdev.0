From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V1 4/4] net/mlx4_en: Add accelerated RFS support
Date: Thu, 19 Jul 2012 19:28:25 +0300
Message-ID: <500835A9.6080404@mellanox.com>
References: <1342686832-21406-1-git-send-email-ogerlitz@mellanox.com>  <1342686832-21406-5-git-send-email-ogerlitz@mellanox.com> <1342706957.2617.25.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <oren@mellanox.com>,
	<yevgenyp@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:55084 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751300Ab2GSQ2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 12:28:33 -0400
In-Reply-To: <1342706957.2617.25.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/2012 5:09 PM, Ben Hutchings wrote:
>> @@ -77,6 +77,12 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
>> >  	struct mlx4_en_dev *mdev = priv->mdev;
>> >  	int err = 0;
>> >  	char name[25];
>> >+	struct cpu_rmap *rmap =
>> >+#ifdef CONFIG_RFS_ACCEL
>> >+		priv->dev->rx_cpu_rmap;
>> >+#else
>> >+		NULL;
>> >+#endif
> You can write this slightly more cleanly using IS_ENABLED().
>
> [...]
>> >+static struct mlx4_en_filter *
>> >+mlx4_en_filter_alloc(struct mlx4_en_priv *priv, int rxq_index, __be32 src_ip,
>> >+                    __be32 dst_ip, __be16 src_port, __be16 dst_port,
>> >+                    u32 flow_id)
>> >+{
> [...]
>> >+       filter->id = priv->last_filter_id++;
> [...]
>
> You need to limit the filter IDs to be < RPS_NO_FILTER.


OK, thanks, we will send fixes for these two comments.

Or.
