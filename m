From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/3] cfg80211/nl80211 core
Date: Fri, 06 Oct 2006 11:51:07 +0200
Message-ID: <1160128267.2715.59.camel@ux156>
References: <1158230812.2936.46.camel@ux156>
	 <1158230963.2936.49.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	Jiri Benc <jbenc@suse.cz>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35503 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750993AbWJFJuW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 05:50:22 -0400
To: netdev@vger.kernel.org
In-Reply-To: <1158230963.2936.49.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-14 at 12:49 +0200, Johannes Berg wrote:

> +struct cfg80211_registered_driver *
> +cfg80211_get_drv_from_ifindex(int ifindex)
> +{
> +	struct cfg80211_registered_driver *drv;
> +	struct net_device *dev;
> +
> +	mutex_lock(&cfg80211_drv_mutex);
> +	dev = dev_get_by_index(ifindex);
> +	if (!dev)
> +		return ERR_PTR(-ENODEV);
> +	drv = cfg80211_drv_by_priv(dev->ieee80211_ptr);
> +	if (drv)
> +		mutex_lock(&drv->mtx);
> +	dev_put(dev);
> +	if (drv)
> +		return drv;
> +	return ERR_PTR(-ENODEV);
> +}

So... nobody spotted the "obvious" [1] locking problem here ;) fixed,
will update the patches soon and upload somewhere, netdev doesn't like
them and drops my mail (even 0/3 which wasn't that big).

johannes

[1] hint: drv->mtx is supposed to be left locked at the end, but
cfg80211_drv_mutex isn't :) I found out the hard way when testing my WE
backward compat code

