From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [3/4] bonding: the calling of bond->slave_cnt need protection
Date: Mon, 22 Jul 2013 08:47:49 +0800
Message-ID: <51EC8135.8060509@huawei.com>
References: <51EA3B0D.7020501@huawei.com> <20130720104746.GC9149@redhat.com> <51EA85BD.2080409@redhat.com> <20130720150041.GE9149@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:8710 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704Ab3GVAsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 20:48:05 -0400
In-Reply-To: <20130720150041.GE9149@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/7/20 23:00, Veaceslav Falico wrote:
> On Sat, Jul 20, 2013 at 02:42:37PM +0200, Nikolay Aleksandrov wrote:
>> On 07/20/2013 12:47 PM, Veaceslav Falico wrote:
>>> On Sat, Jul 20, 2013 at 03:23:57PM +0800, dingtianhong wrote:
>>>> The bonding_store_mode has rtnl protection, so no need to get read lock
>>>> for bond->slave_cnt, but the bonding_store_fail_over_mac need to protect
>>>> the bond->slave_cnt, so add read_lock().
>>>>
>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>>
>> <snip>
>>>
>>> Maybe it's Saturday, but I really don't see *any* point in this locking.
>>>
>>> I think you've meant that we need the rtnl protection while reading
>>> slave_cnt AND updating the .fail_over_mac, so that in between we won't add
>>> new slaves with outdated params.
>>>
>>> Something like this (untested):
>>>
>> Indeed, Veaceslav's way is the correct one (I've looked at this race
>> before), but IMO it's not worth it to protect fail_over_mac as the worst
>> that could happen is inconsistency with the MAC addresses which isn't
>> fatal. Anyway, I still haven't had my coffee and might be missing something :-)
> 
> Yep, agree that it's kind of minor and hard to hit in real life.
> 
> OTOH, getting the rtnl here costs us virtually nothing and might save
> someone from a headache :). And it also follows the logic "don't change
> anything slave-related without rtnl".
> 
> So I'd rather have it, as a minor improvement :).
> 
>>
>> Cheers,
>> Nik

yes , i think it is hard to hit the problem in real lift, just looks better. :)

>>
> 
> 
