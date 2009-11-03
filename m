From: christian pellegrin <chripell@fsfe.org>
Subject: Re: [PATCH] can: Driver for the Microchip MCP251x SPI CAN controllers
Date: Tue, 3 Nov 2009 09:53:47 +0100
Message-ID: <cabda6420911030053r2dce5cd9wd416757e5f1b6574@mail.gmail.com>
References: <cabda6420911020729j3323ec33i59c7e94020acc469@mail.gmail.com>
	 <1257175840-28528-1-git-send-email-chripell@fsfe.org>
	 <4AEF37C1.9030706@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: socketcan-core@lists.berlios.de,
	spi-devel-general@lists.sourceforge.net, netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:44721 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbZKCIxn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 03:53:43 -0500
Received: by bwz27 with SMTP id 27so7291854bwz.21
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 00:53:47 -0800 (PST)
In-Reply-To: <4AEF37C1.9030706@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Nov 2, 2009 at 8:49 PM, Wolfgang Grandegger <wg@grandegger.com>=
 wrote:
> I assume this is v2 of the patch.
>

Yes I put the version in the subject. Will reply with v3 shortly

>> + =A0 =A0 buf[TXBDLC_OFF] =A0=3D (rtr << DLC_RTR_SHIFT) | frame->can=
_dlc;
>
> Two spaces before "=3D".
>

ack. This could be a good idea for a checkpatch.pl rule. Unfortunately
I don't know much about perlre. I used some emacs regexp so I hope
this is the last time you find double whitespaces or tabs around
assignment in this patch

>> + =A0 =A0 }
>
> Here the transceiver should be switched off!?
>

ack, all the error paths now seem checked now.

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_write_bits(spi, CA=
NINTF, intf, 0x00);
>
> Assigning variables within if or while expressions is not allowed. I
> wonder why checkpatch did not spot it.
>

ack. Out of curiosity I checked checkpatch.pl, unfortunately it looks
like it looks only for ifs:

if ($c =3D~ /\bif\s*\(.*[^<>!=3D]=3D[^=3D].*/s) {
	ERROR("do not use assignment in if condition\n" . $herecurr);
}

anyway I looked at this loop and tested: there is no need for it.

>> + =A0 =A0 net->flags =A0 =A0 =A0 =A0 =A0 =A0 =A0|=3D IFF_ECHO;
>
> Remove spaces, please.
>

ack, sorry

>> + =A0 =A0 if (ret >=3D 0) {
>
> if (!ret) ?
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&spi->dev, "probed\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> + =A0 =A0 }
>
> Shouldn't the power be switched off?
>

ack on the error patch

>
> We are close...
>

thank you for the patience


--=20
Christian Pellegrin, see http://www.evolware.org/chri/
"Real Programmers don't play tennis, or any other sport which requires
you to change clothes. Mountain climbing is OK, and Real Programmers
wear their climbing boots to work in case a mountain should suddenly
spring up in the middle of the computer room."
