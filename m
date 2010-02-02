From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM with summary: Re: [PATCH] netfilter: per netns
 nf_conntrack_cachep
Date: Tue, 02 Feb 2010 18:16:30 +0100
Message-ID: <1265130990.2953.176.camel@edumazet-laptop>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265019160.2848.14.camel@edumazet-laptop>
	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
	 <1265023437.2848.30.camel@edumazet-laptop>
	 <1265035970.2848.50.camel@edumazet-laptop>
	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>
	 <1265036548.2848.55.camel@edumazet-laptop>
	 <1265108690.2861.118.camel@tonnant>  <1265110504.2861.135.camel@tonnant>
	 <1265129192.2861.141.camel@tonnant> <1265129903.2861.150.camel@tonnant>
	 <4B685B14.1040207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Masters <jonathan@jonmasters.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B685B14.1040207@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 02 f=C3=A9vrier 2010 =C3=A0 18:04 +0100, Patrick McHardy a =C3=
=A9crit :

> Ah nice catch, that seems to be the problem. When the untracked
> conntrack is already attached to an skb and thus has refcnt > 1
> and we re-initalize the refcnt, it will get freed.
>=20
> The question is whether the ct_net pointer of the untracked conntrack
> is actually required. If so, we need one instance per namespace,
> otherwise we can just move initialization and cleanup to the init_net
> init/cleanup functions. Alexey, do you happen to know this?
>=20

One untracked per netns seems the way to go, and move it outside of
read_mostly area too, we obviously can modify its refcount frequently..=
=2E


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
