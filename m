From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 2/2] team: add netpoll support
Date: Tue, 24 Jul 2012 10:30:39 +0200
Message-ID: <1343118639.2626.11042.camel@edumazet-glaptop>
References: <1342538556-22601-1-git-send-email-jiri@resnulli.us>
	 <1342538556-22601-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:46501 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619Ab2GXIar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 04:30:47 -0400
Received: by lbbgm6 with SMTP id gm6so8827095lbb.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 01:30:45 -0700 (PDT)
In-Reply-To: <1342538556-22601-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 17:22 +0200, Jiri Pirko wrote:
> It's done in very similar way this is done in bonding and bridge.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

> +static int team_netpoll_setup(struct net_device *dev,
> +			      struct netpoll_info *npifo)
> +{
> +	struct team *team = netdev_priv(dev);
> +	struct team_port *port;
> +	int err;
> +
> +	mutex_lock(&team->lock);
> +	list_for_each_entry(port, &team->port_list, list) {
> +		err = team_port_enable_netpoll(team, port);
> +		if (err) {
> +			__team_netpoll_cleanup(team);
> +			break;
> +		}
> +	}
> +	mutex_unlock(&team->lock);
> +	return err;
> +}

If port_list is empty, we return a non initialized value in 'err'

What would be the fix ? 0 or an error ?
