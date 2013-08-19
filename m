From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net] skge: dma_sync the whole receive buffer
Date: Mon, 19 Aug 2013 02:49:32 +0200
Message-ID: <52116B9C.8050003@gmail.com>
References: <20130810104100.0ae20aa6@nehalam.linuxnetplumber.net> <20130810.132935.1257046025460198490.davem@davemloft.net> <20130810150207.37432299@nehalam.linuxnetplumber.net> <20130813.150955.1471100759610399160.davem@davemloft.net> <20130813180036.3e639789@nehalam.linuxnetplumber.net> <520B59D3.4020103@gmail.com> <20130814092022.494caf2b@nehalam.linuxnetplumber.net> <520BCC72.8040002@gmail.com> <20130815084117.2f48fc58@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:43726 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755624Ab3HSAtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 20:49:36 -0400
Received: by mail-ee0-f44.google.com with SMTP id b47so1878022eek.31
        for <netdev@vger.kernel.org>; Sun, 18 Aug 2013 17:49:34 -0700 (PDT)
In-Reply-To: <20130815084117.2f48fc58@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.08.2013 17:41, Stephen Hemminger wrote:
> On Wed, 14 Aug 2013 20:29:06 +0200
> poma <pomidorabelisima@gmail.com> wrote:
>=20
>> On 14.08.2013 18:20, Stephen Hemminger wrote:
>>> On Wed, 14 Aug 2013 12:20:03 +0200
>>> poma <pomidorabelisima@gmail.com> wrote:
>>>
>>>> On 14.08.2013 03:00, Stephen Hemminger wrote:
>>>>> On Tue, 13 Aug 2013 15:09:55 -0700 (PDT)
>>>>> David Miller <davem@davemloft.net> wrote:
>>>>>
>>>>>> From: Stephen Hemminger <stephen@networkplumber.org>
>>>>>> Date: Sat, 10 Aug 2013 15:02:07 -0700
>>>>>>
>>>>>>> The DMA sync should sync the whole receive buffer, not just
>>>>>>> part of it. Fixes log messages dma_sync_check.
>>>>>>>
>>>>>>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>>>>>>
>>>>>> Applied, but I really suspect that your "check DMA mapping error=
s"
>>>>>> patch has added a serious regression.  A regression much worse t=
han
>>>>>> the bug you were trying to fix with that change.
>>>>>
>>>>> Argh. The problem is deeper than that. Device got broken somewher=
e between
>>>>> 3.2 and 3.4. My old Dlink card works on 3.2 but gets DMA errors o=
n 3.4.
>>>>> The config's are different though so checking that as well.
>>>>>
>>>>
>>>> Can I help you with debugging?
>>>> DGE-530T is rather solid device.
>>>
>>> Don't think it is a hardware problem.
>>> The failure is when the board access the Receive ring PCI memory ar=
ea.
>>> This region is allocated with pci_alloc_consistent and therefore sh=
ould
>>> be available. Two possible issues are driver math issues, or hardwa=
re
>>> problems with where the region is located. Some of these cards don'=
t
>>> really have full 64 bit PCI support.
>>>
>>> My board is:
>>> 05:01.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Ada=
pter (rev 11)
>>> 	Subsystem: D-Link System Inc DGE-530T Gigabit Ethernet Adapter
>>> 	Flags: bus master, 66MHz, medium devsel, latency 32, IRQ 18
>>> 	Memory at f7d20000 (32-bit, non-prefetchable) [size=3D16K]
>>> 	I/O ports at c000 [size=3D256]
>>> 	Expansion ROM at f7d00000 [disabled] [size=3D128K]
>>> 	Capabilities: [48] Power Management version 2
>>> 	Capabilities: [50] Vital Product Data
>>> 	Kernel driver in use: skge
>>>
>>>
>>> What is your config?
>>>
>>
>> 01:09.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Adap=
ter
>> (rev 11)
>> 	Subsystem: D-Link System Inc DGE-530T Gigabit Ethernet Adapter
>> 	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 19
>> 	Memory at fbffc000 (32-bit, non-prefetchable) [size=3D16K]
>> 	I/O ports at b400 [size=3D256]
>> 	[virtual] Expansion ROM at ec000000 [disabled] [size=3D128K]
>> 	Capabilities: [48] Power Management version 2
>> 	Capabilities: [50] Vital Product Data
>> 	Kernel driver in use: skge
>>
>>
>> poma
>>
>=20
> In the course of debugging this, I moved the card to another slot
> and all the problems went away. I suspect either card insertion or mo=
re likely
> the crap consumer motherboards don't have full PCI support on some sl=
ots.
>=20
> There doesn't seem to be anyway to address this in software.
>=20


DGE-530T is further tested in the 3 available slots:
01:06.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Adapter
(rev 11)
01:07.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Adapter
(rev 11)
01:08.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Adapter
(rev 11)
And the result is the same as in the slot:
01:09.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Adapter
(rev 11)
warnings, oopses and kernel crashes.

However DGE-528T(RTL8110s) on the same bus runs without errors:
01:09.0 Ethernet controller: D-Link System Inc DGE-528T Gigabit Etherne=
t
Adapter (rev 10)
	Subsystem: D-Link System Inc DGE-528T Gigabit Ethernet Adapter
	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 19
	I/O ports at cc00 [size=3D256]
	Memory at fbfff000 (32-bit, non-prefetchable) [size=3D256]
	[virtual] Expansion ROM at fbe00000 [disabled] [size=3D128K]
	Capabilities: [dc] Power Management version 2
	Kernel driver in use: r8169

Besides comparing the behavior of these two cards, e.g. NFS upload, I
noticed an obvious difference in the data flow.
Via DGE-528T transmission is steady, while via DGE-530T the traffic is
at times interrupted and unstable.
So it seems that the "WARNING: at lib/dma-debug.c:937 check_unmap=85"
isn't just a fun.


poma
