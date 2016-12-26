From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] net: dev_weight: TX/RX orthogonality,Re: [PATCH v1]
 net: dev_weight: TX/RX orthogonality
Date: Mon, 26 Dec 2016 11:58:18 -0500 (EST)
Message-ID: <20161226.115818.1691666598003246082.davem@davemloft.net>
References: <1482745763-15082-1-git-send-email-matthias.tafelmeier@gmx.net>
        <20161226.105238.2087282115500549289.davem@davemloft.net>
        <ae0712c3-61c6-432e-78d9-665d0c291c9f@gmx.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hagen@jauu.net, fw@strlen.de,
        edumazet@google.com, daniel@iogearbox.net
To: matthias.tafelmeier@gmx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754563AbcLZQ6X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 11:58:23 -0500
In-Reply-To: <ae0712c3-61c6-432e-78d9-665d0c291c9f@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Date: Mon, 26 Dec 2016 17:43:08 +0100

> 
>> From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
>> Date: Mon, 26 Dec 2016 10:49:23 +0100
>>
>>> @@ -269,13 +269,21 @@ static struct ctl_table net_core_table[] = {
>>>  		.extra1		= &min_rcvbuf,
>>>  	},
>>>  	{
>>> -		.procname	= "dev_weight",
>>> -		.data		= &weight_p,
>>> +		.procname	= "dev_weight_rx",
>>> +		.data		= &weight_p_rx,
>>  ...
>>>  	{
>>> +		.procname	= "dev_weight_tx",
>> Sysctls are user visible APIs.  You cannot change them without
>> breaking userspace.  You particularly cannot change the name of
>> the sysctl.
> 
> What about leaving *dev_weight* in place for TX side as is and newly
> introducing a sysctl param
> *dev_weight_rx*. Though, am open to a better naming for the latter.

This changes behavior for existing users, you cannot do this.
