From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] team: Notify state change on ports
Date: Thu, 12 Mar 2015 15:29:07 -0400 (EDT)
Message-ID: <20150312.152907.1881565281406694368.davem@redhat.com>
References: <1426176236-28255-1-git-send-email-jonas.johansson@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	monis@mellanox.com, jonas.johansson@westermo.se
To: jonasj76@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbbCLT3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 15:29:18 -0400
In-Reply-To: <1426176236-28255-1-git-send-email-jonas.johansson@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Johansson <jonasj76@gmail.com>
Date: Thu, 12 Mar 2015 17:03:56 +0100

> +static void team_notify_port_work(struct work_struct *work)
> +{
> +	struct team *team;
> +	struct team_port_notify *notify;
> +
> +	team = container_of(work, struct team, notify_ports.dw.work);
> +
> +	if (!rtnl_trylock()) {
> +		schedule_delayed_work(&team->notify_ports.dw, 0);
> +		return;
> +	}
> +	rcu_read_lock();

This endless retry logic has the same problems as the issue being
worked on right now in the bonding notifiers.

We need something more sane, therefore I suggest we wait for the
bonding case to be worked out and then we can apply that solution
here as well.
