From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH] aquantia: Fix "ethtool -S" crash when adapter down.
Date: Thu, 4 May 2017 20:08:06 +0300
Message-ID: <800da97f-7a4b-6f61-f4ff-51d4ef50e05f@aquantia.com>
References: <90666578f043b366313ddd90ffad86de42d890f2.1493914743.git.pavel.belous@aquantia.com>
 <50047294-4f40-e8ae-0982-5720b87019a9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Arcari <darcari@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0043.outbound.protection.outlook.com ([104.47.38.43]:47584
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751289AbdEDRIV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 13:08:21 -0400
In-Reply-To: <50047294-4f40-e8ae-0982-5720b87019a9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04.05.2017 20:00, David Arcari wrote:
> Hi Pavel,
>
> On 05/04/2017 12:33 PM, Pavel Belous wrote:
>> From: Pavel Belous <pavel.belous@aquantia.com>
>>
>> This patch fixes the crash that happens when driver tries to collect statistics
>> from already released "aq_vec" object.
>>
>> Fixes: 97bde5c4f909 ("net: ethernet: aquantia: Support for NIC-specific code")
>> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
>> ---
>>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
>> index cdb0299..3a32573 100644
>> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
>> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
>> @@ -755,7 +755,7 @@ void aq_nic_get_stats(struct aq_nic_s *self, u64 *data)
>>  	count = 0U;
>>
>>  	for (i = 0U, aq_vec = self->aq_vec[0];
>> -		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
>> +		aq_vec && self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
>>  		data += count;
>>  		aq_vec_get_sw_stats(aq_vec, data, &count);
>>  	}
>> @@ -961,6 +961,7 @@ void aq_nic_free_hot_resources(struct aq_nic_s *self)
>>  	for (i = AQ_DIMOF(self->aq_vec); i--;) {
>>  		if (self->aq_vec[i])
>>  			aq_vec_free(self->aq_vec[i]);
>> +			self->aq_vec[i] = NULL;
>
> I think you intended to to add { } to the if statement.  The code compiles as
> is, but the indentation is not correct.
>
> -DA

Oh. Sorry about that. I did not see the loss of braces during merge.
I will prepare another patch with Lino and David M. comments.

Regards,
Pavel.


>
>>  	}
>>
>>  err_exit:;
>>
>
