From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] team: fix mtu setting
Date: Thu, 29 May 2014 21:55:24 +0200
Message-ID: <20140529195524.GD19750@minipsycho.orion>
References: <1401389177-10463-1-git-send-email-jiri@resnulli.us>
 <20140529193319.GB13007@t520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:59781 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbaE2Tz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 15:55:29 -0400
Received: by mail-pd0-f173.google.com with SMTP id v10so99771pde.32
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 12:55:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140529193319.GB13007@t520.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 29, 2014 at 09:33:19PM CEST, fbl@redhat.com wrote:
>On Thu, May 29, 2014 at 08:46:17PM +0200, Jiri Pirko wrote:
>> Now it is not possible to set mtu to team device which has a port
>> enslaved to it. The reason is that when team_change_mtu() calls
>> dev_set_mtu() for port device, notificator for NETDEV_PRECHANGEMTU
>> event is called and team_device_event() returns NOTIFY_BAD forbidding
>> the change. So fix this by returning NOTIFY_DONE here in case team is
>> changing mtu in team_change_mtu().
>> 
>> Introduced-by: 3d249d4c "net: introduce ethernet teaming device"
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>
>Alright, so changing the team's mtu is now allowed but changing
>port's mtu isn't allowed.
>LGTM.
>
>Since there are some common code between the unwide and the
>successful code paths, I'd suggest to simply use:
>...
>	list_for_each_entry() {
>		err = 
>		if (err)
>			break
>	}
>
>	if (err) {
>		unwind
>	}
>	else
>		dev->mtu = new_mtu;
>
>	<common code>
>
>But I suspect that due to the long function name, any
>additional indentation there will cause the code to look
>less readable.

Yep, I was thinking about the same thing, decided not to go that way for
now.

>
>Acked-by: Flavio Leitner <fbl@redhat.com>
>


Thanks for review!
