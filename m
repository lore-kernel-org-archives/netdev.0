From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] tc: policing requires a rate estimator
Date: Tue, 25 Nov 2008 19:38:52 +0100
Message-ID: <492C463C.5000202@trash.net>
References: <20081125101656.52348bdd@extreme>	<20081125102113.371db7b1@extreme>	<492C44AD.1010007@trash.net> <20081125103319.19de15c3@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33638 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbYKYSjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 13:39:04 -0500
In-Reply-To: <20081125103319.19de15c3@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 25 Nov 2008 19:32:13 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>>
>>> --- a/net/sched/act_police.c	2008-11-25 10:15:50.000000000 -0800
>>> +++ b/net/sched/act_police.c	2008-11-25 10:17:54.000000000 -0800
>>> @@ -182,6 +182,12 @@ override:
>>>  		R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE]);
>>>  		if (R_tab == NULL)
>>>  			goto failure;
>>> +
>>> +		if (!est && !gen_estimator_active(&police->tcf_rate_est)) {
>>> +			err = -EINVAL;
>>> +			goto failure;
>> This leaks the R_tab reference.
> 
> The previous patch added a put at the failure: tag.

I missed that, sorry.

