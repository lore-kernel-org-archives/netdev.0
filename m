From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 2/2] bridge: netlink dump interface at par with
 brctl
Date: Tue, 10 Jun 2014 07:41:53 -0400
Message-ID: <5396EF01.7030009@mojatatu.com>
References: <1402151244-3324-1-git-send-email-jhs@emojatatu.com> <1402151244-3324-2-git-send-email-jhs@emojatatu.com> <5395E3C4.5080904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com
To: vyasevic@redhat.com, davem@davemloft.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:47966 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbaFJLmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 07:42:12 -0400
Received: by mail-ie0-f178.google.com with SMTP id rd18so95841iec.23
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 04:42:11 -0700 (PDT)
In-Reply-To: <5395E3C4.5080904@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/14 12:41, Vlad Yasevich wrote:
> On 06/07/2014 10:27 AM, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> Actually better than brctl showmacs because we can filter by bridge
>> port in the kernel.
>> The current bridge netlink interface doesnt scale when you have many
>> bridges each with large fdbs or even bridges with many bridge ports
>>
>> For example usage look at accompanying iproute2 patch.
>
> The code was a bit tough to follow.  I think the main reason is
> that you now always pass a filtering devices even when there was
> no filtering information requested.
>
> I am wondering if it could be made simpler...
>

The patch may be hard to follow i think. I cant think of a simple
way to do filtering by br and brport. If you have suggestions, shoot.

>>   	rcu_read_lock();
>> +	if (br_idx) {
>> +		br_dev = __dev_get_by_index(net, br_idx);
>> +		if (!br_dev) {
>> +			rcu_read_unlock();
>> +			return -ENODEV;
>> +		}
>> +		ops = br_dev->netdev_ops;
>> +		bdev = br_dev;
>> +	}
>> +
>
> I think this can be outside of the rcu since you hold an rtnl at this time.
>

Will fix on next iteration.

cheers,
jamal
