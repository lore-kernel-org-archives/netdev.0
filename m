From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 06/20] ppp: slight optimization of addr compare
Date: Tue, 24 Dec 2013 08:35:49 -0800
Message-ID: <1387902949.2259.51.camel@joe-AO722>
References: <52B96FCD.50901@huawei.com>
	 <52B9B559.2060400@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Michal Ostrowski <mostrows@earthlink.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52B9B559.2060400@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-24 at 20:24 +0400, Sergei Shtylyov wrote:
> On 24-12-2013 15:28, Ding Tianhong wrote:
[]
> > diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
[]
> > @@ -131,12 +131,13 @@ static inline struct pppoe_net *pppoe_pernet(struct net *net)
> >
> >   static inline int cmp_2_addr(struct pppoe_addr *a, struct pppoe_addr *b)
> >   {
> > -	return a->sid == b->sid && !memcmp(a->remote, b->remote, ETH_ALEN);
> > +	return a->sid == b->sid && ether_addr_equal(a->remote,
> > +							      b->remote);
> 
>     If it really doesn't fit insto single line, the continuation line should 
> start right under 'a->remote'.

Better still might be

	return a->sid == b->sid &&
	       ether_addr_equal(a->remote, b->remote);
