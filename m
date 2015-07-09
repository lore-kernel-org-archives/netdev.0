From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: Fighting out-of-order reception with RPS?
Date: Thu, 09 Jul 2015 07:55:43 +0200
Message-ID: <559E0CDF.7080309@hartkopp.net>
References: <559D628C.5020100@hartkopp.net> <CALx6S35OJHyr6iwfdtYW6P-ke2pmsmQ9BjO-D=qjgCHxwF7oew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	sunil.kovvuri@gmail.com, jonathon.reinhart@gmail.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CALx6S35OJHyr6iwfdtYW6P-ke2pmsmQ9BjO-D=qjgCHxwF7oew@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 08.07.2015 23:17, Tom Herbert wrote:
> On Wed, Jul 8, 2015 at 10:49 AM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
(..)
>> When receiving CAN frames from a specific CAN network interface (e.g. can0)
>> the frames are sporadically out-of-order on SMP systems like my Core i7 laptop
>> with 4 CPUs. This out-of-order reception kills reliable communication e.g. for
>> CAN transport protocols.
>>
>> First approach was to set the smp_affinity for the USB adapter on irq 28 with:
(..)
>> Next idea was to use RPS after reading Documentation/networking/scaling.txt
(..)
>>
>> My two questions:
>>
>> 1. Is there any better solution to meet the described requirements?
>
> I would suggest that you look into how there are OOO packets in the
> first place. Even if the interrupts is allowed to happen on different
> CPUs by sm_affinity, NAPI execution should be serialized for the
> device so that OOO shouldn't happen. The result of your RPS setting
> should be all packets go to the same queue, this shouldn't normally
> affect the ordering. Looking at drivers/net/can there are apparently
> several variants of the driver. Do you know which one you're running?

I have two CAN hardware interfaces I can test together with a SMP system:

1. PCAN-USB using the driver at drivers/net/can/usb/peak_usb/
2. PCAN Compact PCIe using drivers/net/can/sja1000/(peak_pci.c / sja1000.c)

Both drivers do not use NAPI. The just follow the way

interrupt -> alloc_skb() -> fill skb -> netif_rx(skb)

I'm usually testing with the USB adapters as the PCIe setup is not very handy.

Best regards,
Oliver

>
>> 2. If not: How can enable this RPS solution by default for CAN interfaces?

