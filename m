From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v13 10/16] Add a hook to intercept external buffers
 from NIC driver.
Date: Tue, 19 Oct 2010 08:24:01 -0700 (PDT)
Message-ID: <20101019.082401.28817543.davem@davemloft.net>
References: <1287133937-5538-1-git-send-email-xiaohui.xin@intel.com>
	<fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1287132437.git.xiaohui.xin@intel.com>
	<33f51c5eddec843260451eccbfa3c5fdea13b479.1287132437.git.xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	herbert@gondor.apana.org.au, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <33f51c5eddec843260451eccbfa3c5fdea13b479.1287132437.git.xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiaohui.xin@intel.com
Date: Fri, 15 Oct 2010 17:12:11 +0800

> @@ -2891,6 +2922,11 @@ static int __netif_receive_skb(struct sk_buff *skb)
>  ncls:
>  #endif
>  
> +	/* To intercept mediate passthru(zero-copy) packets here */
> +	skb = handle_mpassthru(skb, &pt_prev, &ret, orig_dev);
> +	if (!skb)
> +		goto out;
> +
>  	/* Handle special case of bridge or macvlan */
>  	rx_handler = rcu_dereference(skb->dev->rx_handler);
>  	if (rx_handler) {

If you consume the packet here, devices in passthru mode cannot
be use with bonding.

But there is nothing that prevents a bond being created with such
a device.

So we have to either prevent such configurations (bad) or make
it work somehow (good) :-)
