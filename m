From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] team: fix possible null pointer dereference in
 team_handle_frame
Date: Mon, 23 Feb 2015 15:31:07 -0500 (EST)
Message-ID: <20150223.153107.994672703052666089.davem@davemloft.net>
References: <1424696574-6590-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbbBWUbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 15:31:09 -0500
In-Reply-To: <1424696574-6590-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 23 Feb 2015 14:02:54 +0100

> Currently following race is possible in team:
> 
> CPU0                                        CPU1
>                                             team_port_del
>                                               team_upper_dev_unlink
>                                                 priv_flags &= ~IFF_TEAM_PORT
> team_handle_frame
>   team_port_get_rcu
>     team_port_exists
>       priv_flags & IFF_TEAM_PORT == 0
>     return NULL (instead of port got
>                  from rx_handler_data)
>                                               netdev_rx_handler_unregister
> 
> The thing is that the flag is removed before rx_handler is unregistered.
> If team_handle_frame is called in between, team_port_exists returns 0
> and team_port_get_rcu will return NULL.
> So do not check the flag here. It is guaranteed by netdev_rx_handler_unregister
> that team_handle_frame will always see valid rx_handler_data pointer.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Fixes: 3d249d4ca7d0 ("net: introduce ethernet teaming device")

Applied and queued up for -stable, thanks Jiri.
