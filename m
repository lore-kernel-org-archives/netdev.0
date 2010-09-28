From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix IPv6 PMTU disc. w/ asymmetric routes
Date: Tue, 28 Sep 2010 13:58:00 -0700 (PDT)
Message-ID: <20100928.135800.39205209.davem@davemloft.net>
References: <55a4f86e1001131651j102b600fm1552a42866c3c671@mail.gmail.com>
	<1285581957-30694-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, maze@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36916
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752273Ab0I1U5k convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 16:57:40 -0400
In-Reply-To: <1285581957-30694-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon, 27 Sep 2010 03:05:57 -0700

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>

Please handle all 4 cases just like the ipv4 routing code does:

{ saddr =3D SADDR, ifindex =3D dev->ifindex }
{ saddr =3D SADDR, ifindex =3D 0 }
{ saddr =3D INADDR_ANY, ifindex =3D dev->ifindex }
{ saddr =3D INADDR_ANY, ifindex =3D 0 }

I believe I've specifically asked for this every time someone
mentioned that they wanted to fix this issue.

And the ipv4 side is a good guide in other ways, it uses a set
of two arrays so you can just loop over them, making your
rt6_do_pmtu_disc() calls along the way.


