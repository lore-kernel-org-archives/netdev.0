From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 net-next 2/4] sh_eth: Add support for r7s72100
Date: Fri, 17 Jan 2014 18:05:12 +0400
Message-ID: <52D93898.5040500@cogentembedded.com>
References: <1389168152-9434-1-git-send-email-horms+renesas@verge.net.au> <1389168152-9434-3-git-send-email-horms+renesas@verge.net.au> <52CDBBE1.1010301@cogentembedded.com> <20140109050351.GE2132@verge.net.au> <52D70F12.9080800@cogentembedded.com> <20140116004943.GF12550@verge.net.au> <52D7FC8D.7000800@cogentembedded.com> <20140117061301.GD16455@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20140117061301.GD16455@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 17-01-2014 10:13, Simon Horman wrote:

>>>>>>> This is a fast ethernet controller.

>>>>>>> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

>>>>>> [...]

>>>>>>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>>>>>>> index 4b38533..cc6d4af 100644
>>>>>>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>>>>>>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>>>>>>> @@ -190,6 +190,59 @@ static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
>>>> [...]
>>>>>>> @@ -701,6 +762,35 @@ static struct sh_eth_cpu_data r8a7740_data = {
>>>>>>>   	.shift_rd0	= 1,
>>>>>>>   };
>>>>>>>
>>>>>>> +/* R7S72100 */
>>>>>>> +static struct sh_eth_cpu_data r7s72100_data = {
>>>>>>> +	.chip_reset	= sh_eth_chip_reset,
>>>>>>> +	.set_duplex	= sh_eth_set_duplex,
>>>>>>> +
>>>>>>> +	.register_type	= SH_ETH_REG_FAST_RZ,
>>>>>>> +
>>>>>>> +	.ecsr_value	= ECSR_ICD,
>>>>>>> +	.ecsipr_value	= ECSIPR_ICDIP,
>>>>>>> +	.eesipr_value	= 0xff7f009f,
>>>>>>> +
>>>>>>> +	.tx_check	= EESR_TC1 | EESR_FTC,
>>>>>>> +	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
>>>>>>> +			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
>>>>>>> +			  EESR_TDE | EESR_ECI,
>>>>>>> +	.fdr_value	= 0x0000070f,
>>>>>>> +	.rmcr_value	= RMCR_RNC,
>>>>>>> +
>>>>>>> +	.apr		= 1,
>>>>>>> +	.mpr		= 1,
>>>>>>> +	.tpauser	= 1,
>>>>>>> +	.hw_swap	= 1,
>>>>>>> +	.rpadir		= 1,
>>>>>>> +	.rpadir_value   = 2 << 16,
>>>>>>> +	.no_trimd	= 1,
>>>>>>> +	.tsu		= 1,
>>>>>>> +	.shift_rd0	= 1,

>>>>>>     Perhaps this field should be renamed to something talking about
>>>>>> check summing support (since bits 0..15 of RD0 contain a frame check
>>>>>> sum for those SoCs). Or maybe it should be just merged with the
>>>>>> 'hw_crc' field...

>>>>> I have no feelings about that one way or another.

>>>>     Do you happen to have R8A7740 manual by chance? If so, does it
>>>> talk about RX check summing support and using RD0 for that?

>>> Yes and yes.

>>> I have taken a quick look and the documentation for RX checksumming on the
>>> R8A7740 appears to be very similar if not the same as that of the R7S72100.

>>> In particular both refer to using the bottom 16 bits of RD0 as
>>> containing the packet checksum.

>>     OK, now if you had SH7734 manual to completely confirm that check
>> sum is stored in the same place there... most probably it is, of
>> course, and we should merge 'hw_crc' and 'shift_rd0' into a single
>> field.

> Unfortunately I don't have access to that manual.

    Anyway, we also need Gen2 manuals accepting the fact that checksumming is 
also supported (they also set 'shift_rd0' field) and giving the mapping of CSMR...

WBR, Sergei

