From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] macvlan: Support creating macvtaps from macvlans
Date: Tue, 3 Dec 2013 09:24:51 +0100
Message-ID: <20131203082450.GA17839@unicorn.suse.cz>
References: <1386043991-4372-1-git-send-email-kevin@pentabarf.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kevin Wallace <kevin@pentabarf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48285 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751808Ab3LCIYw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 03:24:52 -0500
Content-Disposition: inline
In-Reply-To: <1386043991-4372-1-git-send-email-kevin@pentabarf.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 02, 2013 at 08:13:11PM -0800, Kevin Wallace wrote:
> -	/* When creating macvlans on top of other macvlans - use
> +	/* When creating macvlans or macvtaps on top of other macvlans - use
>  	 * the real device as the lowerdev.
>  	 */
> -	if (lowerdev->rtnl_link_ops == dev->rtnl_link_ops) {
> +	if (lowerdev->rtnl_link_ops == &macvlan_link_ops) {
>  		struct macvlan_dev *lowervlan = netdev_priv(lowerdev);
>  		lowerdev = lowervlan->lowerdev;
>  	}

Perhaps we could use the helpers:

	if (netif_is_macvlan(lowerdev))
		lowerdev = macvlan_dev_real_dev(lowerdev);

to show more clearly what we are doing.

                                                        Michal Kubecek
