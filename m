From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Mon, 20 Jan 2014 13:05:41 +0100
Message-ID: <CAMuHMdUYcGRRg_XWQKVJMqcUHBLGCRJvtqXH1Uvz0odgoYydOg@mail.gmail.com>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>
	<CAMuHMdWZJUvcW9OzM39aB2m+VdKqmZ6EOGR_rZcAdV7Cmwx3kg@mail.gmail.com>
	<52DD0CC1.70205@pengutronix.de>
	<CAMuHMdV5sMUnXb1Z1HeRk9+_dCGWrbD-DS62S7T4Be-77HvsvA@mail.gmail.com>
	<52DD0F72.1000005@pengutronix.de>
	<52DD1058.4090205@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, linux-can@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Pavel Kiryukhin <vksavl@gmail.com>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52DD1058.4090205@codethink.co.uk>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 20, 2014 at 1:02 PM, Ben Dooks <ben.dooks@codethink.co.uk> wrote:
> On 20/01/14 11:58, Marc Kleine-Budde wrote:
>>
>> On 01/20/2014 12:52 PM, Geert Uytterhoeven wrote:
>>>
>>> On Mon, Jan 20, 2014 at 12:47 PM, Marc Kleine-Budde <mkl@pengutronix.de>
>>> wrote:
>>>>
>>>> On 01/20/2014 12:43 PM, Geert Uytterhoeven wrote:
>>>>>
>>>>> On Thu, Dec 26, 2013 at 10:37 PM, Sergei Shtylyov
>>>>> <sergei.shtylyov@cogentembedded.com> wrote:
>>>>>>
>>>>>> Changes in version 3:
>>>>>
>>>>>
>>>>>> - added '__packed' to 'struct rcar_can_mbox_regs' and 'struct
>>>>>> rcar_can_regs';
>>>>>> - removed unneeded type cast in the probe() method.
>>>>>
>>>>>
>>>>>> +/* Mailbox registers structure */
>>>>>> +struct rcar_can_mbox_regs {
>>>>>> +       u32 id;         /* IDE and RTR bits, SID and EID */
>>>>>> +       u8 stub;        /* Not used */
>>>>>> +       u8 dlc;         /* Data Length Code - bits [0..3] */
>>>>>> +       u8 data[8];     /* Data Bytes */
>>>>>> +       u8 tsh;         /* Time Stamp Higher Byte */
>>>>>> +       u8 tsl;         /* Time Stamp Lower Byte */
>>>>>> +} __packed;
>>>>>
>>>>>
>>>>> Sorry, I missed the earlier discussion, but why the _packed?
>>>>> One u32 and 12 bytes makes a nice multiple of 4.
>>>>
>>>>
>>>> Better safe than sorry, it's the layout of the registers in hardware,
>>>> don't let the compiler optimize here.
>>>
>>>
>>> Actually __packed makes it less safe, as the compiler now assumes
>>> the u32 id member is unaligned, and thus may turn 32-bit accesses into 4
>>> byte accesses.
>>>
>>> Fortunately it won't happen in this case as the code uses writel/readl to
>>> acces the id member.
>>
>>
>> Yes, as this are registers they must not be accessed directly. However
>> we can use "__attribute__ ((packed, aligned(4)))" to tell the compiler
>> that the base address of this struct is always aligned to 4 bytes.
>
> I thought we'd gotten past the stage of ever writing register
> definitions as structures?

It allows to use e.g. "readl(&base->field)", which is used all over the place.

And sparse will inform you (read: the person who runs it) if you access
it directly.

Note that this driver does not use direct accesses.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
