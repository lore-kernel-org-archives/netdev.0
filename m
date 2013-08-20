From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/3] net: add a new NETDEV_CHANGEROOM event type
Date: Tue, 20 Aug 2013 17:16:58 +0200
Message-ID: <1377011818.13829.9.camel@jlt4.sipsolutions.net>
References: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
	 <1377002752-4622-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com, jiri@resnulli.us,
	stephen@networkplumber.org, kaber@trash.net, davem@davemloft.net,
	vyasevic@redhat.com, eric.dumazet@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:55499 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592Ab3HTPRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 11:17:05 -0400
In-Reply-To: <1377002752-4622-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-20 at 13:45 +0100, Florian Fainelli wrote:

>  /**
> + *	dev_set_headroom - Change device needed headroom
> + *	@dev: device
> + *	@new_headroom: new headroom size
> + *
> + * 	Change the network device headroom space.
> + */
> +int dev_set_headroom(struct net_device *dev, unsigned short new_headroom)

It seems that you need to invoke these under RTNL, might be worth
documenting that.

Also, maybe it would be worth doing it in one call? If you need to
change both, then you'd end up calling the notifier twice, which is less
efficient? I suppose you could make them 'int' arguments and reserve -1
for no changes, or just require both new values to be given (if doing
this at all.)

johannes
