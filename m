From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH V2] CAN: Add Flexcan CAN controller driver
Date: Tue, 28 Jul 2009 21:41:30 +0200
Message-ID: <4A6F546A.4000008@grandegger.com>
References: <20090728120624.GS2714@pengutronix.de>	<4A6EFB64.8070804@hartkopp.net>	<20090728133719.GU2714@pengutronix.de>	<4A6F0238.6050605@hartkopp.net> <4A6F073A.1050909@hartkopp.net>	<20090728142452.GW2714@pengutronix.de>	<4A6F0FC2.1060605@hartkopp.net> <20090728145354.GX2714@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:60573 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbZG1Tlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 15:41:35 -0400
In-Reply-To: <20090728145354.GX2714@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
> On Tue, Jul 28, 2009 at 04:48:34PM +0200, Oliver Hartkopp wrote:
>> Sascha Hauer wrote:
>>> On Tue, Jul 28, 2009 at 04:12:10PM +0200, Oliver Hartkopp wrote:
>>>> Oliver Hartkopp wrote:
>>>>> Sascha Hauer wrote:
>>>>>>>> +
>>>>>>>> +	if (frame->can_id & CAN_RTR_FLAG)
>>>>>>>> +		dlc |= MB_CNT_RTR;
>>>>>>>> +
>>>>>>>> +	writel(dlc, &regs->cantxfg[TX_BUF_ID].can_dlc);
>>>>>>>> +	writel(can_id, &regs->cantxfg[TX_BUF_ID].can_id);
>>>> Are you sure, that this is correct?
>>> Yes, I am sure, at least on my hardware.
>> I looked into the writel() macro which does a cpu_to_le32() to the value -
>> sorry that i did not check this before ...
>>
>>>> Indeed i wonder, if it would make sense to skip the entire struct flexcan_mb
>>>> approach and fiddle byte-by-byte inside the registers ...
>>> You'll have to to 32 bit accesses to get it right on little and big
>>> endian.
>>>
>>> what we can do is:
>>>
>>> writel(can_data[0] << 24 | can_data[1] << 16 | can_data[2] << 8 | can_data[3],
>>> 	msg_buf + 0x8);
>> This looks easier to understand and makes things clear, when you look into the
>> specification.
> 
> Ok, I'll change it like this.

OK, even if I do not really share Oliver's concerns. The second write
could be suppressed if dlc <= 4.

Wolfgang.
