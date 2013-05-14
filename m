From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH v2 net 1/2] tg3: Skip powering down function 0 on
 certain serdes devices
Date: Tue, 14 May 2013 11:17:48 -0700
Message-ID: <51927FCC.9000500@broadcom.com>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
 <1368479056-11780-2-git-send-email-nsujir@broadcom.com>
 <1368554932.23628.17.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stable@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: "Joe Perches" <joe@perches.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1368554932.23628.17.camel@joe-AO722>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/14/2013 11:08 AM, Joe Perches wrote:
> On Mon, 2013-05-13 at 14:04 -0700, Nithin Nayak Sujir wrote:
>> On the 5718, 5719 and 5720 serdes devices, powering down function 0
>> results in all the other ports being powered down. Add code to skip
>> function 0 power down.
>
> Hi Nithin.  5718?  I'm confused a bit by the commit message.
>
>> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> []
>> +static bool tg3_phy_power_bug(struct tg3 *tp)
>> +{
>> +	switch (tg3_asic_rev(tp)) {
>> +	case ASIC_REV_5700:
>> +	case ASIC_REV_5704:
>> +		return true;
>> +	case ASIC_REV_5780:
>> +		if (tp->phy_flags & TG3_PHYFLG_MII_SERDES)
>> +			return true;
>> +		return false;
>> +	case ASIC_REV_5717:
>> +		if (!tp->pci_fn)
>> +			return true;
>> +		return false;
>> +	case ASIC_REV_5719:
>> +	case ASIC_REV_5720:
>> +		if ((tp->phy_flags & TG3_PHYFLG_PHY_SERDES) &&
>> +		    !tp->pci_fn)
>> +			return true;
>> +		return false;
>> +	}
>> +
>
> Where is the 5718 in this?
> What is the 5718?
> There is no #define for it.
>

The 5718 is another device in the same family as the 5719 and 5720. There is no 
case or define for the ASIC_REV because it has the same asic revision as the 5719.

However, it is a separate device and you can find it in the pci table and in the 
code as TG3PCI_DEVICE_TIGON3_5718.


>
>
