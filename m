From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 09/26] team: fill-up LAG changeupper info struct
 and pass it along
Date: Wed, 2 Dec 2015 07:36:16 +0200
Message-ID: <CAJ3xEMj_AwtbRW7=FKFSMR9ed8B2Yak7U5zTSVHtf-r5+2ytRA@mail.gmail.com>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
	<1448977744-17930-10-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33453 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbbLBFgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 00:36:17 -0500
Received: by iouu10 with SMTP id u10so35479700iou.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 21:36:16 -0800 (PST)
In-Reply-To: <1448977744-17930-10-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015 at 3:48 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Initialize netdev_lag_upper_info structure by TX type according to
> current team mode and pass it along via netdev_master_upper_dev_link.
[...]
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
> @@ -1078,23 +1078,24 @@ static void team_port_disable_netpoll(struct team_port *port)
>  }
>  #endif
>
> -static int team_upper_dev_link(struct net_device *dev,
> -                              struct net_device *port_dev)
> +static int team_upper_dev_link(struct team *team, struct team_port *port)
>  {
> +       struct netdev_lag_upper_info lag_upper_info;
>         int err;
>
> -       err = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
> +       lag_upper_info.tx_type = team->mode->lag_tx_type;
> +       err = netdev_master_upper_dev_link(port->dev, team->dev, NULL,
> +                                          &lag_upper_info);
>         if (err)
>                 return err;
> -       port_dev->priv_flags |= IFF_TEAM_PORT;
> +       port->dev->priv_flags |= IFF_TEAM_PORT;
>         return 0;
>  }

you also added into this patch moving

from struct netdevice *dev_port->xxx

to struct team_port *port->dev->xxx

which goes beyond the logical change / functionality this  patch
introduces... maybe
better put it in a separate patch?

Or.
