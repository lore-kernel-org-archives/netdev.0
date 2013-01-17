From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] team: do not use -ENOENT
Date: Thu, 17 Jan 2013 22:15:32 +0100
Message-ID: <20130117211532.GC1591@minipsycho.orion>
References: <20130117203347.GA1591@minipsycho.orion>
 <20130117.154240.1134435647038964241.davem@davemloft.net>
 <20130117205212.GB1591@minipsycho.orion>
 <20130117.160742.614484345035625041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:49067 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064Ab3AQVPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 16:15:36 -0500
Received: by mail-wg0-f45.google.com with SMTP id dq12so1901079wgb.12
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 13:15:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130117.160742.614484345035625041.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 17, 2013 at 10:07:42PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Thu, 17 Jan 2013 21:52:12 +0100
>
>> Thu, Jan 17, 2013 at 09:42:40PM CET, davem@davemloft.net wrote:
>>>From: Jiri Pirko <jiri@resnulli.us>
>>>Date: Thu, 17 Jan 2013 21:33:47 +0100
>>>
>>>>>> @@ -2320,7 +2320,7 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
>>>>>>  			list_add(&opt_inst->tmp_list, &opt_inst_list);
>>>>>>  		}
>>>>>>  		if (!opt_found) {
>>>>>> -			err = -ENOENT;
>>>>>> +			err = -EINVAL;
>>>>>>  			goto team_put;
>>>>>>  		}
>>>>>>  	}
>>>
>>>
>>>> I'm not really sure. But in this case, I do not think that is a problem.
>>>> 
>>>> 1) I'm most probably the only one (libteam) who is using this api and
>>>> libteam does not mind about what err code is returned in these cases.
>>>> 
>>>> 2) In this case, it is only about different number. And one number or
>>>> another, it does not imply userspace to behave differently. In other words,
>>>> userspace should not take different actions in case for example -ENOENT
>>>> or -ENODEV is returned.
>>>
>>>I agree with this analysis.
>>>
>>>But for the team_nl_cmd_options_set() case, I would strongly advise
>>>that you use some error code more descriptive than -EINVAL.  In fact
>>>the existing -ENOENT I feel is better, because it tells the caller
>>>what kind of problem there was.
>>>
>>>Even if you don't like the fact that -ENOENT is oriented towards file
>>>existence, it does convey a ton more information than -EINVAL does.
>> 
>> I understand your feeling, because I have the same one :)
>> But looking all over the code and on possible err codes as well, I did
>> not find any suitable err code to indicate some object was not found.
>> And since I recently saw email from Linus about the fact that -ENOENT
>> should be used only in relation to files, -EINVAL the "default:" in my
>> "switch()".
>
>Look in the packet scheduler API for how much we use -ENOENT in this
>kind of situation where the requested object to operate on could not
>be found.
>
>I think it is entirely appropriate to use -ENOENT, if not completely
>consistent with the rest of the networking.

Okay, fair enough. In that case, I believe that also the other 2
occurrences of -ENOENT in team driver are ok as well. Please scratch this
patch.

Thanks!
