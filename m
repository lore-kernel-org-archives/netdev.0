From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCHv2 1/3] ethtool: stmmac: Fix Designware ethtool register
 dump
Date: Fri, 7 Jul 2017 09:10:49 +0200
Message-ID: <f5a184a4-95ea-33d4-473c-ea9da266c12c@st.com>
References: <1498662822-12173-1-git-send-email-thor.thayer@linux.intel.com>
 <1498662822-12173-2-git-send-email-thor.thayer@linux.intel.com>
 <81e6d065-bd74-6af8-de4f-7722d0b1e270@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <thor.thayer@linux.intel.com>, <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:49709 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752361AbdGGHLt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 03:11:49 -0400
In-Reply-To: <81e6d065-bd74-6af8-de4f-7722d0b1e270@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/2017 10:22 PM, Thor Thayer wrote:
> On 06/28/2017 10:13 AM, thor.thayer@linux.intel.com wrote:
>> From: Thor Thayer <thor.thayer@linux.intel.com>
>>
>> The commit fbf68229ffe7 ("net: stmmac: unify registers dumps methods")
>>
>> in the Linux kernel modified the register dump to store the DMA 
>> registers
>> at the DMA register offset (0x1000) but ethtool (stmmac.c) looks for the
>> DMA registers after the MAC registers which is offset 12.
>> This patch adds the DMA register offset so that indexing is correct.
>>
>> Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
>> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> ---
>> v2  Modify the commit message to specify commit from Linux kernel.
>>      Add Acked-by.
>> ---
>
> Please disregard this patch.
>
> After further reflection, it would be better to leave this alone and 
> change the kernel driver. This change would require using different 
> ethtool for different versions.
>
> The other 2 patches with macro changes are still valid.

I think it is better to resend a V3 with the two patches

Regards
Peppe

>
> Thanks,
>
> Thor
>
>>   stmmac.c | 5 +++++
>>   1 file changed, 5 insertions(+)
>>
>> diff --git a/stmmac.c b/stmmac.c
>> index fb69bfe..e1bb291 100644
>> --- a/stmmac.c
>> +++ b/stmmac.c
>> @@ -14,6 +14,9 @@
>>   #include <string.h>
>>   #include "internal.h"
>>   +/* The DMA Registers start at offset 0x1000 in the DW IP */
>> +#define DMA_REG_OFFSET    (0x1000 / 4)
>> +
>>   int st_mac100_dump_regs(struct ethtool_drvinfo *info,
>>               struct ethtool_regs *regs)
>>   {
>> @@ -36,6 +39,7 @@ int st_mac100_dump_regs(struct ethtool_drvinfo *info,
>>         fprintf(stdout, "\n");
>>       fprintf(stdout, "DMA Registers\n");
>> +    stmmac_reg = (unsigned int *)regs->data + DMA_REG_OFFSET;
>>       for (i = 0; i < 9; i++)
>>           fprintf(stdout, "CSR%d  0x%08X\n", i, *stmmac_reg++);
>>   @@ -59,6 +63,7 @@ int st_gmac_dump_regs(struct ethtool_drvinfo 
>> *info, struct ethtool_regs *regs)
>>         fprintf(stdout, "\n");
>>       fprintf(stdout, "DMA Registers\n");
>> +    stmmac_reg = (unsigned int *)regs->data + DMA_REG_OFFSET;
>>       for (i = 0; i < 22; i++)
>>           fprintf(stdout, "Reg%d  0x%08X\n", i, *stmmac_reg++);
>>
>
>
