From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: ipv6: Remove addresses for failures with strict DAD
Date: Wed, 17 Aug 2016 17:40:31 +0200
Message-ID: <58750abf-9221-f2d3-0fb2-cc5f1bcd92f9@stressinduktion.org>
References: <1471429720-6141-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:51719 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752181AbcHQPkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 11:40:35 -0400
In-Reply-To: <1471429720-6141-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.08.2016 12:28, Mike Manning wrote:
> +static void dev_disable_change(struct inet6_dev *idev);
>  
>  /*
>   *	Configured unicast address hash table
> @@ -1945,6 +1946,12 @@ lock_errdad:
>  
>  			pr_info("%s: IPv6 being disabled!\n",
>  				ifp->idev->dev->name);
> +			spin_unlock_bh(&ifp->lock);
> +			addrconf_dad_stop(ifp, 1);
> +			rtnl_lock();
> +			dev_disable_change(idev);
> +			rtnl_unlock();
> +			return;
>  		}
>  	}

You can't take rtnl_lock at that point but must postpone the actions and
do that in addrconf_dad_work.

Probably the whole ... else if (idev->cnf.accept_dad > 1 && ...) needs
to move there.

Bye,
Hannes
