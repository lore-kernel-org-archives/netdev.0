From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] flexcan: disable bus error interrupts for the i.MX28
Date: Tue, 09 Oct 2012 14:32:13 +0200
Message-ID: <5074194D.7060704@grandegger.com>
References: <5065A35B.3020702@grandegger.com> <20121007030858.GJ20231@S2101-09.ap.freescale.net> <50719647.4070404@grandegger.com> <7FE21149F4667147B645348EC60578850B2A361F@039-SN2MPN1-011.039d.mgd.msft.net> <507296F2.9010402@grandegger.com> <7FE21149F4667147B645348EC60578850B2A8D51@039-SN2MPN1-011.039d.mgd.msft.net> <50729D73.3050409@pengutronix.de> <7FE21149F4667147B645348EC60578850B36E998@039-SN2MPN1-011.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Shawn Guo <shawn.guo@linaro.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux-CAN <linux-can@vger.kernel.org>,
	Hui Wang <jason77.wang@gmail.com>
To: Dong Aisheng-B29396 <B29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <7FE21149F4667147B645348EC60578850B36E998@039-SN2MPN1-011.039d.mgd.msft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/09/2012 01:52 PM, Dong Aisheng-B29396 wrote:
> Hi Wolfgang,
> 
>> -----Original Message-----
>> From: Dong Aisheng-B29396
>> Sent: Monday, October 08, 2012 5:44 PM
>> To: 'Marc Kleine-Budde'
>> Cc: Wolfgang Grandegger; Shawn Guo; Linux Netdev List; Linux-CAN; Hui Wang
>> Subject: RE: [PATCH] flexcan: disable bus error interrupts for the i.MX28
>>
>>> -----Original Message-----
>>> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
>>> Sent: Monday, October 08, 2012 5:32 PM
>>> To: Dong Aisheng-B29396
>>> Cc: Wolfgang Grandegger; Shawn Guo; Linux Netdev List; Linux-CAN; Hui
>>> Wang
>>> Subject: Re: [PATCH] flexcan: disable bus error interrupts for the
>>> i.MX28
>>> Importance: High
>>>
>>> On 10/08/2012 11:13 AM, Dong Aisheng-B29396 wrote:
>>>>>> I just checked our ic guy of flexcan, it seems he also had no sense
>>>>>> of
>>>>> this issue.
>>>>>>
>>>>>> Below is some version info what I got:
>>>>>> Mx6s use FlexCAN3, with IP version 10.00.12.00
>>>>>> Mx53 use FlexCAN2 (with glitch filter), with IP version 03.00.00.00
>>>>>> Mx28 use FlexCAN2 (with glitch filter), with IP version 03.00.04.00
>>>>>> Mx35 use FlexCAN2 (without glitch filter) , with IP version
>>>>>> 03.00.00.00
>>>>>> Mx25 use FlexCAN2 (without glitch filter), with IP version
>>>>>> 03.00.00.00 I'm not sure if mx6q has such issue.
>>>>>
>>>>> OK, we need to find that out experimentally.
>>>>>
>>>> Our IC owner double checked the MX35 and MX53 IP and found the
>>>> RX_WARN & TX_WARN Interrupt source actually are not connected to ARM.
>>>
>>> Does this mean it's a SoC problem, not a problem of the ip core?
>>>
>> It's not a problem of ip core, it's about how to use the IP.
>> I do not know why some i.MX SoCs does not use rx/tx warn interrupts.
>>
>>>> That means flexcan will not trigger interrupt to ARM core even
>>>> RX_WARN or TX_WARN Happens.
>>>> This may be the root cause that why you cannot see RX_WARN interrupt
>>>> if not enable bus error interrupt on mx35.
>>>> He also checked that mx6q has the rx/tx warning interrupt connected
>>>> to
>>> arm.
>>>> So we guess mx6q does not have this issue.
>>>> Anyway, we can test to confirm.
>>>
>>> What about mx25?
>>>
>> For mx25 and mx28, he could not access it now.
>> Will check tomorrow.
>>
> Just let you know:
> The checking result is Mx28 has rx/tx warning interrupt line connected
> while mx25 not.
> Looks align with what we guess.

OK, then I'm going to remove FLEXCAN_HAS_BROKEN_ERR_STATE for the mx6q
as well in the next version of the patch.

Thanks for taking care.

Wolfgang

