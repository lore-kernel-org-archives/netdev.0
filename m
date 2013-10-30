From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: Re: [PATCH 2/2] ipv6: Add checks for RAWIP ARP type
Date: Wed, 30 Oct 2013 12:15:22 +0200
Message-ID: <5270DC3A.6040206@linux.intel.com>
References: <1383124271-15290-1-git-send-email-jukka.rissanen@linux.intel.com> <1383124271-15290-3-git-send-email-jukka.rissanen@linux.intel.com> <20131030093137.GA3431@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4789 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272Ab3J3KPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 06:15:25 -0400
In-Reply-To: <20131030093137.GA3431@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,

On 30.10.2013 11:31, Alexander Aring wrote:
> Hi Jukka,
>
> On Wed, Oct 30, 2013 at 11:11:11AM +0200, Jukka Rissanen wrote:
>> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
>> ---
>>   net/ipv6/addrconf.c | 14 +++++++++++++-
>>   1 file changed, 13 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index d6ff126..60bf947 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -1783,6 +1783,15 @@ static int addrconf_ifid_ip6tnl(u8 *eui, struct net_device *dev)
>>   	return 0;
>>   }
>>
>> +static int addrconf_ifid_rawip(u8 *eui, struct net_device *dev)
>> +{
>> +	if (dev->addr_len != 8)
>> +		return -1;
>> +	memcpy(eui, dev->dev_addr, 8);
>> +	eui[0] ^= 2;
>> +	return 0;
>> +}
>> +
>
> I think we have already a function like this, look for:
>
> static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
>
> which is the same for ieee802154 6lowpan. Are there any issues why we
> can't use the same function here?

No issues there, I can certainly prepare a patch that uses the 
addrconf_ifid_eui64() instead.


-- 
Cheers,
Jukka
