From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ethtool: check the ethtool_ops is NULL in dev_ethtool
Date: Tue, 18 Feb 2014 10:22:01 +0100
Message-ID: <53032639.3060701@redhat.com>
References: <5301F32C.4040704@huawei.com> <53024266.8010700@redhat.com> <5302B57A.1040806@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47419 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754473AbaBRJWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 04:22:09 -0500
In-Reply-To: <5302B57A.1040806@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2014 02:20 AM, Wang Weidong wrote:
> On 2014/2/18 1:09, Daniel Borkmann wrote:
>> On 02/17/2014 12:31 PM, Wang Weidong wrote:
>>> some drivers maybe not implement the ethtool_ops with only
>>> set NULL. So when call the ethtool cmds will lead to a
>>> 'NULL pointer dereference'.
>>>
>>> So add a checking in dev_ethtool.
>>>
>>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>>> ---
>>>    net/core/ethtool.c | 3 +++
>>>    1 file changed, 3 insertions(+)
>>>
>>> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
>>> index 30071de..f418dcb 100644
>>> --- a/net/core/ethtool.c
>>> +++ b/net/core/ethtool.c
>>> @@ -1499,6 +1499,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
>>>            if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
>>>                return -EPERM;
>>>        }
>>> +
>>
>> You have a trailing whitespace/tab in the line above. Please
>> use checkpatch for detecting such things.
>>
> Sorry for that. I will fix it soon.
>
>> Can you be more specific with "some drivers"? Any driver that
>> is in the mainline tree?
>>
> No. My team implements a driver without considering the ethtool_ops.
> So I got the problem.

If it's code that is out of the mainline tree, then why should the
kernel support that? Submit your driver to the tree first, and then
such a change could be considered. Or, even better, let them implement
ethtool ops/stubs.

>>> +    if (!dev->ethtool_ops)
>>> +        return -EOPNOTSUPP;
>>>
>>>        if (dev->ethtool_ops->begin) {
>>>            rc = dev->ethtool_ops->begin(dev);
>>>
>>
>>
>
>
