From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Tue, 21 Jan 2014 01:12:12 +0300
Message-ID: <52DD9F3C.7000408@cogentembedded.com>
References: <52DD0CC1.70205@pengutronix.de>	<CAMuHMdV5sMUnXb1Z1HeRk9+_dCGWrbD-DS62S7T4Be-77HvsvA@mail.gmail.com>	<52DD0F72.1000005@pengutronix.de> <20140120.111614.394228612374217980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org,
	vksavl@gmail.com
To: David Miller <davem@davemloft.net>, mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:47079 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbaATVMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 16:12:15 -0500
Received: by mail-la0-f52.google.com with SMTP id c6so5817370lan.25
        for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 13:12:13 -0800 (PST)
In-Reply-To: <20140120.111614.394228612374217980.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/20/2014 10:16 PM, David Miller wrote:

>>>>>> - added '__packed' to 'struct rcar_can_mbox_regs' and 'struct rcar_can_regs';
>>>>>> - removed unneeded type cast in the probe() method.

>>>>>> +/* Mailbox registers structure */
>>>>>> +struct rcar_can_mbox_regs {
>>>>>> +       u32 id;         /* IDE and RTR bits, SID and EID */
>>>>>> +       u8 stub;        /* Not used */
>>>>>> +       u8 dlc;         /* Data Length Code - bits [0..3] */
>>>>>> +       u8 data[8];     /* Data Bytes */
>>>>>> +       u8 tsh;         /* Time Stamp Higher Byte */
>>>>>> +       u8 tsl;         /* Time Stamp Lower Byte */
>>>>>> +} __packed;

>>>>> Sorry, I missed the earlier discussion, but why the _packed?
>>>>> One u32 and 12 bytes makes a nice multiple of 4.

>>>> Better safe than sorry, it's the layout of the registers in hardware,
>>>> don't let the compiler optimize here.

>>> Actually __packed makes it less safe, as the compiler now assumes
>>> the u32 id member is unaligned, and thus may turn 32-bit accesses into 4
>>> byte accesses.

>>> Fortunately it won't happen in this case as the code uses writel/readl to
>>> acces the id member.

>> Yes, as this are registers they must not be accessed directly. However
>> we can use "__attribute__ ((packed, aligned(4)))" to tell the compiler
>> that the base address of this struct is always aligned to 4 bytes.

> I truly think using packed here is rediculous, please remove it unless
> you can prove that things won't work without it.

    They will. But how about the following 'struct rcar_can_regs'?

> Thanks.

WBR, Sergei
