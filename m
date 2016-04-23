From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [PATCH net-next 2/9] libnl: nla_put_le64(): align on a 64-bit
 area
Date: Sat, 23 Apr 2016 19:05:41 +0200
Message-ID: <60b94d1a-23a2-ec18-7f2b-2ba21946af03@pengutronix.de>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461339084-3849-3-git-send-email-nicolas.dichtel@6wind.com>
 <1461343880.7627.34.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, linux-wpan@vger.kernel.org,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, bsingharora@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1461343880.7627.34.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

On 04/22/2016 06:51 PM, Eric Dumazet wrote:
> On Fri, 2016-04-22 at 17:31 +0200, Nicolas Dichtel wrote:
>> nla_data() is now aligned on a 64-bit area.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>  include/net/netlink.h     |  8 +++++---
>>  include/net/nl802154.h    |  6 ++++++
>>  net/ieee802154/nl802154.c | 13 ++++++++-----
>>  3 files changed, 19 insertions(+), 8 deletions(-)
>>
>> diff --git a/include/net/netlink.h b/include/net/netlink.h
>> index 6f51a8a06498..7f6b99483ab7 100644
>> --- a/include/net/netlink.h
>> +++ b/include/net/netlink.h
>> @@ -878,14 +878,16 @@ static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value)
>>  }
>>  
>>  /**
>> - * nla_put_le64 - Add a __le64 netlink attribute to a socket buffer
>> + * nla_put_le64 - Add a __le64 netlink attribute to a socket buffer and align it
>>   * @skb: socket buffer to add attribute to
>>   * @attrtype: attribute type
>>   * @value: numeric value
>> + * @padattr: attribute type for the padding
>>   */
>> -static inline int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value)
>> +static inline int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value,
>> +			       int padattr)
>>  {
>> -	return nla_put(skb, attrtype, sizeof(__le64), &value);
>> +	return nla_put_64bit(skb, attrtype, sizeof(__le64), &value, padattr);
>>  }
>>  
> 
> But _why_ is it needed ?
> 
> nla_put() has no alignment assumptions, it simply copies 8 bytes.
> 
> Seems this is going too far.
> 

if this is really needed, then nla_put_u64/be64/etc need to be changed also,
or? The function nla_put_u64 is the same like nla_put_le64 but with __le64
type, so sparse will not complain about that.

- Alex
