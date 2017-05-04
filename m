From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH] aquantia: Fix "ethtool -S" crash when adapter down.
Date: Thu, 4 May 2017 20:09:56 +0300
Message-ID: <d20deac6-7010-c0e8-e4d8-7faa591e7306@aquantia.com>
References: <90666578f043b366313ddd90ffad86de42d890f2.1493914743.git.pavel.belous@aquantia.com>
 <0babf800-080c-96e0-4dbb-8d3fca3fb784@gmx.de>
 <20170504.125113.569969253752966231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darcari@redhat.com
To: David Miller <davem@davemloft.net>, LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0060.outbound.protection.outlook.com ([104.47.36.60]:33907
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751492AbdEDRKM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 13:10:12 -0400
In-Reply-To: <20170504.125113.569969253752966231.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04.05.2017 19:51, David Miller wrote:
> From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
> Date: Thu, 4 May 2017 18:48:12 +0200
>
>> Hi Pavel,
>>
>> On 04.05.2017 18:33, Pavel Belous wrote:
>>> From: Pavel Belous <pavel.belous@aquantia.com>
>>>
>>> This patch fixes the crash that happens when driver tries to collect statistics
>>> from already released "aq_vec" object.
>>>
>>> Fixes: 97bde5c4f909 ("net: ethernet: aquantia: Support for NIC-specific code")
>>> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
>>> ---
>>>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 3 ++-
>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
>>> index cdb0299..3a32573 100644
>>> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
>>> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
>>> @@ -755,7 +755,7 @@ void aq_nic_get_stats(struct aq_nic_s *self, u64 *data)
>>>  	count = 0U;
>>>
>>>  	for (i = 0U, aq_vec = self->aq_vec[0];
>>> -		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
>>> +		aq_vec && self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
>>>  		data += count;
>>>  		aq_vec_get_sw_stats(aq_vec, data, &count);
>>>  	}
>>> @@ -961,6 +961,7 @@ void aq_nic_free_hot_resources(struct aq_nic_s *self)
>>>  	for (i = AQ_DIMOF(self->aq_vec); i--;) {
>>>  		if (self->aq_vec[i])
>>>  			aq_vec_free(self->aq_vec[i]);
>>> +			self->aq_vec[i] = NULL;
>>>  	}
>>>
>>>  err_exit:;
>>>
>>
>> if the driver does not support statistics when the interface is down, would not it be clearer
>> to check if netif_running() in get_stats() instead?
>
> Yes, much cleaner.
>
> Much better would be to have a cached software copy so that statistics
> can be reported regardless of whether the device is down or not.
>

Thank you.
I will think about how to do it better.

Regards,
Pavel
