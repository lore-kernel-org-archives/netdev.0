From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 8/8] Jhash in too big for inlining, move under lib/
Date: Sat, 23 Feb 2008 00:02:14 -0800
Message-ID: <20080223000214.81b1390a.akpm@linux-foundation.org>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1203515238-22848-5-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1203515238-22848-6-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1203515238-22848-7-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1203515238-22848-8-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1203515238-22848-9-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: =?ISO-8859-1?B?IklscG8gSuRydmluZW4i?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:44208 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757388AbYBWIDe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Feb 2008 03:03:34 -0500
In-Reply-To: <1203515238-22848-9-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008 15:47:18 +0200 "Ilpo J=E4rvinen" <ilpo.jarvinen@hel=
sinki.fi> wrote:

> vmlinux.o:
>  62 functions changed, 66 bytes added, 10935 bytes removed, diff: -10=
869
>=20
> ...+ these to lib/jhash.o:
>  jhash_3words: 112
>  jhash2: 276
>  jhash: 475
>=20
> select for networking code might need a more fine-grained approach.

It should be possible to use a modular jhash.ko.  The things which you
have identified as clients of the jhash library are usually loaded as m=
odules.

But in the case where someone does (say) NFSD=3Dy we do need jhash.o li=
nked into
vmlinux also.  This is doable in Kconfig but I always forget how.  Adri=
an, Sam
and Randy are the repositories of knowledge here ;)
