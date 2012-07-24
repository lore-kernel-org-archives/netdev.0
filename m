From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/2] team: add netpoll support
Date: Tue, 24 Jul 2012 13:14:28 +0200
Message-ID: <20120724111428.GA5031@minipsycho.brq.redhat.com>
References: <1342538556-22601-1-git-send-email-jiri@resnulli.us>
 <1342538556-22601-3-git-send-email-jiri@resnulli.us>
 <1343118639.2626.11042.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:58569 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446Ab2GXLOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 07:14:32 -0400
Received: by wgbdr13 with SMTP id dr13so6810523wgb.1
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 04:14:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1343118639.2626.11042.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 24, 2012 at 10:30:39AM CEST, eric.dumazet@gmail.com wrote:
>On Tue, 2012-07-17 at 17:22 +0200, Jiri Pirko wrote:
>> It's done in very similar way this is done in bonding and bridge.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>
>> +static int team_netpoll_setup(struct net_device *dev,
>> +			      struct netpoll_info *npifo)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	struct team_port *port;
>> +	int err;
>> +
>> +	mutex_lock(&team->lock);
>> +	list_for_each_entry(port, &team->port_list, list) {
>> +		err = team_port_enable_netpoll(team, port);
>> +		if (err) {
>> +			__team_netpoll_cleanup(team);
>> +			break;
>> +		}
>> +	}
>> +	mutex_unlock(&team->lock);
>> +	return err;
>> +}
>
>If port_list is empty, we return a non initialized value in 'err'
>
>What would be the fix ? 0 or an error ?

0, I'm going to send fix in a minute. Thanks!

>
>
>
