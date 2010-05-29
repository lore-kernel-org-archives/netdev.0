From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fec: fix pm to survive to suspend/resume
Date: Sat, 29 May 2010 00:15:34 -0700 (PDT)
Message-ID: <20100529.001534.57459102.davem@davemloft.net>
References: <536177.31761.qm@web51001.mail.re2.yahoo.com>
	<1274982828-13082-1-git-send-email-eric@eukrea.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.hauer@pengutronix.de, sshtylyov@mvista.com,
	linux-arm-kernel@lists.infradead.org, fabioestevam@yahoo.com,
	netdev@vger.kernel.org
To: eric@eukrea.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752312Ab0E2HPX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 May 2010 03:15:23 -0400
In-Reply-To: <1274982828-13082-1-git-send-email-eric@eukrea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric B=E9nard <eric@eukrea.com>
Date: Thu, 27 May 2010 19:53:48 +0200

> * with this patch, if the connection if active before suspend, it
> will be active after resume.
> * before this patch, it was necessary to close the interface and
> reopen it to recover the connection.
>=20
> Signed-off-by: Eric B=E9nard <eric@eukrea.com>

On resume the PHY should be reset and the link renegotiated (or set to
a fixed speed/duplex if set by the user via ethtool) just like as
happens on ->open().

You seem to be avoiding that here.

If the PHY is not functioning properly after the ->resume() triggered
reset, fix that instead.

I'm not applying this patch, it doesn't look the right thing to do at
all.
