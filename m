From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netlink: fix compat recvmsg
Date: Mon, 16 Aug 2010 15:01:28 +0200
Message-ID: <1281963688.2524.44.camel@edumazet-laptop>
References: <1281710115.3760.27.camel@jlt3.sipsolutions.net>
	 <1281710887.4470.78.camel@edumazet-laptop>
	 <1281712433.2116.15.camel@jlt3.sipsolutions.net>
	 <20100814.223722.116371746.davem@davemloft.net>
	 <1281936351.3683.1.camel@jlt3.sipsolutions.net>
	 <1281939002.2942.70.camel@edumazet-laptop>
	 <1281939753.3683.5.camel@jlt3.sipsolutions.net>
	 <1281940172.2942.81.camel@edumazet-laptop>
	 <1281943244.3683.8.camel@jlt3.sipsolutions.net>
	 <1281963025.2524.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Kalle Valo <kalle.valo@iki.fi>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58584 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab0HPNBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 09:01:34 -0400
Received: by wwj40 with SMTP id 40so6490391wwj.1
        for <netdev@vger.kernel.org>; Mon, 16 Aug 2010 06:01:32 -0700 (PDT)
In-Reply-To: <1281963025.2524.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 ao=C3=BBt 2010 =C3=A0 14:50 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le lundi 16 ao=C3=BBt 2010 =C3=A0 09:20 +0200, Johannes Berg a =C3=A9=
crit :
> > From: Johannes Berg <johannes.berg@intel.com>
> >=20
> > Since
> > commit 1dacc76d0014a034b8aca14237c127d7c19d7726
> > Author: Johannes Berg <johannes@sipsolutions.net>
> > Date:   Wed Jul 1 11:26:02 2009 +0000
> >=20
> >     net/compat/wext: send different messages to compat tasks
> >=20
> > we had a race condition when setting and then
> > restoring frag_list. Eric attempted to fix it,
> > but the fix created even worse problems.
> >=20
> > However, the original motivation I had when I
> > added the code that turned out to be racy is
> > no longer clear to me, since we only copy up
> > to skb->len to userspace, which doesn't include
> > the frag_list length. As a result, not doing
> > any frag_list clearing and restoring avoids
> > the race condition, while not introducing any
> > other problems.
> >=20
> > Additionally, while preparing this patch I found
> > that since none of the remaining netlink code is
> > really aware of the frag_list, we need to use the
> > original skb's information for packet information
> > and credentials. This fixes, for example, the
> > group information received by compat tasks.
> >=20
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: stable@kernel.org [2.6.31+, for 2.6.35 revert 1235f504aa]
> > Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> > ---
>=20
> As a side effect, it might fix the=20
>=20
> 	if (nlk->flags & NETLINK_RECV_PKTINFO)
> 		netlink_cmsg_recv_pktinfo(msg, skb);
>=20
> That tried to use pktinfo from the slave skb. After this
> patch, skb points to master skb.
>=20

As you already mentioned it in your changelog, I missed it ;)



