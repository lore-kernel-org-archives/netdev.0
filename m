From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Re: [PATCH net v2 1/9] macsec: add missing NULL check after kmalloc
Date: Fri, 22 Apr 2016 12:06:11 +0200
Message-ID: <5719F793.4020202@marvell.com>
References: <cover.1461315621.git.sd@queasysnail.net>
 <d358a1ca10006d65c6d799e56d1abb7d17fda4a5.1461315621.git.sd@queasysnail.net>
 <5719F047.80102@marvell.com> <20160422094826.GA17059@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Lance Richardson <lrichard@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:25098 "EHLO
	mx0a-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752443AbcDVKGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 06:06:24 -0400
In-Reply-To: <20160422094826.GA17059@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 22.04.2016 11:48, Sabrina Dubroca wrote:
> 2016-04-22, 11:35:03 +0200, Lino Sanfilippo wrote:
>>
>>
>> On 22.04.2016 11:28, Sabrina Dubroca wrote:
>>> Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
>>> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
>>> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
>>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>> ---
>>>    drivers/net/macsec.c | 4 ++--
>>>    1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
>>> index 84d3e5ca8817..f691030ee3df 100644
>>> --- a/drivers/net/macsec.c
>>> +++ b/drivers/net/macsec.c
>>> @@ -1622,8 +1622,8 @@ static int macsec_add_rxsa(struct sk_buff *skb, struct genl_info *info)
>>>    	}
>>>
>>>    	rx_sa = kmalloc(sizeof(*rx_sa), GFP_KERNEL);
>>> -	if (init_rx_sa(rx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]), secy->key_len,
>>> -		       secy->icv_len)) {
>>> +	if (!rx_sa || init_rx_sa(rx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]),
>>> +				 secy->key_len, secy->icv_len)) {
>>>    		rtnl_unlock();
>>>    		return -ENOMEM;
>>>    	}
>>
>>
>> In case that kmalloc was successful and init_rx_sa failed, the allocated memory should be freed, shouldnt it?.
>
> Yep, Lance pointed that out in v1:
> http://marc.info/?l=linux-netdev&m=146108796406155
>
> But since we have the same code with init_tx_sa, I decided to fix both
> in a separate patch (7/9 in this set).
>

Ah ok, sorry about the noise then :)

Regards,
Lino
