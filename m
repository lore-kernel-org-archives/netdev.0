From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Fri, 20 Oct 2017 17:44:41 +0530
Message-ID: <6b0d7939-349d-2acf-fc6d-d018383167d5@ti.com>
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
 <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
 <ed19ead3-d8f6-c027-74cf-8aee131c8a59@ti.com>
 <08432016-e733-b827-b9aa-bc359dd837f5@pengutronix.de>
 <7ba515d9-7710-c152-a55a-f995b7f3d49a@ti.com>
 <848e965d-e6a1-8930-9064-0317563326c0@ti.com>
 <93c6d531-c38b-6f88-510f-59eb3e733b78@ti.com>
 <545ac690-10c8-b206-76dd-dbbe602eb6af@pengutronix.de>
 <4c5b5e9f-44dc-0bf5-5131-b3caf54f390e@ti.com>
 <da663b5a-5459-2e99-79a2-3fdc3daef70b@pengutronix.de>
 <74482aa8-7b65-bd3d-7160-0d515b8c7b27@ti.com>
 <48317843-b488-8ccb-c6c5-e8cbb90ff5e3@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Wenyou Yang <wenyou.yang@atmel.com>,
        Dong Aisheng <b29396@freescale.com>,
        "Quadros, Roger" <rogerq@ti.com>,
        Oliver Hartkopp <socketcan@hartkopp.net>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
        Franklin S Cooper Jr <fcooper@ti.com>,
        =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
        "Yang, Wenyou" <Wenyou.Yang@Microchip.com>, <wg@grandegger.com>,
        <socketcan@hartkopp.net>, <quentin.schulz@free-electrons.com>,
        <edumazet@google.com>, <linux-can@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <48317843-b488-8ccb-c6c5-e8cbb90ff5e3@pengutronix.de>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 19 October 2017 08:25 PM, Marc Kleine-Budde wrote:
> On 10/19/2017 03:54 PM, Franklin S Cooper Jr wrote:
>> On 10/19/2017 06:32 AM, Marc Kleine-Budde wrote:
>>> On 10/19/2017 01:09 PM, Sekhar Nori wrote:
>>>> On Thursday 19 October 2017 02:43 PM, Marc Kleine-Budde wrote:
>>>>> On 10/19/2017 07:07 AM, Sekhar Nori wrote:
>>>>>>>>> Sounds reasonable. What's the status of this series?
>>>>>>>>
>>>>>>>> I have had some offline discussions with Franklin on this, and I am not
>>>>>>>> fully convinced that DT is the way to go here (although I don't have the
>>>>>>>> agreement with Franklin there).
>>>>>>>
>>>>>>> Probably the fundamental area where we disagree is what "default" SSP
>>>>>>> value should be used. Based on a short (< 1 ft) point to point test
>>>>>>> using a SSP of 50% worked fine. However, I'm not convinced that this
>>>>>>> default value of 50% will work in a more "traditional" CAN bus at higher
>>>>>>> speeds. Nor am I convinced that a SSP of 50% will work on every MCAN
>>>>>>> board in even the simplest test cases.
>>>>>>>
>>>>>>> I believe that this default SSP should be a DT property that allows any
>>>>>>> board to determine what default value works best in general.
>>>>>>
>>>>>> With that, I think, we are taking DT from describing board/hardware
>>>>>> characteristics to providing default values that software should use.
>>>>>
>>>>> If the default value is board specific and cannot be calculated in
>>>>> general or from other values present in the DT, then it's from my point
>>>>> of view describing the hardware.
>>>>>
>>>>>> In any case, if Marc and/or Wolfgang are okay with it, binding
>>>>>> documentation for such a property should be sent to DT maintainers for
>>>>>> review.
>>>>>>
>>>>>>>>
>>>>>>>> There are two components in configuring the secondary sample point. It
>>>>>>>> is the transceiver loopback delay and an offset (example half of the bit
>>>>>>>> time in data phase).
>>>>>>>>
>>>>>>>> While the transceiver loopback delay is pretty board dependent (and thus
>>>>>>>> amenable to DT encoding), I am not quite sure the offset can be
>>>>>>>> configured in DT because its not really board dependent.
>>>>>>>>
>>>>>>>> Unfortunately, offset calculation does not seem to be an exact science.
>>>>>>>> There are recommendations ranging from using 50% of bit time to making
>>>>>>>> it same as the sample point configured. This means users who need to
>>>>>>>> change the SSP due to offset variations need to change  their DT even
>>>>>>>> without anything changing on their board.
>>>>>>>>
>>>>>>>> Since we have a netlink socket interface to configure sample point, I
>>>>>>>> wonder if that should be extended to configure SSP too (or at least the
>>>>>>>> offset part of SSP)?
>>>>>>>
>>>>>>> Sekhar is right that ideally the user should be able to set the SSP at
>>>>>>> runtime. However, my issue is that based on my experience CAN users
>>>>>>> expect the driver to just work the majority of times. For unique use
>>>>>>> cases where the driver calculated values don't work then the user should
>>>>>>> be able to override it. This should only be done for a very small
>>>>>>> percentage of CAN users. Unless you allow DT to provide a default SSP
>>>>>>> many users of MCAN may find that the default SSP doesn't work and must
>>>>>>> always use runtime overrides to get anything to work. I don't think that
>>>>>>> is a good user experience which is why I don't like the idea.
>>>>>>
>>>>>> Fair enough. But not quite sure if CAN users expect CAN-FD to "just
>>>>>> work" without doing any bittiming related setup.
>>>>>
>>>>> From my point of view I'd rather buy a board from a HW vendor where
>>>>> CAN-FD works, rather than a board where I have to tweak the bit-timing
>>>>> for a simple CAN-FD test setup.
>>>>>
>>>>> As far as I see for the m_can driver it's a single tuple: "bitrate > 2.5
>>>>> MBit/s -> 50%". Do we need an array of tuples in general?
>>
>> Internally what I proposed was a binding that allowed you to pass in an
>> array of a range of baud rates and then a SSP for that baud rate range.
>> Therefore, if the baud rate being used impacted what SSP worked then it
>> allows someone to provide a range of defaults. Of course a person also
>> has the ability to use a single large range thus implementing a single
>> default SSP value.
> 
> A single tuple is just a special case of a list of tuples :)
> 
> I was thinking of something like this:
> 
> First we need a struct defining the bitrate spp relationship.

