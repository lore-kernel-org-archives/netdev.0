From: Timur Tabi <timur.tabi@gmail.com>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Tue, 20 Apr 2010 10:59:57 -0500
Message-ID: <q2yed82fe3e1004200859k742149cajead11323745ab768@mail.gmail.com>
References: <1271632401-2472-1-git-send-email-afleming@freescale.com>
	<m2ged82fe3e1004191408p53f19073x106ef56677c8a5df@mail.gmail.com>
	<DD217C72-156B-403D-B83B-EB365C782F2B@kernel.crashing.org>
	<o2oed82fe3e1004200801n98683cdalb2898c879b93f8fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Fleming <afleming@freescale.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:52546 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985Ab0DTQA2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 12:00:28 -0400
Received: by pwj9 with SMTP id 9so4349828pwj.19
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 09:00:28 -0700 (PDT)
In-Reply-To: <o2oed82fe3e1004200801n98683cdalb2898c879b93f8fd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 20, 2010 at 10:01 AM, Timur Tabi <timur.tabi@gmail.com> wro=
te:
> On Mon, Apr 19, 2010 at 11:43 PM, Kumar Gala <galak@kernel.crashing.o=
rg> wrote:
>
>> spin_event_timeout doesn't make sense for this. =A0The patch is fine=
=2E
>
> Can you please elaborate on that? =A0I don't understand why you think
> that. =A0spin_event_timeout() takes an expression and a timeout, and
> loops over the expression calling cpu_relax(), just like this loop
> does.

I haven't tested it, but I think this should work:

	spin_event_timeout((gfar_read(&regs->ievent) &
		(IEVENT_GRSC | IEVENT_GTSC)) =3D=3D
		(IEVENT_GRSC | IEVENT_GTSC), -1, 0);

Ideally, Andy should use a timeout value other than -1, and then test
the result like this:

	u32 ret;

	ret =3D spin_event_timeout((gfar_read(&regs->ievent) &
		(IEVENT_GRSC | IEVENT_GTSC)) =3D=3D
		(IEVENT_GRSC | IEVENT_GTSC), 1000, 0);

	if (!ret)
		/* timeout has occurred */

--=20
Timur Tabi
Linux kernel developer at Freescale
