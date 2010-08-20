From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] netfilter: save the hash of the tuple in the
 original direction for latter use
Date: Fri, 20 Aug 2010 17:10:16 +0200
Message-ID: <1282317016.2484.173.camel@edumazet-laptop>
References: <1282316003-2966-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282316003-2966-1-git-send-email-xiaosuo@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 22:53 +0800, Changli Gao a =C3=A9c=
rit :
> Since we don't change the tuple in the original direction, we can sav=
e it
> in ct->tuplehash[IP_CT_DIR_REPLY].hnode.pprev for __nf_conntrack_conf=
irm()
> use.
>=20
> __hash_conntrack() is split into two steps: ____hash_conntrack() is u=
sed
> to get the raw hash, and __hash_bucket() is used to get the bucket id=
=2E
>=20
> In SYN-flood case, early_drop() doesn't need to recompute the hash ag=
ain.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---

Hmm... so to accept a few more SYN packets per second in SYNFLOOD
attack, we slow a bit normal operations ? (adding one test on each
packet going through conntrack)

If yes (I dont think we should, hackers are stronger than you anyway,
just face it)

v4:
	__read_mostly on nf_conntrack_rnd


What would happen if we let the initialization of nf_conntrack_rnd
only in the insertion case (like currently done) ?=20
Only the first packet received on the machine/conntrack might be hashed
on a wrong slot. Is it a big deal ? If yes, maybe find a way to
recompute the hash in this case, instead of reusing 'wrong' one ?
