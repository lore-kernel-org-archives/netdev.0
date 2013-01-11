From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3] net, wireless: overwrite default_ethtool_ops
Date: Fri, 11 Jan 2013 11:51:47 +0100
Message-ID: <1357901507.9767.0.camel@jlt4.sipsolutions.net>
References: <20130111091909.GA2347@redhat.com>
	 (sfid-20130111_101938_088871_22B76855)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Ben Greear <greearb@candelatech.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	linux-wireless@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:52681 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753911Ab3AKKv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 05:51:28 -0500
In-Reply-To: <20130111091909.GA2347@redhat.com> (sfid-20130111_101938_088871_22B76855)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-11 at 10:19 +0100, Stanislaw Gruszka wrote:
> Since:
> 
> commit 2c60db037034d27f8c636403355d52872da92f81
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Sun Sep 16 09:17:26 2012 +0000
> 
>     net: provide a default dev->ethtool_ops
> 
> wireless core does not correctly assign ethtool_ops.
> 
> After alloc_netdev*() call, some cfg80211 drivers provide they own
> ethtool_ops, but some do not. For them, wireless core provide generic
> cfg80211_ethtool_ops, which is assigned in NETDEV_REGISTER notify call:
> 
>         if (!dev->ethtool_ops)
>                 dev->ethtool_ops = &cfg80211_ethtool_ops;
> 
> But after Eric's commit, dev->ethtool_ops is no longer NULL (on cfg80211
> drivers without custom ethtool_ops), but points to &default_ethtool_ops.
> 
> In order to fix the problem, provide function which will overwrite
> default_ethtool_ops and use it by wireless core.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Acked-by: Johannes Berg <johannes@sipsolutions.net>

This will work nicely, clearly I didn't understand davem's suggestion :)

johannes
