From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Thu, 12 Nov 2015 17:20:29 +0000
Message-ID: <yw1xziyjkuci.fsf@unicorn.mansr.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<564241BF.4020700@free.fr> <yw1xbnb1r70r.fsf@unicorn.mansr.com>
	<5644953C.8000800@free.fr> <yw1xfv0bmhz3.fsf@unicorn.mansr.com>
	<5644BC1B.1000109@free.fr> <yw1x4mgrm9ys.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <festevam@gmail.com>
To: Mason <slash.tmp@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1x4mgrm9ys.fsf@unicorn.mansr.com> (=?iso-8859-1?Q?=22M=E5n?=
 =?iso-8859-1?Q?s_Rullg=E5rd=22's?= message
	of "Thu, 12 Nov 2015 16:57:47 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

M=E5ns Rullg=E5rd <mans@mansr.com> writes:

> Mason <slash.tmp@free.fr> writes:
>
>> [ CCing a few knowledgeable people ]
>>
>> Despite the subject, this is about an Atheros 8035 PHY :-)
>>
>> On 12/11/2015 15:04, M=E5ns Rullg=E5rd wrote:
>>
>>> Mason wrote:
>>>=20
>>>> BTW, you're not using the PHY IRQ, right? I think I remember you s=
aying
>>>> it didn't work reliably?
>>>=20
>>> It doesn't seem to be wired up on any of my boards, or there's some
>>> magic required to activate it that I'm unaware of.
>>
>> Weird. The board schematics for the 1172 show Tango ETH0_MDINT# pin
>> properly connected to AR8035 INT pin (pin 20).
>
> I have a different board.
>
>> <Thinking out loud>
>>
>> http://www.redeszone.net/app/uploads/2014/04/AR8035.pdf
>>
>> INT pin 20
>> I/O, D, PD
>> Interrupt Signal to System; default OD-gate, needs an external
>> 10Kohm pull-up, active low; can be configured to I/O by register,
>> active high.
>>
>> 4.1.17 Interrupt Enable
>> Offset: 0x12
>> Mode: Read/Write
>> Hardware Reset: 0
>>
>> Strange... it looks like AT803X_INER and AT803X_INTR_ENABLE refer to
>> the same "Interrupt Enable" register?
>
> Seems like someone missed that it was already defined.
>
>> In fact, AT803X_INER_INIT =3D=3D 0xec00 makes sense for register 0x1=
2:
>> link success/fail, speed/duplex changed, autoneg error
>>
>> Looks like at803x_config_intr() is used for 8031, but not for 8035..=
=2E
>>
>> Relevant commit:
>> 77a9939426f7a "phy/at8031: enable at8031 to work on interrupt mode"
>>
>> If I add .config_intr and .ack_interrupt to the 8035 struct, then I =
get
>> (also added some traces)
>
> I tried that just now, and I get nothing.  What interrupt did you
> specify in your device tree?

It works with the interrupt set to trigger on rising edge.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
