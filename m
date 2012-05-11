From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH v3][resend] bonding: don't increase rx_dropped after
 processing LACPDUs
Date: Fri, 11 May 2012 15:54:10 +0200
Message-ID: <20120511135410.GA11466@midget.suse.cz>
References: <20120509110140.GA9817@midget.suse.cz>
 <20120510.233134.1390996845692589691.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jbohac@suse.cz, andy@greyhouse.net, netdev@vger.kernel.org,
	fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38919 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759847Ab2EKNyU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2012 09:54:20 -0400
Content-Disposition: inline
In-Reply-To: <20120510.233134.1390996845692589691.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 10, 2012 at 11:31:34PM -0400, David Miller wrote:
> > Since commit 3aba891d, bonding processes LACP frames (802.3ad
> > mode) with bond_handle_frame(). Currently a copy of the skb is
> > made and the original is left to be processed by other
> > rx_handlers and the rest of the network stack by returning
> > RX_HANDLER_ANOTHER.  As there is no protocol handler for
> > PKT_TYPE_LACPDU, the frame is dropped and dev->rx_dropped
> > increased.
> >=20
> > Fix this by making bond_handle_frame() return RX_HANDLER_CONSUMED
> > if bonding has processed the LACP frame.
> >=20
> > Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> >=20
>=20
> Don't send me garbage you didn't even check the compile of:
>=20
> drivers/net/bonding/bond_main.c: In function =E2=80=98bond_handle_fra=
me=E2=80=99:
> drivers/net/bonding/bond_main.c:1463:13: warning: assignment from inc=
ompatible pointer type [enabled by default]
> drivers/net/bonding/bond_main.c: In function =E2=80=98bond_open=E2=80=
=99:
> drivers/net/bonding/bond_main.c:3441:21: warning: assignment from inc=
ompatible pointer type [enabled by default]
> drivers/net/bonding/bond_main.c:3448:20: warning: assignment from inc=
ompatible pointer type [enabled by default]

sorry, I overlooked these warnings. The patch actually broke the
rlb mode which I did not test.=20

I'll send a fixed patch (v4).

Thanks!

--=20
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
