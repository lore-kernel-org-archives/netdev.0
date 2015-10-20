From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: removed USB_USBNET as a config option
Date: Tue, 20 Oct 2015 12:24:30 +0200
Message-ID: <1445336670.2246.11.camel@suse.com>
References: <1445257387-4278-1-git-send-email-oneukum@suse.com>
	 <87oafuu0ru.fsf@nemi.mork.no> <1445322539.2246.1.camel@suse.com>
	 <87k2qiszfv.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49569 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbbJTK0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2015 06:26:07 -0400
In-Reply-To: <87k2qiszfv.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-10-20 at 10:43 +0200, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oneukum@suse.com> writes:
> > On Mon, 2015-10-19 at 21:16 +0200, Bj=C3=B8rn Mork wrote:
> >
> >> This looks incomplete.
> >
> > Yes, it is against the earlier patch set which introduces the CDC
> > parser in cdc-acm and cdc-wdm. In hindsight I should have reversed
> > the order of patches.
>=20
> Ah, right, I see.
>=20
> But that patch has it's own set of problems, as pointed out by the te=
st
> robot:
>=20
> All the USBNET based minidrivers (as well as the USB_USBNET
> infrastructure itself) are protected by
>=20
> menuconfig USB_NET_DRIVERS
>         tristate "USB Network Adapters"
>         default USB if USB
>         depends on USB && NET
>=20
> if USB_NET_DRIVERS
> ..
>=20
>=20
> but USB_ACM and USB_WDM don't have similar protection.  So you'll hav=
e
> to make them select NET and USB_NET_DRIVERS too.

I really would like to avoid that.

> Selecting NET is going to be messy.  It already selects 3 other symbo=
ls,
> which you'll have to add as well.  And I have a feeling that the list=
 of
> NET dependencies might grow, which probably explains why there curren=
tly
> are no "select NET"'s in the kernel. So "select NET" is most likely o=
ut
> of the question.  And I don't think we want to make USB_ACM or USB_WD=
M
> depend on NET either.  It will not make sense to anyone attempting to
> select these drivers, resulting in infinite confusion.

Well, ACM is a tty driver which in theory makes sense without net,
so I think it would be wrong to demand networking support.

> So we might need to move cdc_parse_cdc_header() out of usbnet.c after
> all. Keeping it there creates an unnecessary "select" mess.  But I do=
n't
> know where to put it...  Either a common CDC helper module or the USB
> core I guess.

A common module means that the overhead of a module would be incurred.
Do you have any other candidates that could go into a common helper
module?

> Sorry for not bringing this up earlier. I know you asked specifically
> about this. I obviously didn't think it thoroughly through before.

Neither did I.

	Regards
		Oliver
