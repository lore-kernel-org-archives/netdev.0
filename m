From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: don't disable BH again in BH disabled
 context
Date: Tue, 17 Aug 2010 08:55:27 +0200
Message-ID: <1282028127.2487.754.camel@edumazet-laptop>
References: <1282027297-9998-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1282027297-9998-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 17 ao=C3=BBt 2010 =C3=A0 14:41 +0800, Changli Gao a =C3=A9crit=
 :
> All the matches and targets of iptables, ip6tables are in BH disabled
> context, since xt_info_rdlock_bh() disables BH.
>=20

Its a thing that might change in a future version. Not a hard fact.

You can probably change iptables to allow softirqs while processing
OUTPUT chains.

We had some attempts in the past to switch to RCU.

It failed at that time because of some RCU implementation details, but
with recent RCU changes, we might try again, and have a clean
implementation, allowing softirqs.

So your patch would need to be reverted.


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
