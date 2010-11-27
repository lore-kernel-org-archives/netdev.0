From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter:  fix  race in conntrack between dump_table
 and destroy
Date: Sat, 27 Nov 2010 07:32:49 +0100
Message-ID: <1290839569.2794.6.camel@edumazet-laptop>
References: <20101124222716.437c5547@nehalam>
	 <1290666873.2798.89.camel@edumazet-laptop>
	 <20101124230004.1dc28e5a@nehalam>
	 <1290669214.2798.109.camel@edumazet-laptop>
	 <20101126135101.4e4b97cc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101126135101.4e4b97cc@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 26 novembre 2010 =C3=A0 13:51 -0800, Stephen Hemminger a =C3=
=A9crit :
> The netlink interface to dump the connection tracking table has a rac=
e
> when entries are deleted at the same time. A customer reported a cras=
h=20
> and the backtrace showed thatctnetlink_dump_table was running while a=
=20
> conntrack entry wasbeing destroyed.
> (see https://bugzilla.vyatta.com/show_bug.cgi?id=3D6402).
>=20
> According to RCU documentation, when using hlist_nulls the reader
> must handle the case of seeing a deleted entry and not proceed
> further down the linked list.  The old code would continue
> which caused the scan to walk into the free list.=20
>=20
> This patch uses locking (rather than RCU) for this operation which
> is guaranteed safe, and no longer requires getting reference while
> doing dump operation.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
