From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fwd: Re: RTL 8169  linux driver question
Date: Fri, 23 Nov 2012 20:20:56 +0100
Message-ID: <20121123192056.GA30290@electric-eye.fr.zoreil.com>
References: <50AFC971.7010103@free.fr> <50AFCB1D.8080002@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sancelot@numalliance.com,
	Hayes Wang <hayeswang@realtek.com>
To: =?utf-8?B?U3TDqXBoYW5l?= ANCELOT <sancelot@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44703 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab2KWToz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 14:44:55 -0500
Content-Disposition: inline
In-Reply-To: <50AFCB1D.8080002@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

St=C3=A9phane ANCELOT <sancelot@free.fr> :
[...]
> I have an adapted version of this driver for a realtime linux kernel
> and a 8168/811B rev 2 component (as listed by lspci).

You should grep for the XID line in the kernel dmesg to identify
the chipset version.

> I had problem with it, my application sends a frame that is
> immediately transmitted back by some slaves, there was abnormally
> 100us lost between the send and receive call.
>=20
> Finally I found it was coming from the following register setup in
> the driver :
>=20
> RTL_W16(IntrMitigate, 0x5151);
>=20
> Can you give me some details about it, since I do not have the
> RTL8169 programming guide.

"Reserved" in my 2007 8168c rev1.0 datasheet.

I merged it long ago from Realtek's driver. It has now changed to 0x5f5=
1.

On the old PCI 8169, bits 15..8 relate to Tx and 7..0 to Rx. Bits 7..4
count in units of 125 us and bits 0..3 in packet units. You may give
0x..00 a try.

Hayes knows better for the 8168 line.

> /100us is important since this component acts as an Ethercat Master
> running at 1ms./

Which realtime kernel is it ?

--=20
Ueimor
