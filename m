From: =?iso-8859-1?Q?Wolf-Bastian_P=F6ttner?= <poettner@ibr.cs.tu-bs.de>
Subject: Re: [PATCH] net/ieee802154/6lowpan: Fix initialization for fragment offset
Date: Wed, 13 Mar 2013 15:40:06 +0100
Message-ID: <D859EF9A-19A9-4F74-B59D-28FADBCE338A@ibr.cs.tu-bs.de>
References: <1363161054-13471-1-git-send-email-poettner@ibr.cs.tu-bs.de> <20130313.103830.247889330240632952.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-zigbee-devel@lists.sourceforge.net,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from salvator.ibr.cs.tu-bs.de ([134.169.34.11]:35261 "EHLO
	salvator.ibr.cs.tu-bs.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab3CMOkN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 10:40:13 -0400
In-Reply-To: <20130313.103830.247889330240632952.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!


Nope. The patch fixes a problem in code that is not in mainline yet. Ho=
wever, people on the linux-zigbee mailing list found it a good idea to =
commit this change to mainline to avoid the problem from arising.

I see, you disagree. Nevermind. ;)


Bastian
--=20
Wolf-Bastian P=F6ttner      Institut f=FCr Betriebssysteme & Rechnerver=
bund
Tel.: +49-531-391-3265                           M=FChlenpfordtstrasse =
23
=46ax.: +49-531-391-5936         TU Braunschweig     D-38106 Braunschwe=
ig

Am 13.03.2013 um 15:38 schrieb David Miller <davem@davemloft.net>:

> From: Wolf-Bastian P=F6ttner <poettner@ibr.cs.tu-bs.de>
> Date: Wed, 13 Mar 2013 08:50:54 +0100
>=20
>> offset has to be initialized, otherwise the *first* fragment will
>> be discarded and reassembly cannot happen.
>>=20
>> Reviewed-by: Alan Ott <alan@signal11.us>
>=20
> 'offset' is never used unless lowpan_fetch_skb_u8(skb, &offset)
> succeeds, in which case it will be initialized properly.  Otherwise w=
e
> unlock and drop the SKB and make no references whatsoever to 'offset'=
=2E
>=20
> I suspect you saw some compiler warning about 'offset' being
> uninitialized, and are just blindly trying to shut this warning up.
