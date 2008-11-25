From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 1/1] netns: filter out uevent not belonging to init_net
Date: Tue, 25 Nov 2008 09:40:59 -0800
Message-ID: <m14p1vg0us.fsf@frodo.ebiederm.org>
References: <20081125165159.411202515@mai-009101017029.toulouse-stg.fr.ibm.com>
	<20081125165346.554858327@mai-009101017029.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	benjamin.thery@bull.net, containers@lists.osdl.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49618 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbYKYRqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:46:08 -0500
In-Reply-To: <20081125165346.554858327@mai-009101017029.toulouse-stg.fr.ibm.com>
	(Daniel Lezcano's message of "Tue, 25 Nov 2008 17:52:00 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

> This patch will filter out the uevent not related to the init_net.
> Without this patch if a network device is created in a network
> namespace with the same name as one network device belonging to the
> initial network namespace (eg. eth0), when the network namespace
> will die and the network device will be destroyed, an event will
> be sent and catched by the udevd daemon. That will result to have
> the real network device to be shutdown because the udevd/uevent are
> not namespace aware.

It is belt and suspenders at this point.  As those devices should
not even be in sysfs at the moment.  But it keeps us from doing the
wrong thing when sysfs support starts coming on line.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> ---
>  net/core/net-sysfs.c |    3 +++
>  1 file changed, 3 insertions(+)
>
> Index: net-next-2.6/net/core/net-sysfs.c
> ===================================================================
> --- net-next-2.6.orig/net/core/net-sysfs.c
> +++ net-next-2.6/net/core/net-sysfs.c
> @@ -427,6 +427,9 @@ static int netdev_uevent(struct device *
>  	struct net_device *dev = to_net_dev(d);
>  	int retval;
>  
> +	if (!net_eq(dev_net(dev), &init_net))
> +		return 0;
> +
>  	/* pass interface to uevent. */
>  	retval = add_uevent_var(env, "INTERFACE=%s", dev->name);
>  	if (retval)
