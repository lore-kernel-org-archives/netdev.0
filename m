From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 11:51:31 +0200
Message-ID: <200911131151.31677.opurdila@ixiacom.com>
References: <200911130701.14847.opurdila@ixiacom.com> <4AFCF8D3.6090905@gmail.com> <20091112222608.79d90e9e@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:8178 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755804AbZKMJyc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 04:54:32 -0500
In-Reply-To: <20091112222608.79d90e9e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 13 November 2009 08:26:08 you wrote:
> On Fri, 13 Nov 2009 07:12:35 +0100
>=20
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Octavian Purdila a =E9crit :
> > > On Friday 13 November 2009 07:01:14 you wrote:
> > >> This patch speeds up the network device name allocation for the =
case
> > >> where a significant number of devices of the same type are creat=
ed
> > >> consecutively.
> > >>
> > >> Tests performed on a PPC750 @ 800Mhz machine with per device sys=
ctl
> > >> and sysfs entries disabled:
> > >>
> > >> Without the patch           With the patch
> > >>
> > >> real    0m 43.43s	    real    0m 0.49s
> > >> user    0m 0.00s	    user    0m 0.00s
> > >> sys     0m 43.43s	    sys     0m 0.48s
>=20
> No one has give a reasonable use case for this network device name
> explosion, what is the benchmark doing this nosense, and how do I
> get paid to do it...
>=20

=46or us the usecase is creating interfaces that get used by applicatio=
ns that=20
generate all sorts of traffic. This allows us to simulate realistic end=
 user=20
traffic (e.g. coming from a full blown stack). That sounds reasonable t=
o us :)

Also, I've seen other people reporting here to use more then 8000 inter=
faces.

> But I have to say no for another reason. You cause the kernel to choo=
se
> a different name for the case where a device is deleted or renamed.
> The old code would find and fill the hole when a new device was added=
=2E
>=20
> Since this is a semantic ABI change, the kind that drives users nuts.
>=20

The intent was to keep the old behavior. When the device is deleted we =
stop=20
fast allocation and we resume it only after we go through the old code =
once=20
again. Did I miss something?
