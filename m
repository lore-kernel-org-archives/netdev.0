From: Patrick McHardy <kaber@trash.net>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 12:56:57 +0200
Message-ID: <4BD17CF9.4020502@trash.net>
References: <1271941082.14501.189.camel@jdb-workstation>	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1271946961.7895.5665.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le jeudi 22 avril 2010 =E0 15:17 +0200, Patrick McHardy a =E9crit :
>> Changli Gao wrote:
>>>> struct nf_conntrack_tuple_hash *
>>>> __nf_conntrack_find(struct net *net, const struct nf_conntrack_tup=
le *tuple)
>>>> ...
>>> We should add a retry limit there.
>> We can't do that since that would allow false negatives.
>=20
> If one hash slot is under attack, then there is a bug somewhere.
>=20
> If we cannot avoid this, we can fallback to a secure mode at the seco=
nd
> retry, and take the spinlock.
>=20
> Tis way, most of lookups stay lockless (one pass), and some might tak=
e
> the slot lock to avoid the possibility of a loop.

That sounds like a good idea. But lets what for Jesper's test results
before we start fixing this problem :)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
