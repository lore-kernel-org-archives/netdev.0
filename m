From: =?UTF-8?B?U3TDqXBoYW5lIEFOQ0VMT1Q=?= <sancelot@free.fr>
Subject: Re: Fwd: Re: RTL 8169  linux driver question
Date: Mon, 26 Nov 2012 08:35:26 +0100
Message-ID: <50B31BBE.2000509@free.fr>
References: <50AFC971.7010103@free.fr> <50AFCB1D.8080002@free.fr> <20121123192056.GA30290@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sancelot@numalliance.com,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:40028 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142Ab2KZHfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 02:35:41 -0500
In-Reply-To: <20121123192056.GA30290@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/11/2012 20:20, Francois Romieu wrote:
> St=C3=A9phane ANCELOT <sancelot@free.fr> :
> [...]
>> I have an adapted version of this driver for a realtime linux kernel
>> and a 8168/811B rev 2 component (as listed by lspci).
> You should grep for the XID line in the kernel dmesg to identify
> the chipset version.
XID 1c4000c0
>> I had problem with it, my application sends a frame that is
>> immediately transmitted back by some slaves, there was abnormally
>> 100us lost between the send and receive call.
>>
>> Finally I found it was coming from the following register setup in
>> the driver :
>>
>> RTL_W16(IntrMitigate, 0x5151);
>>
>> Can you give me some details about it, since I do not have the
>> RTL8169 programming guide.
> "Reserved" in my 2007 8168c rev1.0 datasheet.
>
> I merged it long ago from Realtek's driver. It has now changed to 0x5=
f51.
>
> On the old PCI 8169, bits 15..8 relate to Tx and 7..0 to Rx. Bits 7..=
4
> count in units of 125 us and bits 0..3 in packet units. You may give
> 0x..00 a try.
>
> Hayes knows better for the 8168 line.
>
>> /100us is important since this component acts as an Ethercat Master
>> running at 1ms./
> Which realtime kernel is it ?
xenomai.
