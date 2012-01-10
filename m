From: Wolfgang Zarre <info@essax.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Tue, 10 Jan 2012 13:43:38 +0100
Message-ID: <4F0C327A.306@essax.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF31@saturn3.aculab.com> <4F0B608D.6090309@essax.com> <4F0C23F0.10602@proconX.com> <4F0C282A.5020505@grandegger.com>
Reply-To: info@essax.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Henrik Maier <henrik@proconX.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4F0C282A.5020505@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello guys,

> Hi Henrik,
>
> On 01/10/2012 12:41 PM, Henrik Maier wrote:
>> Hello guys,
>>
>> see comments below.
>>
>> On 9/01/2012 10:47 PM, Wolfgang Zarre wrote:
>>> Further I have also investigated a bit the issue regarding the "HM"
>>> patches.
>>>
>>> I checked out the can4linux and I could find this patch in file
>>> can_i82527funcs.c as mentioned by Oliver.
>>> @Oliver: BTW thanks for Your investigation.
>>>
>>> After studying the Makefile and some tests I discovered that
>>> this file is just used for the target SBS_PC7 but funny enough not
>>> for GENERIC_I82527.
>>>
>>> I was seeking the declaration of CANout used in can_i82527funcs.c
>>> to see if it's based on the same code we had and as well as in Lincan
>>> but unfortunately the target SBS_PC7 doesn't compile with kernel
>>> 2.6.39-4 and moreover I got the message:
>>> ...can4linux/trunk/can4linux/i82527funcs.c:72:
>>>                        error: implicit declaration of function 'CANout'
>>>
>>> And additional not knowing if the board of SBS_PC7 is ISA or PCI based
>>> I tried to find out and found after some research the following
>>> thread:
>>> http://old.nabble.com/-PATCH-v2--cc770-isa%3A-legacy-driver-for-CC770-i82725-on-the-ISA-bus-td24216347.html
>>>
>>>
>>> According to that I assumed it's ISA based and is working with cc770_isa.
>>>
>>> But not finding the declaration of CANout used in can_i82527funcs.c I
>>> assumed further that it was done without spinlock which might cause
>>> the effect of repeated or even lost interrupts as well depending on
>>> the hardware configuration.
>>>
>>> If this is the case then the HM patches would be obsolete and maybe
>>> someone owning a SBS PC7 can test without these patches.
>>>
>>> @Henrik: I would like to ask You if You can confirm this when You are
>>> back.
>>> Thanks a lot.
>>>
>>>
>>> Wolfgang
>>
>> The can4linux port I made was done for a specific project and a specific
>> hardware, the SBS PC7, and only ever tested on that hardware. The i82527
>> code was already in the can4linux 3.x archive but not maintained for a
>> while and has become non-functional over time.
>>
>> Initially we used the 2.4 Linux kernel and the can4linux version 3.1 as
>> basis for the re-integration of the i82527. I called our modified
>> version  "3.1i" (i for Intel). This is from the changelog:
>>
>> 3.1i - Integration of the i82527 code into can4linux version 3.1,
>>        major refactoring and clean-up of the i82527 code, fixed
>>        interrupt lock-up issue w/ sending while receiving in heavy load,
>>        fixed issue w/ stopping and re-starting the bus, added
>>        new acceptance mask function to bring code in line with SJA1000 code
>>        base, new I/O model to support the SJA1000 CANin/CANout macros,
>>        support added to the makefile for generic i82527 cards and
>>        SBS PC7compact DINrail mounted industry PC
>>        by Henrik Maier of FOCUS Software Engineering Pty Ltd
>> <www.focus-sw.com>
>>
>> As time passed the requirement for kernel 2.6 support emerged and we did
>> the same based on can4linux 3.3.2 and called it "3.3.2i" which later was
>> merged into the official can4linux archive and became 3.3.3.
>>
>> The "repeated TX IRQ" issue came up only with kernel 2.6 and was not
>> required in the 2.4 version. The way I fixed it may not have been the
>> best, but it solved the immediate need of finishing a project and
>> getting the driver stable. I am not a kernel driver expert.
>
> OK, then most likely it's not a hardware issue.
>
>> The PC7 hardware is now obsolete anyway. From my point we can do a
>> "clean" start and remove the old baggage.
>>
>> The PC7 CAN interface is ISA based and I don't have a hardware any more
>> to test.
>>
>> Some background info and our "i" versions are published here:
>>
>> http://www.focus-sw.com/can/can4linux.html
>>
>> I hope that helps a bit. It has been a few years since I worked with
>> can4linux but it is great to see that the community is further enhancing
>> CAN support for Linux.
>
> Yes, of course. Thanks for digging that out. As you suggest, we will
> remove that code and wait what happens.
>

Ok, I'll prepare this patch separately as said.

> Wolfgang.
>

Wolfgang
