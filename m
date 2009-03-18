From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Wed, 18 Mar 2009 07:40:11 +0100
Message-ID: <20090318064010.GA13399@electric-eye.fr.zoreil.com>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <20090317220625.GA5038@electric-eye.fr.zoreil.com> <200903180256.26626.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Karsten Wiese <fzu@wemgehoertderstaat.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59758 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755694AbZCRGgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 02:36:46 -0400
Content-Disposition: inline
In-Reply-To: <200903180256.26626.fzu@wemgehoertderstaat.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten Wiese <fzu@wemgehoertderstaat.de> :
> Am Dienstag 17 M=E4rz 2009 schrieb Francois Romieu:
[...]
> > How the patch is supposed to work is not completely clear to me.
>=20
> Without it, if netif_rx_schedule_prep() returns 0, __netif_rx_schedul=
e() is not
> called so nothing is there to care for the transfer. Nonetheless intr=
_mask is=20
> changed so that its not possible that __netif_rx_schedule() is ever c=
alled
> later.
>=20
> Patch works by letting rtl8169_interrupt() again call netif_rx_schedu=
le_prep()
> until it succeeds and __netif_rx_schedule() is called.

Thanks for the explanation.

If netif_rx_schedule fails after napi is enabled, there is a
racing poll thread to care for the transfer.

Stated differently the bug is noticeable because napi_enable()=20
should be called before request_irq() in rtl8169_open, right ?

--=20
Ueimor
