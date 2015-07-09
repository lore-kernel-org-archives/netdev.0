From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] net: don't reforward packets already
 forwarded by offload device
Date: Thu, 09 Jul 2015 15:22:19 -0700 (PDT)
Message-ID: <20150709.152219.296131629520319694.davem@davemloft.net>
References: <1436397403-62412-1-git-send-email-sfeldma@gmail.com>
	<1436397403-62412-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251AbbGIWWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 18:22:20 -0400
In-Reply-To: <1436397403-62412-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed,  8 Jul 2015 16:16:39 -0700

> @@ -653,6 +654,9 @@ struct sk_buff {
>  #ifdef CONFIG_NETWORK_SECMARK
>  	__u32			secmark;
>  #endif
> +#ifdef CONFIG_NET_SWITCHDEV
> +	__u32			offload_fwd_mark;
> +#endif

May I humbly suggest:

	union {
#ifdef CONFIG_NETWORK_SECMARK
		__u32	secmark;
#endif
#ifdef CONFIG_NET_SWITCHDEV
		__u32	offload_fwd_mark;
#endif
	};

After some studying, I'm largely convinced that these two values are
used in non-conflicting contexts.

Let me know if you can find an exception to this.

Thanks.
