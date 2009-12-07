From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Mon, 7 Dec 2009 23:18:04 +0100
Message-ID: <20091207231804.23baebd2@houba>
References: <20091130213727.2f4047d2@houba>
	<alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
	<20091201211945.505d3c98@houba>
	<alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
	<20091202085925.472136e2@houba>
	<alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
	<20091202154403.GB30730@sd-11162.dedibox.fr>
	<alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
	<20091202183451.173db5f2@houba>
	<4B16BD58.3040802@tvk.rwth-aachen.de>
	<20091203085933.GD30730@sd-11162.dedibox.fr>
	<alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
	<4B17A791.80808@tvk.rwth-aachen.de>
	<alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi>
	<4B17C6C3.1060000@tvk.rwth-aachen.de>
	<20091203202328.62d7551a@houba>
	<4B1ADF79.6000101@tvk.rwth-aachen.de>
	<alpine.DEB.2.00.0912071532080.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:51071 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934433AbZLGWSX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 17:18:23 -0500
In-Reply-To: <alpine.DEB.2.00.0912071532080.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mon, 7 Dec 2009 16:01:53 +0200 (EET),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :

> On Sat, 5 Dec 2009, Damian Lukowski wrote:
>=20
> > Could you please make another test and unplug the cable or drop
> > [...]
> After taking some more look into this, this is partly a red herring.
> It looks like that because of the place of the printk that was still
> in the end of the function. You can see the full trace of what
> happens in .13., they come from independent incarnations of RTO
> recovery (when finally no error happens in tcp_retransmit_skb).

Doh ! Sorry :(=20

> However, the problem itself could occur. Here's the patch which
> should prevent that (I'm rather convinced that this really isn't
> stable worthy but net-next or net-2.6 would be fine):
>=20
> --
> [PATCH] tcp: fix retrans_stamp advancing in error cases
> [...]

Tonight, I made 2 more tests : .20 and .21 .=20

The first with latest damian patch from today.
Added the printk (This time I doubled checked ;).
Start the copy, wait 20s, disconnect cable 20s, reconnect.=20

The second try was identical, but I added your patch.
The copy was slower comparing to the first try.

I didn't took time to understand tcp retransmission timeout and read
the code. So, I'm not sure the printk is at the good place and usefull.

--=20
=46r=C3=A9d=C3=A9ric Leroy
