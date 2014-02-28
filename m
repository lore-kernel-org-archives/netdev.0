From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Fri, 28 Feb 2014 16:05:15 +0400
Message-ID: <53107B7B.8040800@cogentembedded.com>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>	<52DCE9E4.7010209@pengutronix.de>	<52E3148E.2010608@cogentembedded.com>	<52FCB6C5.6020001@pengutronix.de>	<53069445.80408@cogentembedded.com>	<5310521E.6000708@pengutronix.de>	<53107007.7050802@cogentembedded.com>	<531074F5.8090702@pengutronix.de> <CAMuHMdUuaX0pGmdOuJ9CJwj-ZTYo4PqTtZmYHh8swamQ754s2A@mail.gmail.com> <531077AC.7050804@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, linux-can@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Pavel Kiryukhin <vksavl@gmail.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <531077AC.7050804@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 28-02-2014 15:49, Marc Kleine-Budde wrote:

>>>>> A 32 bit read/modify/write is a standard operation, nothing special, no
>>>>> need to worry about byte swapping or anything like this.

>>>>     Oh, really? 8-)
>>>>     Don't you know that read[bwlq]() assume little-endian memory layout
>>>> and to read from big-endian 32-bit register one normally needs readl_be()?

>>> I assume you are on little endian ARM only (for now).

    That doesn't matter but yes.

>>> If you use a standard 32 bit read, then modify the correct bits in that
>>> 32 bit word and write it back, with the corresponding 32 bit write
>>> everything should be fine. For this usecase you just have yo figure out
>>> which 24 of the 32 bit are the one you have to change and which are the
>>> 8 that must not be modified.

    It seems you can't figure that out yourself. :-)

>>> Looking at the register layout:

>>>> +     u8 bcr[3];      /* Bit Configuration Register */
>>>> +     u8 clkr;        /* Clock Select Register */

>>> I think clkr would be the lowest 8 bit and bcr[] are the upper 24.

>> That would be the outcome on big endian ;-)

> Doh! Yes, correct.
> The point is, just read/modify the correct bits/write, should just work.

    That's what I do. But I completely fail to see the point of reading BCR 
which is completely overwritten. I would like to consider the pointless 
discussion about 32-bit read complete now.

> The driver has to be tested on BE ARM anyways, as this isn't the only 32
> bit reg.

    This is not a 32-bit register but 24- and 8-bit one. I'm afraid we won't 
be able to test on BE soon as the machine we're debugging on is LE only. 
Anyway, for the big-endian configured Superhyway bus the big-endian HPB bus 
the CAN controller resides on shouldn't swap bytes.

> Marc

WBR, Sergei

