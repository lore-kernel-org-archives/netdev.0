From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch net-next] team: do not use -ENOENT
Date: Thu, 17 Jan 2013 07:51:15 -0800
Message-ID: <20130117075115.731c4cf0@nehalam.linuxnetplumber.net>
References: <1358418300-2346-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:58114 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756737Ab3AQPwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 10:52:43 -0500
Received: by mail-da0-f53.google.com with SMTP id x6so1165028dac.40
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 07:52:43 -0800 (PST)
In-Reply-To: <1358418300-2346-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Jan 2013 11:25:00 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> Since this error code means "No such file or directory", change this
> value in team driver to ones which make more sense.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  drivers/net/team/team.c                   | 4 ++--
>  drivers/net/team/team_mode_activebackup.c | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> index 70d5d6b..3d7cf6e 100644
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
> @@ -1128,7 +1128,7 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
>  	if (!port || !team_port_find(team, port)) {
>  		netdev_err(dev, "Device %s does not act as a port of this team\n",
>  			   portname);
> -		return -ENOENT;
> +		return -ENODEV;
>  	}
>  
>  	__team_option_inst_mark_removed_port(team, port);
> @@ -2320,7 +2320,7 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
>  			list_add(&opt_inst->tmp_list, &opt_inst_list);
>  		}
>  		if (!opt_found) {
> -			err = -ENOENT;
> +			err = -EINVAL;
>  			goto team_put;
>  		}
>  	}
> diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
> index 6262b4d..2792e13 100644
> --- a/drivers/net/team/team_mode_activebackup.c
> +++ b/drivers/net/team/team_mode_activebackup.c
> @@ -81,7 +81,7 @@ static int ab_active_port_set(struct team *team, struct team_gsetter_ctx *ctx)
>  			return 0;
>  		}
>  	}
> -	return -ENOENT;
> +	return -ENODEV;
>  }
>  
>  static const struct team_option ab_options[] = {

To be pedantic.
Changing errno's means effectively changing the ABI.
Linus has already rejected similar patches in other areas.
