From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] switchdev: call bridge setlink/dellink ndos
 recursively
Date: Tue, 17 Mar 2015 08:05:39 +0100
Message-ID: <20150317070539.GE2042@nanopsycho.orion>
References: <1426515774-21038-1-git-send-email-jiri@resnulli.us>
 <55075460.9040408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfeldma@gmail.com,
	roopa@cumulusnetworks.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:36266 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbbCQHFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 03:05:43 -0400
Received: by wetk59 with SMTP id k59so699705wet.3
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 00:05:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55075460.9040408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 16, 2015 at 11:08:32PM CET, john.fastabend@gmail.com wrote:
>On 03/16/2015 07:22 AM, Jiri Pirko wrote:
>>There has been a discussion about if it's better to let masters to
>>propagate call down themself or if its better just blindly go down and
>>try to call ndo on every lower netdev. Turned out that more people (me
>>not included) like the second option better.
>>
>>This patch changes bridge setlink/dellink in that direction.
>>Sorry Roopa for forcing you to do it the way I liked initially.
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Hi Jiri,
>
>I'm going to ask the dumb question here because it wasn't clear from
>the emails I could dredge up.
>
>Why do you want to do this? Can you add it to the commit message so

I don't want to do this. It just look like there has been a consensus
that most of the people want this.

>in the future it is clear. Specifically what does it mean to propagate
>these calls down? Can you give a stacked example?

Example of propagation of ndo call through stacked devices:

dev->ops->ndo_bridge_setlink (team_ndo_bridge_setlink)
		-> for_each_team_port(port_dev)
			-> port_dev->ops->ndo_bridge_setlink(rocker_ndo_bridge_setlink)





>
>Thanks,
>John
>
>-- 
>John Fastabend         Intel Corporation
