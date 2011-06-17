From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next] ip: introduce ip_is_fragment helper inline function
Date: Fri, 17 Jun 2011 14:24:14 -0400
Message-ID: <4DFB9BCE.2060000@windriver.com>
References: <1308334091-10031-1-git-send-email-paul.gortmaker@windriver.com> <1308334764.2831.18.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47562 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932107Ab1FQSYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 14:24:20 -0400
In-Reply-To: <1308334764.2831.18.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-06-17 02:19 PM, Ben Hutchings wrote:
> On Fri, 2011-06-17 at 14:08 -0400, Paul Gortmaker wrote:
>> There are enough instances of this:
>>
>>     iph->frag_off & htons(IP_MF | IP_OFFSET)
>>
>> that a helper function is probably warranted.
> [...]
>> --- a/drivers/net/s2io.c
>> +++ b/drivers/net/s2io.c
>> @@ -4111,7 +4111,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
>>  			struct tcphdr *th;
>>  			ip = ip_hdr(skb);
>>  
>> -			if ((ip->frag_off & htons(IP_OFFSET|IP_MF)) == 0) {
>> +			if (ip_is_fragment(ip) == 0) {
>>  				th = (struct tcphdr *)(((unsigned char *)ip) +
>>  						       ip->ihl*4);
>>  
> 
> The condition should be written more clearly as !ip_is_fragment().

Agreed, and I actually had that but then "un-did" it since
I didn't want to force my choices of coding style down
into drivers.  Maybe I was just being overcautious.

> 
> [...]
>> diff --git a/include/net/ip.h b/include/net/ip.h
>> index e9ea7c7..114a152 100644
>> --- a/include/net/ip.h
>> +++ b/include/net/ip.h
>> @@ -250,6 +250,11 @@ int ip_decrease_ttl(struct iphdr *iph)
>>  	return --iph->ttl;
>>  }
>>  
>> +static inline int ip_is_fragment(const struct iphdr *iph)
>> +{
>> +	return iph->frag_off & htons(IP_MF | IP_OFFSET);
>> +}
>> +
>>  static inline
>>  int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
>>  {
> [..]
> 
> The return type should be bool.

I can make that change.  I'll sit on it for a bit in case anyone
else sees anything else needing a tweak.

Thanks Ben,
Paul.

> 
> Ben.
> 
