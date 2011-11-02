From: Dave Jones <davej@redhat.com>
Subject: Re: Fix NULL dereference in x25_recvmsg
Date: Tue, 1 Nov 2011 22:15:25 -0400
Message-ID: <20111102021525.GA8512@redhat.com>
References: <20111102015315.GA6569@redhat.com>
 <1320199845.4728.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Matthew Daley <mattjd@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754105Ab1KBCP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Nov 2011 22:15:29 -0400
Content-Disposition: inline
In-Reply-To: <1320199845.4728.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 02, 2011 at 03:10:45AM +0100, Eric Dumazet wrote:
 > Le mardi 01 novembre 2011 =E0 21:53 -0400, Dave Jones a =E9crit :
 > > commit cb101ed2 in 3.0 introduced a bug in x25_recvmsg()
 > > When passed bogus junk from userspace, x25->neighbour can be NULL,
 > > as shown in this oops..
 > >=20
 >=20
 > Your patch seems fine but :
 >=20
 > Are you sure this bug is not present on previous kernels ?
 >=20
 > It seems we had prior to this commit :
 >=20
 > skb_pull(skb, x25->neighbour->extended ?
 > 	X25_EXT_MIN_LEN : X25_STD_MIN_LEN);

It might have been possible with a specifically crafted set of argument=
s.

It never showed up in testing before now, probably because we were
returning from the function before we got to that skb_pull
via all the other tests that get performed.

	Dave
