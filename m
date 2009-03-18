From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Wed, 18 Mar 2009 12:59:59 +0100
Message-ID: <200903181300.00591.fzu@wemgehoertderstaat.de>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <200903180256.26626.fzu@wemgehoertderstaat.de> <20090318064010.GA13399@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout2.freenet.de ([195.4.92.92]:39209 "EHLO mout2.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754140AbZCRMAH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 08:00:07 -0400
In-Reply-To: <20090318064010.GA13399@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch 18 M=E4rz 2009 schrieb Francois Romieu:
> Karsten Wiese <fzu@wemgehoertderstaat.de> :
> > Am Dienstag 17 M=E4rz 2009 schrieb Francois Romieu:
> [...]
> > > How the patch is supposed to work is not completely clear to me.
> >=20
> > Without it, if netif_rx_schedule_prep() returns 0, __netif_rx_sched=
ule() is not
> > called so nothing is there to care for the transfer. Nonetheless in=
tr_mask is=20
> > changed so that its not possible that __netif_rx_schedule() is ever=
 called
> > later.
> >=20
> > Patch works by letting rtl8169_interrupt() again call netif_rx_sche=
dule_prep()
> > until it succeeds and __netif_rx_schedule() is called.
>=20
> Thanks for the explanation.
>=20
> If netif_rx_schedule fails after napi is enabled, there is a
> racing poll thread to care for the transfer.
>=20
> Stated differently the bug is noticeable because napi_enable()=20
> should be called before request_irq() in rtl8169_open, right ?

Propably yes. That would mean the first interrupt is received before
rtl_hw_start() is called in rtl8169_open. The source of that
interrupt would be something else then?

Thanks,
Karsten
