From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] skbuff: Add new tc classify variable
Date: Wed, 08 Feb 2012 10:21:56 +0100
Message-ID: <1328692916.2284.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
	 <20120207.135841.1753473725075272902.davem@davemloft.net>
	 <20120207201633.GB26533@pandem0nium>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-wireless@vger.kernel.org
To: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120207201633.GB26533@pandem0nium>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 07 f=C3=A9vrier 2012 =C3=A0 21:16 +0100, Simon Wunderlich a =C3=
=A9crit :
> Hello David,
>=20
> On Tue, Feb 07, 2012 at 01:58:41PM -0500, David Miller wrote:
> > From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
> > Date: Tue,  7 Feb 2012 19:39:08 +0100
> >=20
> > > The linux traffic control mechanism has different ways to select =
the
> > > correct class of a qdisc. A common way to do this is to use tc fi=
lters
> > > that are directly attached to a qdisc. Another approach is to use=
 the
> > > iptables classify module. The latter one can reduce the amount of=
 work
> > > necessary to process a packet when iptables is already involved i=
n the
> > > packet classification.
> >=20
> > Do not bloat up sk_buff any more.  Add this, and the other existing
> > tc_* members to the qdisc SKB control block instead.
> >=20
>=20
> Thanks for your feedback!
>=20
> I guess you mean skb->cb, but this is also used within mac80211 for v=
arious things
> (quoting include/net/mac80211.h):
>=20
>  * struct ieee80211_tx_info - skb transmit information
>  *
>  * This structure is placed in skb->cb for three uses:
>  *  (1) mac80211 TX control - mac80211 tells the driver what to do
>  *  (2) driver internal use (if applicable)
>  *  (3) TX status information - driver tells mac80211 what happened
>=20
> We could give it a try, but we most probably run into conflicts again=
=2E
>=20
> I've messed up the CCs in my initial mail (and just resent it) - sorr=
y about that.
> Maybe the mac80211 guys have a suggestion as well :)
>=20

I really dont understand what the conflict might be.

As long as skb is in Qdisc layer, Qdisc owns skb->cb[] (a part of it
actually, see current discussions about IB on netdev)

As soon as packet is given to device (mac80211), cb[] can be reused.

Or are you saying tc_class also might be needed by mac80211 in the
future ?



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
