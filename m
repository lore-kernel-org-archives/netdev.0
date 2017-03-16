From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Thu, 16 Mar 2017 21:02:08 +0100
Message-ID: <006d9e14-47bf-1add-97c3-24098b43267f@grandegger.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <234d9e75-0083-b8b4-c781-add653fdb550@grandegger.com>
 <b3ebb569-b50c-39ad-dec5-0059fbfba8fb@timesys.com>
 <eb4e0f6f-14de-3369-0d50-7371ae74f4fb@grandegger.com>
 <3dbf8748-9d04-0f21-0e95-448d7a72e7d5@timesys.com>
 <41439729-42d0-d883-2801-2d3607f2aeab@grandegger.com>
 <CANiP4c8WMeT1Cr7WDXew1ne7DFR04oaA8Uch0zvyyOf5yCa37A@mail.gmail.com>
 <3dba0948-ffcb-8e80-fb32-62bb0aca6627@grandegger.com>
 <54d9a104-8ed1-4bb3-666e-042d3781dbfb@timesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Akshay Bhat <akshay.bhat@timesys.com>,
        Akshay Bhat <nodeax@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <54d9a104-8ed1-4bb3-666e-042d3781dbfb@timesys.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Akshay,

Am 16.03.2017 um 18:06 schrieb Akshay Bhat:
> Hi Wolfgang,
> 
> On 03/15/2017 05:42 AM, Wolfgang Grandegger wrote:
>> Hello Akshay,
>>
> ..snip..
>>>
>>> So here is my plan:
>>> - Have the bus error interrupt always enabled
>>> - If berr-reporting off, then have the isr checks/reports state changes
>>
>> Error state change messages should always be there. These are the
>> important one.
>>
>>> - if berr-reporting on, then have the isr checks/reports bus errors
>>> and state changes (Does it make sense packing the error message, if
>>> the ISR finds both bus and state changes?)
>>
>> If berr-reporting is off, simply do not create an error message for bus
>> errors, and only if the state changed. If it's "on" create an additional
>> bus error message.
>>
>> http://lxr.free-electrons.com/source/drivers/net/can/flexcan.c#L334
>>
>>
> 
> I have fixed the driver to handle the error reporting. Also thanks for
> your tip for generating bus-off by setting the host device at a
> different CAN bit rate! Below are logs with the updated driver. Let me
> know if you have any concerns, if not I will submit the v4 patch.
> 
> berr-reporting on case:
> http://pastebin.com/qDRLERmW

Looks much better now! There are message for state changes to error
warning and passive. Just the following message is not correct:

 (000.200824)  can0  20000004   [8]  00 40 00 00 00 00 5F 19   ERRORFRAME
    controller-problem{}
    error-counter-tx-rx{{95}{25}}

Sorry, forgot to mention... the function can_change_state() [1]
should be used for that purpose, if possible. It fixes the issue
above as well.

> berr-reporting off case:
> http://pastebin.com/fUn3j7qU

Ditto.

I just had another look to the manual and there is this undocumented
STATFE register at offset 0x1E. It's mentioned in some other parts of
the doc as interrupt enable register for STATF events. I would assume
the same bit layout than STATF. If you set bit 2 (BUSOFF), 3 (ERRP)
and 4 (ERRW), you may get interrupts. It's worth a try, I think. If
it works, it's the much better solution.

Wolfgang.

[1] http://lxr.free-electrons.com/ident?i=can_change_state

Wolfgang.
