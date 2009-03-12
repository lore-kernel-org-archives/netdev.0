From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 12:23:39 +0200
Message-ID: <1295ed070903120323y21c9b3ddrf382ba765d060e65@mail.gmail.com>
References: <1236772642-12705-1-git-send-email-pktoss@gmail.com>
	 <200903121759.31024.rusty@rustcorp.com.au>
	 <1295ed070903120044s63b4da71i68add51703952d0f@mail.gmail.com>
	 <200903121946.24847.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:51398 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593AbZCLKXm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 06:23:42 -0400
Received: by ey-out-2122.google.com with SMTP id 25so93112eya.37
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 03:23:39 -0700 (PDT)
In-Reply-To: <200903121946.24847.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No, that's absolutely sane behavior, the previous was buggy. =A0If a =
network
> doesn't support carrier, you shouldn't look for it.
>
> Since they've fixed this in Network Manager, I'm not tempted to lie a=
bout it
> in the driver (though the distributions might choose to).
>
> Rusty.
>

Ok, if "lying" is reporting that the driver supports carrier
detection, this looks
like an innocent lie :). Because the carrier *is* on, this is the truth=
 and you
could just as well claim that the virtual hardware supports detection
as that it doesn't :)

(Plus there is no technical reason why virtio_net cannot report carrier=
 status,
the only argument against it is saving 2 lines of code)

IMHO, if someone has such an ancient card whose hardware cannot report
carrier status (even my ne2k isa can do this iirc) they would be traine=
d
to set the network up manually.

NetworkManager 's purpose is to automatically select the 'best' network
to connect to. By default it prefers wired networks from wireless.

If a wired eth card that does not report carrier status has no cable co=
nnected,
then (with the 'default ON' hack) NM will prefer that (useless) card ev=
en if
there is a possibility for a successful wireless connection.

That would upset me as a user and that is why I think this hack is wron=
g.
If the hardware cannot report carrier, then only the user can know whet=
her
this card should be preferred or not, it has to be explicit.

Anyway, that is as much arguing as I can afford for  a 2-liner :)
If you still don't like it, that 's fine with me, I doubt I 'll have
too much trouble
carrying it forward myself :)

Thanks a lot for taking the time to review :)

Pantelis

P.s., as an added bonus, ethtool eth0 shows a nice "Link detected: yes"
with this patch, instead of the scary "Operation not supported".
