From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: properly latch and use autoclose value from sock
 to association
Date: Mon, 09 Dec 2013 20:32:38 -0500 (EST)
Message-ID: <20131209.203238.1909015829128815864.davem@davemloft.net>
References: <52A0A300.3010409@gmail.com>
	<1386343755-14130-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, wangweidong1@huawei.com,
	vyasevich@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab3LJBck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:32:40 -0500
In-Reply-To: <1386343755-14130-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri,  6 Dec 2013 10:29:15 -0500

> @@ -2205,6 +2206,12 @@ static int sctp_setsockopt_autoclose(struct sock *sk, char __user *optval,
>  	if (copy_from_user(&sp->autoclose, optval, optlen))
>  		return -EFAULT;
>  
> +	if (sp->autoclose > net->sctp.max_autoclose) {
> +		pr_warn("Capping autoclose value %d to defined maximum of %lu\n",
> +			sp->autoclose, net->sctp.max_autoclose);
> +		sp->autoclose = net->sctp.max_autoclose;
> +	}

Please don't add this warning.

If we already do this for certain setsockopt calls in SCTP, that just
means we have bugs to fix.
