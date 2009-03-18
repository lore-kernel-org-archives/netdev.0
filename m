From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Wed, 18 Mar 2009 02:56:26 +0100
Message-ID: <200903180256.26626.fzu@wemgehoertderstaat.de>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <20090317220625.GA5038@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout3.freenet.de ([195.4.92.93]:43180 "EHLO mout3.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284AbZCRCBs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 22:01:48 -0400
In-Reply-To: <20090317220625.GA5038@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag 17 M=E4rz 2009 schrieb Francois Romieu:
> Karsten Wiese <fzu@wemgehoertderstaat.de> :
> >=20
> > Only adjust the NAPI bits of the interruptmask, if netif_rx_schedul=
e_prep()
> > returns true.
> > Without this, I see interrupt storms here using 2.6.29-rcx and 2.6.=
27.19 and
> > device needed rmmod r8169 + modprobe r8169 to start working.
>=20
> How the patch is supposed to work is not completely clear to me.

Without it, if netif_rx_schedule_prep() returns 0, __netif_rx_schedule(=
) is not
called so nothing is there to care for the transfer. Nonetheless intr_m=
ask is=20
changed so that its not possible that __netif_rx_schedule() is ever cal=
led
later.

Patch works by letting rtl8169_interrupt() again call netif_rx_schedule=
_prep()
until it succeeds and __netif_rx_schedule() is called.

Thanks,
Karsten
