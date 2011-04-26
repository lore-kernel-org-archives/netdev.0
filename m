From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/3] bql: Byte queue limits
Date: Tue, 26 Apr 2011 07:13:38 -0700
Message-ID: <BANLkTi=xTTjcG7CVfCk8sWojRSZhST+e_Q@mail.gmail.com>
References: <alpine.DEB.2.00.1104252128290.5895@pokey.mtv.corp.google.com>
	<1303796313.2747.190.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:59772 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811Ab1DZONm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 10:13:42 -0400
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p3QEDfnH016763
	for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 07:13:41 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by kpbe15.cbf.corp.google.com with ESMTP id p3QEDd1M009519
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 07:13:39 -0700
Received: by pzk2 with SMTP id 2so306033pzk.9
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 07:13:38 -0700 (PDT)
In-Reply-To: <1303796313.2747.190.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Wow... magical values and very limited advices how to tune them.
>
The intent is that the algorithm is sufficiently adaptive so that no
tuning should be required.

> Tom, this reminds me you were supposed to provide Documentation/files=
 to
> describe RPS, RFS, XPS ...
>
We'll look into that.

> We receive many questions about these features...
>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>> =A0include/linux/netdevice.h | =A0 46 +++++++++++++++-
>> =A0net/core/net-sysfs.c =A0 =A0 =A0| =A0137 ++++++++++++++++++++++++=
+++++++++++++++++++--
>> =A02 files changed, 177 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index cb8178a..0a76b88 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -44,6 +44,7 @@
>> =A0#include <linux/rculist.h>
>> =A0#include <linux/dmaengine.h>
>> =A0#include <linux/workqueue.h>
>> +#include <linux/dynamic_queue_limits.h>
>>
>> =A0#include <linux/ethtool.h>
>> =A0#include <net/net_namespace.h>
>> @@ -556,8 +557,10 @@ struct netdev_queue {
>> =A0 =A0 =A0 struct Qdisc =A0 =A0 =A0 =A0 =A0 =A0*qdisc;
>> =A0 =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 state;
>> =A0 =A0 =A0 struct Qdisc =A0 =A0 =A0 =A0 =A0 =A0*qdisc_sleeping;
>> -#ifdef CONFIG_RPS
>> +#ifdef CONFIG_XPS
>> =A0 =A0 =A0 struct kobject =A0 =A0 =A0 =A0 =A0kobj;
>> + =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do_bql;
>> + =A0 =A0 struct dql =A0 =A0 =A0 =A0 =A0 =A0 =A0dql;
>> =A0#endif
>
> I have no idea why you use CONFIG_XPS for BQL (how BQL is it related =
to

I'll add CONFIG_BQL

> SMP ???), and why kobj is now guarded by CONFIG_XPS instead of
> CONFIG_RPS.
>
Because that kobj is for transmit side (currently only for xps_cpus)

>
>
>
