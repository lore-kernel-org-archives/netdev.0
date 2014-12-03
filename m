From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net v1 1/2] amd-xgbe: Do not clear interrupt indicator
Date: Wed, 3 Dec 2014 08:27:58 -0600
Message-ID: <547F1DEE.2070808@amd.com>
References: <20141203001642.17582.32777.stgit@tlendack-t1.amdoffice.net>
 <20141203001648.17582.48766.stgit@tlendack-t1.amdoffice.net>
 <547EF54B.1050308@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0104.outbound.protection.outlook.com ([157.56.110.104]:9312
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752882AbaLCO2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 09:28:09 -0500
In-Reply-To: <547EF54B.1050308@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2014 05:34 AM, Sergei Shtylyov wrote:
> Hello.
>
> On 12/3/2014 3:16 AM, Tom Lendacky wrote:
>
>> The interrupt value within the xgbe_ring_data structure is used as an
>> indicator of which Rx descriptor should have the INTE bit set to
>> generate an interrupt when that Rx descriptor is used.  This bit was
>> mistakenly cleared in the xgbe_unmap_rdata function, effectively
>
>     Not xgbe_unmap_skb() (as seems to follow from the patch)?

Yup, I'm mixing up my versions between net-next and net. I'll send
an updated version with a more appropriate comment.

Thanks,
Tom

>
>> nullifying the ethtool rx-frames support.
>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   drivers/net/ethernet/amd/xgbe/xgbe-desc.c |    1 -
>>   1 file changed, 1 deletion(-)
>
>> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
>> b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
>> index 6fc5da0..43b7d2e 100644
>> --- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
>> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
>> @@ -356,7 +356,6 @@ static void xgbe_unmap_skb(struct xgbe_prv_data
>> *pdata,
>>
>>       rdata->tso_header = 0;
>>       rdata->len = 0;
>> -    rdata->interrupt = 0;
>>       rdata->mapped_as_page = 0;
>>
>>       if (rdata->state_saved) {
>
> WBR, Sergei
>
