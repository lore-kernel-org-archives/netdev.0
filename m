From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH net 1/2] tg3: Skip powering down function 0 on
 certain serdes devices
Date: Mon, 13 May 2013 11:31:21 -0700
Message-ID: <51913179.7080204@broadcom.com>
References: <1368468227-18710-1-git-send-email-nsujir@broadcom.com>
 <1368468227-18710-2-git-send-email-nsujir@broadcom.com>
 <1368469301.1913.24.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stable@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: "Joe Perches" <joe@perches.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1368469301.1913.24.camel@joe-AO722>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/13/2013 11:21 AM, Joe Perches wrote:
> On Mon, 2013-05-13 at 11:03 -0700, Nithin Nayak Sujir wrote:
>> On the 5718, 5719 and 5720 serdes devices, powering down function 0
>> results in all the other ports being powered down. Add code to skip
>> function 0 power down.
>>
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Michael Chan <mchan@broadcom.com>
>> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
>> ---
>>   drivers/net/ethernet/broadcom/tg3.c | 24 ++++++++++++++++++------
>>   1 file changed, 18 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
>> index 728d42a..737f035 100644
>> --- a/drivers/net/ethernet/broadcom/tg3.c
>> +++ b/drivers/net/ethernet/broadcom/tg3.c
>> @@ -2957,6 +2957,23 @@ static int tg3_5700_link_polarity(struct tg3 *tp, u32 speed)
>>   	return 0;
>>   }
>>
>> +static bool tg3_phy_power_bug(struct tg3 *tp)
>> +{
>> +	if (tg3_asic_rev(tp) == ASIC_REV_5700 ||
>> +	    tg3_asic_rev(tp) == ASIC_REV_5704 ||
>> +	    (tg3_asic_rev(tp) == ASIC_REV_5780 &&
>> +	     (tp->phy_flags & TG3_PHYFLG_MII_SERDES)) ||
>> +	    (tg3_asic_rev(tp) == ASIC_REV_5717 &&
>> +	     !tp->pci_fn) ||
>> +	    ((tg3_asic_rev(tp) == ASIC_REV_5719 ||
>> +	      tg3_asic_rev(tp) == ASIC_REV_5720) &&
>> +	     (tp->phy_flags & TG3_PHYFLG_PHY_SERDES) &&
>> +	     !tp->pci_fn))
>> +		return true;
>
> I think this would be a lot easier to read and
> more easily extended using a switch/case like:
>

Will do, I'll resubmit with this change.

> static bool tg3_phy_power_bug(struct tg3 *tp)
> {
> 	switch (tg3_asic_rev(tp)) {
> 	case ASIC_REV_5700:
> 	case ASIC_REV_5704:
> 		return true;
> 	case ASIC_REV_5717:
> 		if (!tp_>pci_fn)
> 			return true;
> 		return false;
> 	case ASIC_REV_5719:
> 	case ASIC_REV_5720:
> 		if ((tp_>phy_flags & TG3_PHYFLG_PHY_SERDES) &&
> 		    !tp->pci_fn)
> 			return true;
> 		return false;
> 	case ASIC_REV_5780:
> 		if (tp->phy_flags & TG3_PHYFLG_MII_SERDES)
> 			return true;
> 		return false;
> 	}
>
> 	return false;
> }
>
>
>
