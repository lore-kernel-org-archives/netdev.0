From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH 3/4] net: can: ifi: Fix RX and TX ID mask
Date: Wed, 02 Mar 2016 11:28:42 +0100
Message-ID: <56D6C05A.9020503@denx.de>
References: <1456775971-4946-1-git-send-email-marex@denx.de> <1456775971-4946-4-git-send-email-marex@denx.de> <56D5D635.1050005@hartkopp.net> <56D60850.8080103@denx.de> <56D683C2.5080402@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:50978 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754431AbcCBK2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 05:28:54 -0500
In-Reply-To: <56D683C2.5080402@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2016 07:10 AM, Oliver Hartkopp wrote:
> Hi Marek,
> 
> On 03/01/2016 10:23 PM, Marek Vasut wrote:
>> On 03/01/2016 06:49 PM, Oliver Hartkopp wrote:
> 
> 
>>>> -#define IFI_CANFD_RXFIFO_ID_ID_STD_MASK		0x3ff
>>>> +#define IFI_CANFD_RXFIFO_ID_ID_STD_MASK		0x7ff
>>>>  #define IFI_CANFD_RXFIFO_ID_ID_XTD_MASK		0x1fffffff
>>>
>>> You should use the CAN_SFF_MASK and CAN_EFF_MASK in your code instead of
>>> defining you private IFI_CANFD_RXFIFO_ID_ID_?TD_MASK definitions.
>>>
>>> You won't have trapped into this problem then :-)
>>
>> These are register bitfield definitions, so should I really ?
>>
>> My OCD kicks in and tells me it'd be odd and inconsistent with the rest
>> of the bitfields, but if you prefer it that way, I'll just send an
>> updated patch.
>>
> 
> Your bit mask is masking the CAN ID out of a given variable.
> That's what CAN_SFF_MASK and CAN_EFF_MASK is made for.
> 
> So at least it should be:
> 
> #define IFI_CANFD_RXFIFO_ID_ID_STD_MASK		CAN_SFF_MASK
> #define IFI_CANFD_RXFIFO_ID_ID_XTD_MASK		CAN_EFF_MASK

This is good, I will do this. Thanks!

> Btw. These defines are _never_ referenced in ifi_canfd.c so they should be
> removed anyway.

The documentation for this core is not available, so if you don't mind,
I'd like to keep those.

-- 
Best regards,
Marek Vasut
