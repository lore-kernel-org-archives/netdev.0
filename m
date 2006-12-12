From: =?windows-1252?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: Fw: [Bugme-new] [Bug 7665] New: getsockopt(IPV6_*CAST_HOPS) returns -1
Date: Tue, 12 Dec 2006 23:38:24 +0100
Message-ID: <200612122338.24592@auguste.remlab.net>
References: <20061211095623.09fb0c40.akpm@osdl.org> <200612120908.19378@auguste.remlab.net> <457F1C2B.9000800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:38047 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932512AbWLLWim convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 17:38:42 -0500
To: Brian Haley <brian.haley@hp.com>
In-Reply-To: <457F1C2B.9000800@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 12 d=E9cembre 2006 22:16, vous avez =E9crit :
> > I don't reckon -1 could be the hop limit value.
>
> -1 means un-initialized.

Sure, -1 means "kernel default" for setsockopt(), but it is not=20
specified for getsockopt().

> The following patch seems to work for me, but this code has behaved
> this way for a while, so don't know if it will break any existing
> apps.

Google Codesearch for "getsockopt IPV6_MULTICAST_HOPS" yields a bunch o=
f=20
apps that seem to assume a valid hop limit is returned, none of which=20
detects -1. I believe applying your patch would fix much more apps than=
=20
it is going to break. Hopefully those not handling -1 will somehow cast=
=20
it to 255 if it is ever re-used, but I can also imagine some broken=20
SDP-or-similar with "/-1" or "/4294967295" as a hop limit.

Thanks,

--=20
R=E9mi Denis-Courmont
