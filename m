From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [af-packet 1/2] Enhance af-packet to provide (near
 zero)lossless packet capture functionality.
Date: Thu, 09 Jun 2011 00:22:54 +0200
Message-ID: <1307571774.3980.7.camel@edumazet-laptop>
References: <1307502786-1396-1-git-send-email-loke.chetan@gmail.com>
	 <1307502786-1396-2-git-send-email-loke.chetan@gmail.com>
	 <1307507754.3102.18.camel@edumazet-laptop>
	 <BANLkTi=_EFRaiPuT=OjwRaJ4XPw0sUhcnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	johann.baudy@gnu-log.net, Chetan Loke <lokec@ccs.neu.edu>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41491 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763Ab1FHWW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 18:22:59 -0400
Received: by wya21 with SMTP id 21so712553wya.19
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 15:22:57 -0700 (PDT)
In-Reply-To: <BANLkTi=_EFRaiPuT=OjwRaJ4XPw0sUhcnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 juin 2011 =C3=A0 18:10 -0400, chetan loke a =C3=A9crit :

> Eric, thanks for pointing that. I will add the padding. But just out
> of curiosity, how is the information being leaked in tpacket_rcv()?
>=20
> If someone is capturing packets then they have access to all the data
> anyways. Also, tpacket_rcv doesn't memset the frame-element to 'zero'
> before calling
> skb_copy_bits(). And we would never want to memset anyways.
>=20

Its a security risk, leaking content of kernel stack or kernel memory.

capturing packets capability is not meaning "accessing full memory"

Some clever hackers can exploit these kind of leaks.

Better make sure we dont have holes in structures copied to user.
(or mapped in this case, but you never knows ;) )



