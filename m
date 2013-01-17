From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] team: do not use -ENOENT
Date: Thu, 17 Jan 2013 15:42:40 -0500 (EST)
Message-ID: <20130117.154240.1134435647038964241.davem@davemloft.net>
References: <1358418300-2346-1-git-send-email-jiri@resnulli.us>
	<20130117075115.731c4cf0@nehalam.linuxnetplumber.net>
	<20130117203347.GA1591@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104Ab3AQUmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 15:42:42 -0500
In-Reply-To: <20130117203347.GA1591@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 17 Jan 2013 21:33:47 +0100

>>> @@ -2320,7 +2320,7 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
>>>  			list_add(&opt_inst->tmp_list, &opt_inst_list);
>>>  		}
>>>  		if (!opt_found) {
>>> -			err = -ENOENT;
>>> +			err = -EINVAL;
>>>  			goto team_put;
>>>  		}
>>>  	}


> I'm not really sure. But in this case, I do not think that is a problem.
> 
> 1) I'm most probably the only one (libteam) who is using this api and
> libteam does not mind about what err code is returned in these cases.
> 
> 2) In this case, it is only about different number. And one number or
> another, it does not imply userspace to behave differently. In other words,
> userspace should not take different actions in case for example -ENOENT
> or -ENODEV is returned.

I agree with this analysis.

But for the team_nl_cmd_options_set() case, I would strongly advise
that you use some error code more descriptive than -EINVAL.  In fact
the existing -ENOENT I feel is better, because it tells the caller
what kind of problem there was.

Even if you don't like the fact that -ENOENT is oriented towards file
existence, it does convey a ton more information than -EINVAL does.
