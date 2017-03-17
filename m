From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Fri, 17 Mar 2017 18:04:42 +0100
Message-ID: <7730cff6-6e85-c98d-0315-bd3888d3aeb1@grandegger.com>
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
 <006d9e14-47bf-1add-97c3-24098b43267f@grandegger.com>
 <69173747-cc2e-55f7-acad-4b5ba2a22863@timesys.com>
 <d5182e77-c243-1980-4cb6-39cd95075f4f@grandegger.com>
 <0362316b-ef76-1733-dbfc-8b644f758db9@timesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Akshay Bhat <akshay.bhat@timesys.com>,
        Akshay Bhat <nodeax@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailproxy01.manitu.net ([217.11.48.65]:48170 "EHLO
        mailproxy01.manitu.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdCQRRd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 13:17:33 -0400
In-Reply-To: <0362316b-ef76-1733-dbfc-8b644f758db9@timesys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Akshay,

Am 17.03.2017 um 17:00 schrieb Akshay Bhat:
> Hi Wolfgang,
>
> On 03/17/2017 03:39 AM, Wolfgang Grandegger wrote:
>> Hello Akshay,
>>
>> Am 16.03.2017 um 23:29 schrieb Akshay Bhat:
>>> Hi Wolfgang,
>>>
>>> On 03/16/2017 04:02 PM, Wolfgang Grandegger wrote:
>>>>
>>>> Looks much better now! There are message for state changes to error
>>>> warning and passive. Just the following message is not correct:
>>>>
>>>>  (000.200824)  can0  20000004   [8]  00 40 00 00 00 00 5F 19
>>>> ERRORFRAME
>>>>     controller-problem{}
>>>>     error-counter-tx-rx{{95}{25}}
>>>>
>>>> Sorry, forgot to mention... the function can_change_state() [1]
>>>> should be used for that purpose, if possible. It fixes the issue
>>>> above as well.
>>>>
>>>
>>> The updated driver (the one used to create the above log) is using
>>> can_change_state() function. data[1] 40 corresponds to
>>> CAN_ERR_CRTL_ACTIVE, so looks correct? Could it be that the can-utils I
>>> am using is old and not reporting state change?
>>
>> Hm, yes. The raw data looks correct. You could download and build a
>> recent version from "https://github.com/linux-can/can-utils" to check.
>> It could also be a bug.
>>
>
> Turned out to be a old version of can-utils. Using the above git tree
> reports the flag.
>
>  (000.200308)  can0  20000004   [8]  00 40 00 00 00 00 5F 00   ERRORFRAME
>         controller-problem{back-to-error-active}
>         error-counter-tx-rx{{95}{0}}
>
>>> Enabling BUSOFF/ERRP/ERRW bits in STATFE did not generate any interrupts
>>> on the INT pin. Should we make it a requirement that both INT and STAT
>>> pins need to be connected in hardware for the driver to do the error
>>> reporting?
>>
>> As I said, it's the better solution, especially if interrupt flooding
>> does harm. How does your system behave when bus errors come in due to no
>> cable connected?
>>
>
> I did not see any issues on the system with the cable disconnected. In
> my particular setup with the cable disconnected the system goes to
> tx-error-passive and does not get any further interrupts until a state
> change occurs.

Hm, that's unusual. Cable disconnected and then send a message:

$ grep /proc/interrupts; sleep 10; /proc/interrupts

should make things clear. But maybe it's a clever chip and it does stop 
sending error messages if the error counter does not change any more. 
After bus-off, the chip is quiet, of course. Should have a closer look 
to the CAN standard.

>> So far using NAPI was mandatory. There is the problem of out-of-order
>> message reception if handled in the isr on multi processor systems.
>> Marc, what is the current policy?
>>
>
> Since this is a SPI based CAN, I am wary for any additional latencies
> NAPI might introduce. The RX handling is being done at the very
> beginning of the ISR for this reason.
>
> Can we go ahead with the existing implementation and re-visit this at a
> later time?

Likely yes, as Marc has already reviewed the driver once.

BTW: what system board/processor are you using?

> Thanks again for all your help in reviewing/improving the driver :)

You are welcome!

Wolfgang.
