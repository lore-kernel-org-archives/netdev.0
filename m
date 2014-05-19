From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 1/9] net/mlx4_core: Enforce irq affinity changes
 immediatly
Date: Mon, 19 May 2014 14:33:32 +0300
Message-ID: <5379EC0C.5070004@mellanox.com>
References: <1399880605-28772-1-git-send-email-amirv@mellanox.com>	 <1399880605-28772-2-git-send-email-amirv@mellanox.com> <1400358787.2647.65.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:36549 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752269AbaESLdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 07:33:39 -0400
In-Reply-To: <1400358787.2647.65.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/17/2014 11:33 PM, Ben Hutchings wrote:
> On Mon, 2014-05-12 at 10:43 +0300, Amir Vadai wrote:
>> From: Yuval Atias <yuvala@mellanox.com>
>>
>> During heavy traffic, napi is constatntly polling the complition queue
>> and no interrupt is fired. Because of that, changes to irq affinity are
>> ignored until traffic is stopped and resumed.
>>
>> By registering to the irq notifier mechanism, and forcing interrupt when
>> affinity is changed, irq affinity changes will be immediatly enforced.
> [...]
>
> This somewhat breaks ARFS in your driver, as that depends on IRQ
> affinity notification.
Interesting...
I missed the fact that irq_set_affinity_notifier is 'set' and not 'add'.
So, do you have objection if I change the API to have a list of 
notifiers instead of only one?

>
> It is also not safe to put an IRQ affinity notification function in a
> module currently, as the work item for notification doesn't carry a
> module reference and could be called after the module is removed.
I can get a module reference when a notifier is added and put it when 
the notifier is removed.

Thanks,
Amir

>
> Ben.
>
