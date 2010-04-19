From: Timur Tabi <timur.tabi@gmail.com>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Mon, 19 Apr 2010 16:08:51 -0500
Message-ID: <m2ged82fe3e1004191408p53f19073x106ef56677c8a5df@mail.gmail.com>
References: <1271632401-2472-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:42610 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030Ab0DSVJW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 17:09:22 -0400
Received: by pwj9 with SMTP id 9so3769563pwj.19
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 14:09:21 -0700 (PDT)
In-Reply-To: <1271632401-2472-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 18, 2010 at 6:13 PM, Andy Fleming <afleming@freescale.com> =
wrote:

> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (!(gfar_read(&regs->ievent) &
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(IEVENT_GRSC | IEVEN=
T_GTSC)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while ((gfar_read(&regs->ievent) &
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(IEVENT_GRSC | IEVEN=
T_GTSC)) !=3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(IEVENT_GRSC | IEVEN=
T_GTSC))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cpu_relax();

How about using spin_event_timeout()?  It streamlines this process and
includes a timeout.

The U-Boot version of this code doesn't have a timeout either, but
spin_event_timeout() is not available in U-Boot.

--=20
Timur Tabi
Linux kernel developer at Freescale
