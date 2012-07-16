From: Andrew Vagin <avagin@parallels.com>
Subject: Re: [PATCH] net-next: make sock diag per-namespace
Date: Mon, 16 Jul 2012 16:38:15 +0400
Message-ID: <20120716123815.GA1178@avaginn.sw.ru>
References: <1342440849-1757320-1-git-send-email-avagin@openvz.org>
 <1342441945.23494.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Andrew Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pavel Emelianov <xemul@parallels.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:10096 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272Ab2GPMiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 08:38:20 -0400
Content-Disposition: inline
In-Reply-To: <1342441945.23494.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 04:32:25PM +0400, Eric Dumazet wrote:
> On Mon, 2012-07-16 at 16:14 +0400, Andrew Vagin wrote:
> > Before this patch sock_diag works for init_net only and dumps
> > information about sockets from all namespaces.
> 
> ...
> 
> > diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
> > index a7f86a3..52f42f9 100644
> > --- a/net/ipv4/udp_diag.c
> > +++ b/net/ipv4/udp_diag.c
> > @@ -34,6 +34,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
> >  	int err = -EINVAL;
> >  	struct sock *sk;
> >  	struct sk_buff *rep;
> > +	struct net *net = sock_net(in_skb->sk);
> >  
> >  	if (req->sdiag_family == AF_INET)
> >  		sk = __udp4_lib_lookup(&init_net,
> 
> It seems you didnt fix udp_dump_one() correctly, since it
> still mentions &init_net
You are right. Sorry for this stupid fault. I will send a new patch.
> 
> > @@ -75,7 +76,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
> >  		kfree_skb(rep);
> >  		goto out;
> >  	}
> > -	err = netlink_unicast(sock_diag_nlsk, rep, NETLINK_CB(in_skb).pid,
> > +	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).pid,
> >  			      MSG_DONTWAIT);
> >  	if (err > 0)
> >  		err = 0;
> 
> udp_dump() also needs some care ?
> 
> 
Yes