I dont know if there is such a relation between bitrate and SSP. We do
know that some papers[1] suggest that below 2.5MBits/sec TDC (and hence
SSP) feature is not required. And we also know that hardly anyone has
tested CAN-FD above 5MBits/sec.

Between these two values, we do not have enough data today to suggest
that SSP (as a percentage of bittiming) needs to move as bitrate varies.

> The driver provides default values by a sorted array of these structs
> together with array length.
> 
> During device registration we assign these default values to the actual
> driver instance.
> 
> The netlink code can read and overwrite the current values. Maybe it can
> read the default values.
> 
> The bitrate calculation code calculates the to be used spp value.
> 
> The driver sets the value during the open callback.
> 
>>> Do we need more than one tuple here?
>>>
>>>>> If good default values are transceiver and board specific, they can go
>>>>> into the DT. We need a generic (this means driver agnostic) binding for
>>>>> this. If this table needs to be tweaked for special purpose, then we can
>>>>> add a netlink interface for this as well.
>>>>>
>>>>> Comments?
>>>>
>>>> I dont know how a good default (other than 50% as the starting point)
>>>> can be arrived at without doing any actual measurements on the actual
>>>> network. Since we do know that the value has to be tweaked, agree that
>>>> netlink interface has to be provided.
>>
>> Now I have seen in non public documentations that setting SP to SSP also
>> works.
> 
> This can already by done now, without the need for new interfaces.

If I read correctly, this is what Oliver Hartkopp is saying too.

>> This makes a bit more sense to me and I'm alot more comfortable going
>> with this. However, since its based on non public information I can't
>> justify it beyond that "it works for me". But I'm alot more 
>> comfortable going with then saying "hey this default value works for 
>> TI's dra76 evm. Therefore, every MCAN board will be stuck by default
>> for a value that works for us". So if there is no push back with
>> going with SSP = db SP with no documentation to back up why that is
>> being used then I will try that out and send patches.
> 
> This means we postpone the whole add-new-interface-dance until the
> SPP=SP approach doesn't work for some usecase?

I think thats prudent as any new interface (DT or userspace) needs to be
maintained forever. Over time we should have more data from actual
deployments to see if a new interface is really necessary.

Thanks,
Sekhar

[1]
http://www.bosch-semiconductors.de/media/automotive_electronics/pdf_2/ipmodules_3/can_fd_1/icc14_2013_paper_Hartwich.pdf
(last page)
