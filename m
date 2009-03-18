From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Wed, 18 Mar 2009 23:36:29 +0100
Message-ID: <20090318223629.GA2306@electric-eye.fr.zoreil.com>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <200903180256.26626.fzu@wemgehoertderstaat.de> <20090318064010.GA13399@electric-eye.fr.zoreil.com> <200903181300.00591.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Karsten Wiese <fzu@wemgehoertderstaat.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:32827 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753553AbZCRWdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 18:33:19 -0400
Content-Disposition: inline
In-Reply-To: <200903181300.00591.fzu@wemgehoertderstaat.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten Wiese <fzu@wemgehoertderstaat.de> :
> Am Mittwoch 18 M=E4rz 2009 schrieb Francois Romieu:
[...]
> > If netif_rx_schedule fails after napi is enabled, there is a
> > racing poll thread to care for the transfer.
> >=20
> > Stated differently the bug is noticeable because napi_enable()=20
> > should be called before request_irq() in rtl8169_open, right ?
>=20
> Propably yes. That would mean the first interrupt is received before
> rtl_hw_start() is called in rtl8169_open. The source of that
> interrupt would be something else then?

All we need is thus a shared interrupt racing on a different CPU
with rtl8169_open and some IO versus memory reordering so that
the hardware is started and a change in the status register can
be seen in the IRQ handler before napi_enable/NAPI_STATE_SCHED
escapes from the CPU where rtl8169_open is running...

It does not look like a credible explanation. :o/

--=20
Ueimor
