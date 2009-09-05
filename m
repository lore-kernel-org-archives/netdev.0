From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net_sched 02/07: make cls_ops->tcf_chain() optional
Date: Sat, 05 Sep 2009 13:57:01 +0200
Message-ID: <4AA2520D.2060603@gmail.com>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet> <20090904164113.27300.79145.sendpatchset@x2.localnet> <4AA21D9F.8090600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:44011 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757313AbZIEL5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 07:57:16 -0400
Received: by fxm17 with SMTP id 17so1161796fxm.37
        for <netdev@vger.kernel.org>; Sat, 05 Sep 2009 04:57:18 -0700 (PDT)
In-Reply-To: <4AA21D9F.8090600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 09/05/2009 10:13 AM:

> Patrick McHardy wrote, On 09/04/2009 06:41 PM:
> 
>> commit 6ea4233ef8f398289a14a3305d4ed440fb026d43
>> Author: Patrick McHardy <kaber@trash.net>
>> Date:   Fri Sep 4 14:28:11 2009 +0200
>>
>>     net_sched: make cls_ops->tcf_chain() optional
>>     
>>     Some qdiscs don't support attaching filters. Handle this centrally in
>>     cls_api and return a proper errno code (EOPNOTSUPP) instead of EINVAL.
>>     
>>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>>
>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>> index 09cdcdf..eaa8f43 100644
>> --- a/net/sched/cls_api.c
>> +++ b/net/sched/cls_api.c
>> @@ -181,6 +181,9 @@ replay:
>>  	if ((cops = q->ops->cl_ops) == NULL)
>>  		return -EINVAL;
>>  
>> +	if (cops->tcf_chain == NULL)
>> +		return -EOPNOTSUPP;
>> +
> 
> 
> You should probably repeat this in tc_dump_tfilter.
 

...In case somebody finds the way to list a filter before
adding it. ;-) But, since it's quite unlikely, let's foget it.

Sorry,

Jarek P.
