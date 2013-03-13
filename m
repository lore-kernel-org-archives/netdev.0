From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ieee802154/6lowpan: Fix initialization for
 fragment offset
Date: Wed, 13 Mar 2013 10:38:30 -0400 (EDT)
Message-ID: <20130313.103830.247889330240632952.davem@davemloft.net>
References: <1363161054-13471-1-git-send-email-poettner@ibr.cs.tu-bs.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-zigbee-devel@lists.sourceforge.net,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org
To: poettner@ibr.cs.tu-bs.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44319 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab3CMOiS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 10:38:18 -0400
In-Reply-To: <1363161054-13471-1-git-send-email-poettner@ibr.cs.tu-bs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Wolf-Bastian P=F6ttner <poettner@ibr.cs.tu-bs.de>
Date: Wed, 13 Mar 2013 08:50:54 +0100

> offset has to be initialized, otherwise the *first* fragment will
> be discarded and reassembly cannot happen.
>=20
> Reviewed-by: Alan Ott <alan@signal11.us>

'offset' is never used unless lowpan_fetch_skb_u8(skb, &offset)
succeeds, in which case it will be initialized properly.  Otherwise we
unlock and drop the SKB and make no references whatsoever to 'offset'.

I suspect you saw some compiler warning about 'offset' being
uninitialized, and are just blindly trying to shut this warning up.
