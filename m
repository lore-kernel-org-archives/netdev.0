From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: xfrm: Fix initialize repl field of struct xfrm_state
Date: Mon, 21 Mar 2011 14:49:14 +0800
Message-ID: <4D86F4EA.6030909@cn.fujitsu.com>
References: <4D86E603.8080704@cn.fujitsu.com>	<20110320.225542.71119753.davem@davemloft.net>	<4D86F1FD.3080009@cn.fujitsu.com> <20110320.234606.183056322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56706 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751133Ab1CUG5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 02:57:11 -0400
In-Reply-To: <20110320.234606.183056322.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> Date: Mon, 21 Mar 2011 14:36:45 +0800
>
>> Sorry for not said clearly, at the first time I want to do like this. 
>> But when I grep 'xfrm_init_state', it be used in many place, not
>> any pf_key, but also XFRM MIGRATE, ipcomp, ipcomp6. So I did this ugly
>> patch by add this to xfrm_init_state() to avoid dup code.
>>
>> Not sure whether the other case like ipcomp/ipcomp6 etc can cause panic, if
>> it panic, maybe we can fix by introduce new xfrm_init_replay() function
>> like to assign the default reply function.
>>   int xfrm_init_replay(struct xfrm_state *x)
>>   {
>>   	x->repl = &xfrm_replay_legacy;
>>   	return 0;
>>   }
>> and change the orig xfrm_init_replay to xfrm_update_replay()? 
>> Or dup those code to all used place?
>>
>> If I was wrong, I will fix this by adding the necessary call to af_key.c.
> Ok, thanks for the explanation.
>
> I think there is a simple way out of this:
>
> 1) Rename current xfrm_init_state to __xfrm_init_state, add
>    "bool init_replay" argument.  Add the xfrm_init_replay()
>    call, as in your patch, but conditionalized on this boolean.
>
> 2) Implement xfrm_init_state as inline, which calls
>    __xfrm_init_state(..., true)
>
> 3) Replace xfrm_init_state() call in xfrm_user.c with
>    __xfrm_init_state(..., false)
>
> This seems to avoid all the problems.  We don't need to touch every
> caller, and we avoid initializing the replay state twice in xfrm_user
>
> Ok?

This OK, I will do this change, thanks.

>
>
