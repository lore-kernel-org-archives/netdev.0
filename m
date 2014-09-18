From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net] net: sched: shrink struct qdisc_skb_cb to 28 bytes
Date: Thu, 18 Sep 2014 12:31:11 -0700
Message-ID: <1411068671.4290.24.camel@joe-AO725>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com>
	 <1402338773-5996-2-git-send-email-_govind@gmx.com>
	 <CAE9FiQW+Rv4o9Pc1J9hyqgW1WrhEANKEXH6zYQc2NQqeMbAcvA@mail.gmail.com>
	 <alpine.LNX.2.03.1406261159071.1438@ws.cisco>
	 <CAJZOPZJ7+n0t1LCqaa3JCBByRw=f_Tp6rk8vm0ZnCzmtKFKX_g@mail.gmail.com>
	 <1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140918092628.566eae2b@urahara>
	 <1411057934.7106.275.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411063227.7106.280.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411063655.4290.18.camel@joe-AO725>
	 <1411067679.7106.283.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Yinghai Lu <yinghai@kernel.org>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, "Christian Benvenuti (benve)" <benve@cisco.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0098.hostedemail.com ([216.40.44.98]:36101 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751253AbaIRTba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 15:31:30 -0400
In-Reply-To: <1411067679.7106.283.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 12:14 -0700, Eric Dumazet wrote:
> On Thu, 2014-09-18 at 11:07 -0700, Joe Perches wrote:
> 
> > > +static inline struct ipoib_cb *ipoib_skb_cb(const struct sk_buff *skb)
> > > +{
> > > +	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct ipoib_cb));
> > > +	return (struct ipoib_cb *)skb->cb;
> > > +}
> > 
> > It seems better not to use const for the struct sk_buff * here.
> > 
> > Neither of the uses take a const struct sk_buff *
> 
> Thats pretty standard, check for other similar constructs like that.
> 
> 
> static inline struct qdisc_skb_cb *qdisc_skb_cb(const struct sk_buff *skb)
> {
>         return (struct qdisc_skb_cb *)skb->cb;
> }
> 
> This allows uses of the helper when the skb is only read (has the const qual)

I don't mind the const argument, but casting
the return to non-const seems like poor form.

btw: it seems like it's 8:5 non-const to const

$ grep -rP --include=*.[ch] -n "cb\s*\*\s*\w+\s*\(\s*(?:const\s+)?struct\s+sk_buff\s*\*\s*\w+\s*\)" *
drivers/net/ethernet/freescale/gianfar.c:2091:static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
drivers/net/wireless/ath/ath10k/core.h:83:static inline struct ath10k_skb_cb *ATH10K_SKB_CB(struct sk_buff *skb)
include/net/mrp.h:38:static inline struct mrp_skb_cb *mrp_cb(struct sk_buff *skb)
include/net/ieee802154_netdev.h:235:static inline struct ieee802154_mac_cb *mac_cb(struct sk_buff *skb)
include/net/ieee802154_netdev.h:240:static inline struct ieee802154_mac_cb *mac_cb_init(struct sk_buff *skb)
include/net/sch_generic.h:251:static inline struct qdisc_skb_cb *qdisc_skb_cb(const struct sk_buff *skb)
include/net/codel.h:95:static struct codel_skb_cb *get_codel_cb(const struct sk_buff *skb)
include/net/garp.h:36:static inline struct garp_skb_cb *garp_cb(struct sk_buff *skb)
net/core/dev.c:2177:static struct dev_kfree_skb_cb *get_kfree_skb_cb(const struct sk_buff *skb)
net/sched/sch_choke.c:142:static inline struct choke_skb_cb *choke_skb_cb(const struct sk_buff *skb)
net/sched/sch_sfb.c:95:static inline struct sfb_skb_cb *sfb_skb_cb(const struct sk_buff *skb)
net/sched/sch_netem.c:171:static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
net/sched/sch_sfq.c:167:static inline struct sfq_skb_cb *sfq_skb_cb(const struct sk_buff *skb)
