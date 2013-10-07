From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Add layer 2 hardware acceleration operations
 for macvlan devices
Date: Mon, 07 Oct 2013 15:52:14 -0400 (EDT)
Message-ID: <20131007.155214.2232375975382665567.davem@davemloft.net>
References: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
	<1380917405-23801-1-git-send-email-nhorman@tuxdriver.com>
	<1380917405-23801-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	andy@greyhouse.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756127Ab3JGTwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:52:16 -0400
In-Reply-To: <1380917405-23801-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri,  4 Oct 2013 16:10:04 -0400

> @@ -426,9 +426,12 @@ struct sk_buff {
>  	char			cb[48] __aligned(8);
>  
>  	unsigned long		_skb_refdst;
> -#ifdef CONFIG_XFRM
> -	struct	sec_path	*sp;
> -#endif
> +
> +	union {
> +		struct	sec_path	*sp;
> +		void 			*accel_priv;
> +	};
> +

I'm not %100 sure these two things are really mutually exclusive.

What if bridging ebtables does an input route lookup?  That can
populate the security path.

Also, why have you not added this to the usual netdev_ops and
hw_features?
