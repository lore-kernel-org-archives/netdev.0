From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] w5300: add WIZnet W5300 Ethernet driver
Date: Mon, 24 Oct 2011 18:21:42 -0400 (EDT)
Message-ID: <20111024.182142.2299822581628382143.davem@davemloft.net>
References: <1319272916-5541-1-git-send-email-kth3321@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, suhwan@wiznet.co.kr, bongbong@wiznet.co.kr
To: kth3321@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319272916-5541-1-git-send-email-kth3321@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Taehun Kim <kth3321@gmail.com>
Date: Sat, 22 Oct 2011 17:41:56 +0900

> +struct wiz_private {
> +	void __iomem *base;
> +	struct net_device *dev;
> +	u8 rxbuf_conf[MAX_SOCK_NUM];
> +	u8 txbuf_conf[MAX_SOCK_NUM];
> +	struct net_device_stats stats;
> +	struct napi_struct napi;
> +	spinlock_t lock;
> +	u32 msg_enable;
> +};

You don't need to have a private net_device_stats, just use the
one in struct net_device, and then you can also get rid of your
private ->ndo_get_stats() method.
