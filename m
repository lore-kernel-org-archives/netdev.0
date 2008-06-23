From: =?ISO-8859-1?Q?S=E9guier_R=E9gis?= <rseguier@e-teleport.net>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
 MTU change
Date: Mon, 23 Jun 2008 19:04:45 +0200
Message-ID: <485FD7AD.5080302@e-teleport.net>
References: <20080604215909.GA17446@electric-eye.fr.zoreil.com> <20080614212341.GA12976@electric-eye.fr.zoreil.com> <4856DA62.7080803@e-teleport.net> <20080617214538.GA6388@electric-eye.fr.zoreil.com> <48584AA4.8040801@e-teleport.net> <48593E35.1010409@e-teleport.net> <20080618201012.GA4019@electric-eye.fr.zoreil.com> <48598784.40306@e-teleport.net> <20080619204312.GA2160@electric-eye.fr.zoreil.com> <485B8542.7060204@e-teleport.net> <20080620103910.GA21227@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@infradead.org>, alan@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.e-teleport.net ([213.190.83.68]:51934 "EHLO
	mail.imsnet.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227AbYFWREt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 13:04:49 -0400
In-Reply-To: <20080620103910.GA21227@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancois Romieu a =E9crit :
> S=E9guier R=E9gis <rseguier@e-teleport.net> :
> [...]
>  =20
>> But if I generate a paquet with a size more than around 3825, the dr=
iver=20
>> don't send it and no paquet is send after, work again after an inter=
face=20
>> down/up and until no paquet > 3825.
>>    =20
>
> Does it qualify as a regression ?
>
>  =20
No,

I test with the version of the driver before patches and I have the sam=
e=20
error.

I think error is in TX. (TX and RX equipments for the test have the sam=
e=20
chip, I don't have other kind of chip available at the moment, that why=
=20
I not sure)

If theses informations help :

When I transmit a paquet of ~ 4000 (for a mtu 4500),

When I reboot and PCIE-AER is compiled, I got this message :

Jun 23 18:28:31 apollo kernel: +------ PCI-Express Device Error ------+
Jun 23 18:28:31 apollo kernel: Error Severity^I^I: Uncorrected (Non-Fat=
al)
Jun 23 18:28:31 apollo kernel: PCIE Bus Error type^I: Transaction Layer
Jun 23 18:28:31 apollo kernel: Unsupported Request   ^I: Multiple
Jun 23 18:28:31 apollo kernel: Requester ID^I^I: 0300
Jun 23 18:28:31 apollo kernel: VendorID=3D1106h, DeviceID=3D3119h, Bus=3D=
03h,=20
Device=3D00h, Function=3D00h
Jun 23 18:28:31 apollo kernel: TLB Header:
Jun 23 18:28:31 apollo kernel: 40000001 0018000c febffc7c 0000fdff
Jun 23 18:28:31 apollo kernel: Broadcast error_detected message
Jun 23 18:28:31 apollo kernel: Broadcast mmio_enabled message
Jun 23 18:28:31 apollo kernel: Broadcast resume message

When I reboot and "PCIE-AER and MSI" is compiled, I got this message :

Jun 23 18:35:59 apollo kernel: irq 163, desc: c0495dc8, depth: 1, count=
:=20
0, unhandled: 0
Jun 23 18:35:59 apollo kernel: ->handle_irq():  c012d997,=20
handle_bad_irq+0x0/0x199
Jun 23 18:35:59 apollo kernel: ->chip(): c0496b20, 0xc0496b20
Jun 23 18:35:59 apollo kernel: ->action(): 00000000
Jun 23 18:35:59 apollo kernel:   IRQ_DISABLED set
Jun 23 18:35:59 apollo kernel: unexpected IRQ trap at vector a3
--=20
R=E9gis
