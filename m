From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next] flow_dissector: fix vlan tag handling
Date: Mon, 24 Oct 2016 18:00:32 +0200
Message-ID: <28288577.YZfdMibjpz@wuerfel>
References: <20161021155626.4020344-1-arnd@arndb.de> <3590200.oN5tv3ZPpc@wuerfel> <20161024081736.GB2781@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@48lvckh6395k16k5.yundunddos.com>,
        Amir Vadai <amir@vadai.me>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161024081736.GB2781@nanopsycho>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, October 24, 2016 10:17:36 AM CEST Jiri Pirko wrote:
> Sat, Oct 22, 2016 at 10:30:08PM CEST, arnd@arndb.de wrote:
> >diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> >index 44e6ba9d3a6b..17be1b66cc41 100644
> >--- a/net/core/flow_dissector.c
> >+++ b/net/core/flow_dissector.c
> >@@ -246,13 +246,10 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
> > 	case htons(ETH_P_8021AD):
> > 	case htons(ETH_P_8021Q): {
> > 		const struct vlan_hdr *vlan;
> >+		struct vlan_hdr _vlan;
> >+		bool vlan_tag_present = (skb && skb_vlan_tag_present(skb));
> 
> Drop the unnecessary "()"

ok

> > 
> >-		if (skb && skb_vlan_tag_present(skb))
> >-			proto = skb->protocol;
> 
> This does not look correct. I believe that you need to set proto for
> further processing.
> 

Ah, of course. I only looked at the usage in this 'case' statement,
but the variable is also used after the 'goto again' and at
the end of the function.

	Arnd
