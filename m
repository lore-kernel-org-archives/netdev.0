From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 09/26] team: fill-up LAG changeupper info struct
 and pass it along
Date: Wed, 2 Dec 2015 08:55:50 +0100
Message-ID: <20151202075549.GB2355@nanopsycho.orion>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <1448977744-17930-10-git-send-email-jiri@resnulli.us>
 <CAJ3xEMj_AwtbRW7=FKFSMR9ed8B2Yak7U5zTSVHtf-r5+2ytRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34512 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756851AbbLBHzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 02:55:52 -0500
Received: by wmvv187 with SMTP id v187so241887273wmv.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 23:55:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMj_AwtbRW7=FKFSMR9ed8B2Yak7U5zTSVHtf-r5+2ytRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 02, 2015 at 06:36:16AM CET, gerlitz.or@gmail.com wrote:
>On Tue, Dec 1, 2015 at 3:48 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Initialize netdev_lag_upper_info structure by TX type according to
>> current team mode and pass it along via netdev_master_upper_dev_link.
>[...]
>> --- a/drivers/net/team/team.c
>> +++ b/drivers/net/team/team.c
>> @@ -1078,23 +1078,24 @@ static void team_port_disable_netpoll(struct team_port *port)
>>  }
>>  #endif
>>
>> -static int team_upper_dev_link(struct net_device *dev,
>> -                              struct net_device *port_dev)
>> +static int team_upper_dev_link(struct team *team, struct team_port *port)
>>  {
>> +       struct netdev_lag_upper_info lag_upper_info;
>>         int err;
>>
>> -       err = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
>> +       lag_upper_info.tx_type = team->mode->lag_tx_type;
>> +       err = netdev_master_upper_dev_link(port->dev, team->dev, NULL,
>> +                                          &lag_upper_info);
>>         if (err)
>>                 return err;
>> -       port_dev->priv_flags |= IFF_TEAM_PORT;
>> +       port->dev->priv_flags |= IFF_TEAM_PORT;
>>         return 0;
>>  }
>
>you also added into this patch moving
>
>from struct netdevice *dev_port->xxx
>
>to struct team_port *port->dev->xxx
>
>which goes beyond the logical change / functionality this  patch
>introduces... maybe
>better put it in a separate patch?

It is not moving anything. I need struct team_port *port as a param
instead of struct net_device *port_dev, that's it.
