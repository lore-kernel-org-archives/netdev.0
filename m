From: David Miller <davem@davemloft.net>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Thu, 09 Dec 2010 11:38:06 -0800 (PST)
Message-ID: <20101209.113806.71114756.davem@davemloft.net>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
	<1291906948.19763.16.camel@localhost>
	<AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, srk@ti.com, netdev@vger.kernel.org
To: mirqus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60489
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753288Ab0LIThi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 14:37:38 -0500
In-Reply-To: <AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirqus@gmail.com>
Date: Thu, 9 Dec 2010 19:47:57 +0100

> Isn't that condition too broad? If the data could change after packet
> is submitted to the driver then results would be unpredictable and
> allow sending wrong data with correct (because hw-calculated)
> checksum.

They are intentionally like that, without question.

Otherwise we'd need to interlock with all application mapped,
filesystem, and other page writes while sending any page over the
network.

We absolutely do not want to have to freeze every page we try to send
via sendfile() or similar, the cost is just too high.

If the application or networked filesystem needs such synchronization,
it provides it for itself.

=46or example, SAMBA only uses sendfile() when the file has an op-lock
held on it.

The checksum requirement for using SG is not going away, so continuing
to discuss along the lines of removing that requirement is not a good
use of your time I don't think.
