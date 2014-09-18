From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: sched: shrink struct qdisc_skb_cb to 28 bytes
Date: Thu, 18 Sep 2014 12:14:39 -0700
Message-ID: <1411067679.7106.283.camel@edumazet-glaptop2.roam.corp.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Yinghai Lu <yinghai@kernel.org>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, "Christian Benvenuti (benve)" <benve@cisco.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:42600 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaIRTOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 15:14:52 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so2144412pab.15
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 12:14:52 -0700 (PDT)
In-Reply-To: <1411063655.4290.18.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 11:07 -0700, Joe Perches wrote:

> > +static inline struct ipoib_cb *ipoib_skb_cb(const struct sk_buff *skb)
> > +{
> > +	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct ipoib_cb));
> > +	return (struct ipoib_cb *)skb->cb;
> > +}
> 
> It seems better not to use const for the struct sk_buff * here.
> 
> Neither of the uses take a const struct sk_buff *

Thats pretty standard, check for other similar constructs like that.


static inline struct qdisc_skb_cb *qdisc_skb_cb(const struct sk_buff *skb)
{
        return (struct qdisc_skb_cb *)skb->cb;
}

This allows uses of the helper when the skb is only read (has the const qual)
