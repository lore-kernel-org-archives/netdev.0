From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v2] Add support for netvsc build without
 CONFIG_SYSFS flag
Date: Thu, 08 May 2014 16:44:58 -0400 (EDT)
Message-ID: <20140508.164458.157597820665207475.davem@davemloft.net>
References: <1399581693-25050-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1399581693-25050-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Thu,  8 May 2014 13:41:33 -0700

> +static inline void netvsc_record_rx_queue(struct sk_buff *skb,
> +					  struct hv_netvsc_packet *packet,
> +					  struct net_device *ndev)
> +{
> +#ifdef CONFIG_SYSFS
> +	skb_record_rx_queue(skb, packet->channel->
> +			    offermsg.offer.sub_channel_index %
> +			    ndev->real_num_rx_queues);
> +#endif
> +}

This is still fantastically gross, what is so unique about your
driver that it needs hacks like this?  No other driver to my
knowledge does.

Figure out what it is that makes your driver so unique, and
try to make it conform to how other drivers handle these
features without SYSFS ifdef'ery instead.

I'm not applying this patch, sorry.

Thanks.
