From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH 1/5 net-next] tg3: Add 57766 device support.
Date: Thu, 14 Feb 2013 15:13:09 -0800
Message-ID: <511D6F85.6060201@broadcom.com>
References: <1360880022-12856-1-git-send-email-mchan@broadcom.com>
 <1360880750.3051.7.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2992 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934976Ab3BNXNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 18:13:19 -0500
In-Reply-To: <1360880750.3051.7.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/14/2013 02:25 PM, Joe Perches wrote:
> On Thu, 2013-02-14 at 14:13 -0800, Michael Chan wrote:
>> From: Matt Carlson <mcarlson@broadcom.com>
>>
>> The patch also adds a couple of fixes
>>
>>   - For the 57766, bootcode needs to setup the PCIE Fast Training
>>     Sequence (FTS) value to prevent transmit hangs. Unfortunately, it
>>     does not have enough room in the selfboot case (i.e. devices with no
>>     NVRAM).  The driver needs to implement this.
> []
>> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> []
>> @@ -9179,7 +9180,14 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
>>   		}
>>
>>   		if (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_57765_AX) {
>> -			u32 grc_mode = tr32(GRC_MODE);
>> +			u32 grc_mode;
>> +
>> +			/* Fix transmit hangs */
>> +			val = tr32(TG3_CPMU_PADRNG_CTL);
>> +			val |= TG3_CPMU_PADRNG_CTL_RDIV2;
>> +			tw32(TG3_CPMU_PADRNG_CTL, val);
>> +
>
> This seems to write this val to more devices than just
> a 57766.  Intentional?
>

Yes. In addition to the 57766, this fix applies to non-AX revisions of the 57765.

It's not apparent from the patch, but this code chunk is inside the conditional -

	if (tg3_flag(tp, 57765_CLASS)) {

which is set for 57765 and 57766 devices.



>> +			grc_mode = tr32(GRC_MODE);
>>
>>   			/* Access the lower 1K of DL PCIE block registers. */
>>   			val = grc_mode & ~GRC_MODE_PCIE_PORT_MASK;
>
>
>
