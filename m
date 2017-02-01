From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [patch net-next] sfc: a couple off by one bugs
Date: Wed, 1 Feb 2017 13:34:49 +0000
Message-ID: <d0791f09-a575-de0c-323c-e24f2cfe7dba@canonical.com>
References: <20170201085040.GA31514@mwanda>
 <60d163b6-0b49-172f-288c-e1712e04a84e@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Bert Kenward <bkenward@solarflare.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Edward Cree <ecree@solarflare.com>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:33513 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdBANgU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 08:36:20 -0500
In-Reply-To: <60d163b6-0b49-172f-288c-e1712e04a84e@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/17 13:24, Edward Cree wrote:
> On 01/02/17 08:50, Dan Carpenter wrote:
>> These checks are off by one.  These are just sanity checks and we don't
>> ever pass invalid values for "encap_type" so it's harmless.
>>
>> Fixes: 9b4108012517 ("sfc: insert catch-all filters for encapsulated traffic")
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> One of these was already fixed by Colin Ian King in
> e9904990e8e70a51574e6ec6b872f3c705ec75f0 ("sfc: fix an off-by-one compare on an
> array size").

Ugh, I missed one of those.

> For the other one:
> Acked-by: Edward Cree <ecree@solarflare.com>
>> diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
>> index 8bec9383d754..dec0c8083ff3 100644
>> --- a/drivers/net/ethernet/sfc/ef10.c
>> +++ b/drivers/net/ethernet/sfc/ef10.c
>> @@ -5080,7 +5080,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
>>
>>               /* quick bounds check (BCAST result impossible) */
>>               BUILD_BUG_ON(EFX_EF10_BCAST != 0);
>> -             if (encap_type > ARRAY_SIZE(map) || map[encap_type] == 0) {
>> +             if (encap_type >= ARRAY_SIZE(map) || map[encap_type] == 0) {
>>                       WARN_ON(1);
>>                       return -EINVAL;
>>               }
>> @@ -5134,7 +5134,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
>>
>>               /* quick bounds check (BCAST result impossible) */
>>               BUILD_BUG_ON(EFX_EF10_BCAST != 0);
>> -             if (encap_type > ARRAY_SIZE(map) || map[encap_type] == 0) {
>> +             if (encap_type >= ARRAY_SIZE(map) || map[encap_type] == 0) {
>>                       WARN_ON(1);
>>                       return -EINVAL;
>>               }
> 
> 
> The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
