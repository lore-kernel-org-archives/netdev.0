From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC 04/12] ndisc: get rid off dev parameter in
 ndisc_opt_addr_space
Date: Fri, 27 May 2016 18:56:08 +0200
Message-ID: <0f311957-d645-422a-bf58-9aa3412b0bb4@stressinduktion.org>
References: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
 <1464031328-17524-5-git-send-email-aar@pengutronix.de>
 <574534F8.20308@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, stefan@osg.samsung.com,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Alexander Aring <aar@pengutronix.de>,
	linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:34454 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751307AbcE0Q4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 12:56:15 -0400
In-Reply-To: <574534F8.20308@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.05.2016 07:15, YOSHIFUJI Hideaki wrote:
> 
> 
> Alexander Aring wrote:
>> This patch removes the net_device parameter from ndisc_opt_addr_space
>> function. This can be useful for calling such functionality which
>> doesn't depends on dev parameter. For current existing functionality
>> which depends on dev parameter, we introduce ndisc_dev_opt_addr_space to have
>> an easy replacement for the ndisc_opt_addr_space function.
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
>> Cc: James Morris <jmorris@namei.org>
>> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>> Cc: Patrick McHardy <kaber@trash.net>
>> Signed-off-by: Alexander Aring <aar@pengutronix.de>
>> ---
>>  include/net/ndisc.h | 13 +++++++++----
>>  net/ipv6/ndisc.c    | 12 ++++++------
>>  2 files changed, 15 insertions(+), 10 deletions(-)
>>
>> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
>> index 2d8edaa..dbc8d01 100644
>> --- a/include/net/ndisc.h
>> +++ b/include/net/ndisc.h
>> @@ -127,10 +127,15 @@ static inline int ndisc_addr_option_pad(unsigned short type)
>>  	}
>>  }
>>  
>> -static inline int ndisc_opt_addr_space(struct net_device *dev)
>> +static inline int ndisc_opt_addr_space(unsigned char addr_len, int pad)
>>  {
>> -	return NDISC_OPT_SPACE(dev->addr_len +
>> -			       ndisc_addr_option_pad(dev->type));
>> +	return NDISC_OPT_SPACE(addr_len + pad);
>> +}
>> +
>> +static inline int ndisc_dev_opt_addr_space(const struct net_device *dev)
>> +{
>> +	return ndisc_opt_addr_space(dev->addr_len,
>> +				    ndisc_addr_option_pad(dev->type));
>>  }
>>  
> 
> I prefer not to change existing functions such as ndisc_opt_addr_space(),
> and name new function __ndisc_opt_addr_space() etc.
> 
> Plus, my original thought (when I implement these functions) was to
> have per-net_device ndisc_opt_addr_spece(), ndisc_opt_adr_data() etc.
> 
> What do you think of that?

As I understood it 6lowpan devices need to handle both, non-compressed
and compressed options/addresses. Probably one can make them
per-interface, but a change to the arguments has still to happen.

Alex?

Thanks,
Hannes
