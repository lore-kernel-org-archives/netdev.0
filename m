From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Mon, 16 Aug 2010 08:31:16 +0200
Message-ID: <1281940276.3683.7.camel@jlt3.sipsolutions.net>
References: <1281710115.3760.27.camel@jlt3.sipsolutions.net>
	 <1281710887.4470.78.camel@edumazet-laptop>
	 <1281712433.2116.15.camel@jlt3.sipsolutions.net>
	 <20100814.223722.116371746.davem@davemloft.net>
	 <1281936351.3683.1.camel@jlt3.sipsolutions.net>
	 <1281939002.2942.70.camel@edumazet-laptop>
	 <1281939753.3683.5.camel@jlt3.sipsolutions.net>
	 <1281940172.2942.81.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:33901 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab0HPGbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 02:31:21 -0400
In-Reply-To: <1281940172.2942.81.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-16 at 08:29 +0200, Eric Dumazet wrote:
> Le lundi 16 ao=C3=BBt 2010 =C3=A0 08:22 +0200, Johannes Berg a =C3=A9=
crit :
> > On Mon, 2010-08-16 at 08:10 +0200, Eric Dumazet wrote:
> >=20
> > > We'll find another way to address the problem.
> >=20
> > For my understanding: The problem is that the save/restore of the
> > frag_list skb can race so a second reader will not see the frag_lis=
t skb
> > because it gets there while it's NULL. This happens with MSG_PEEK, =
or
> > with clones of the SKB since skb_shared_info is invariant across cl=
ones.
> >=20
> > Correct?
> >=20
>=20
> Yes
>=20
> I believe we should have a mutual exclusion for the critical section.
>=20
> (setting pointer to NULL, ...., setting pointer back to its orig valu=
e)

Yeah, that'd work, but I'm wondering now why I did this at all. The cod=
e
already restricts the data copying to skb->len, which will not include
the frag_list, so it should be OK to just leave it intact? I'll go and
look at that in more detail and try it.

johannes

