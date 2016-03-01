From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH 3/4] net: can: ifi: Fix RX and TX ID mask
Date: Tue, 01 Mar 2016 22:23:28 +0100
Message-ID: <56D60850.8080103@denx.de>
References: <1456775971-4946-1-git-send-email-marex@denx.de> <1456775971-4946-4-git-send-email-marex@denx.de> <56D5D635.1050005@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <56D5D635.1050005@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/01/2016 06:49 PM, Oliver Hartkopp wrote:
> Hi Marek,

Hi Oliver,

> On 02/29/2016 08:59 PM, Marek Vasut wrote:
>> The RX and TX ID mask for CAN2.0 is 11 bits wide. This patch fixes
>> the incorrect mask, which caused the CAN IDs to miss the MSBit both
>> on receive and transmit.
>>
>> Signed-off-by: Marek Vasut <marex@denx.de>
>> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Oliver Hartkopp <socketcan@hartkopp.net>
>> Cc: Wolfgang Grandegger <wg@grandegger.com>
>> ---
>>  drivers/net/can/ifi_canfd/ifi_canfd.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/can/ifi_canfd/ifi_canfd.c b/drivers/net/can/ifi_canfd/ifi_canfd.c
>> index 82a33bd..6704098 100644
>> --- a/drivers/net/can/ifi_canfd/ifi_canfd.c
>> +++ b/drivers/net/can/ifi_canfd/ifi_canfd.c
>> @@ -135,7 +135,7 @@
>>  
>>  #define IFI_CANFD_RXFIFO_ID			0x6c
>>  #define IFI_CANFD_RXFIFO_ID_ID_OFFSET		0
>> -#define IFI_CANFD_RXFIFO_ID_ID_STD_MASK		0x3ff
>> +#define IFI_CANFD_RXFIFO_ID_ID_STD_MASK		0x7ff
>>  #define IFI_CANFD_RXFIFO_ID_ID_XTD_MASK		0x1fffffff
> 
> You should use the CAN_SFF_MASK and CAN_EFF_MASK in your code instead of
> defining you private IFI_CANFD_RXFIFO_ID_ID_?TD_MASK definitions.
> 
> You won't have trapped into this problem then :-)

These are register bitfield definitions, so should I really ?

My OCD kicks in and tells me it'd be odd and inconsistent with the rest
of the bitfields, but if you prefer it that way, I'll just send an
updated patch.

>>  #define IFI_CANFD_RXFIFO_ID_IDE			BIT(29)
>>  
>> @@ -156,7 +156,7 @@
>>  
>>  #define IFI_CANFD_TXFIFO_ID			0xbc
>>  #define IFI_CANFD_TXFIFO_ID_ID_OFFSET		0
>> -#define IFI_CANFD_TXFIFO_ID_ID_STD_MASK		0x3ff
>> +#define IFI_CANFD_TXFIFO_ID_ID_STD_MASK		0x7ff
>>  #define IFI_CANFD_TXFIFO_ID_ID_XTD_MASK		0x1fffffff
> 
> dito.
> 
> 
> Regards,
> Oliver
> 
>>  #define IFI_CANFD_TXFIFO_ID_IDE			BIT(29)
>>  
>>


-- 
Best regards,
Marek Vasut
