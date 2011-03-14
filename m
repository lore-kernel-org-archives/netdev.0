From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/4] netfilter: xt_connlimit: fix daddr connlimit in SNAT
 scenario
Date: Mon, 14 Mar 2011 13:26:00 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1103141310140.27542@obet.zrqbmnf.qr>
References: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2011-03-14 07:50, Changli Gao wrote:

>We use the reply tuples when limiting the connections by the destinati=
on
>addresses, however, in SNAT scenario, the final reply tuples won't be
>ready until SNAT is done in POSTROUING or INPUT chain

If I am not mistaken: if you do daddr counting, SNAT is irrelevant.
Consider ruleset
 -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to 1.2.3.4:80
 -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to 1.2.3.5:443

The tuple will first be (as per conntrack -L):
 src=3Dhome dst=3Drouter src=3Drouter dst=3Dhome
After DNAT:
 src=3Dhome dst=3Drouter src=3D1.2.3.4 dst=3Dhome

Thus looking at the src of the reply tuple seems correct =E2=80=94 at l=
east this=20
is what was wanted, counting per stashed servers (=3D1 customer), not p=
er=20
globally visible address.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
