From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 v2] bonding: COW before overwriting the destination
 MAC address
Date: Thu, 03 Mar 2011 09:35:02 +0100
Message-ID: <1299141302.2456.42.camel@edumazet-laptop>
References: <1299136034-5549-1-git-send-email-xiaosuo@gmail.com>
	 <1299138901.2456.32.camel@edumazet-laptop>
	 <AANLkTimNb-ZPFuhhdsSroFzaHKFauR3pTBXL3HMmnECf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62850 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756809Ab1CCIfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 03:35:08 -0500
Received: by fxm17 with SMTP id 17so861074fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 00:35:07 -0800 (PST)
In-Reply-To: <AANLkTimNb-ZPFuhhdsSroFzaHKFauR3pTBXL3HMmnECf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 16:21 +0800, Changli Gao a =C3=A9crit :
> On Thu, Mar 3, 2011 at 3:55 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> >
> >
> >
> > Thats minor, but using :
> >
> > u16 *dest =3D eth_hdr(skb)->h_dest;
> >
> > memcpy(dest, ptr, ETH_ALEN);
> >
> > Is better because compiler knows both destination and source are at
> > least aligned on shorts.
> >
> > On some arches, it helps to not using 6 bytes copy, but 3 shorts.
> >
> >
>=20
> Is it still true if ptr isn't aligned on shorts? And
> net_device.dev_addr is an unsigned char *pointer. Thanks.
>=20

dev_addr[] was aligned to word boundaries (because of natural structure
alignment), but the recent changes made it a char *pointer, so gcc is
not able to make this true anymore.

This could change if dev_addr was a pointer to struct netdev_hw_addr



