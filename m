From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH v3 net-next 1/3] ipv4: rename ip_options_echo to
 __ip_options_echo()
Date: Fri, 26 Sep 2014 08:21:57 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1409260820470.2078@localhost6.localdomain6>
References: <1411676092-16196-1-git-send-email-edumazet@google.com>  <1411676092-16196-2-git-send-email-edumazet@google.com>  <1411677008.3460.7.camel@joe-AO725>  <1411677484.16953.43.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411678163.3460.9.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Julia Lawall <julia.lawall@lip6.fr>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:57304 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752976AbaIZGWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 02:22:00 -0400
In-Reply-To: <1411678163.3460.9.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Sep 2014, Joe Perches wrote:

> On Thu, 2014-09-25 at 13:38 -0700, Eric Dumazet wrote:
> > On Thu, 2014-09-25 at 13:30 -0700, Joe Perches wrote:
> > 
> > > Unrelated:
> > > 
> > > I wonder how much effort, if any, should be made to convert
> > > struct sk_buff * to const struct sk_buff * where appropriate.
> > > 
> > > For instance:
> > > 
> > > This __ip_options_echo could use const struct sk_buff *skb
> > > if fib_compute_spec_dst was changed to const struct sk_buff *skb.
> > 
> > Well, this seems something certainly doable, as a follow up ;)
> 
> It's doable, but it seems a non-trivial inspection task.
> 
> I believe coccinelle does not have the ability to automate this.

For example, can this function declare skb as const?  Or would one have to 
know that vde_user_write does not modify the contents of skb->data as 
well?

julia

static int vde_write(int fd, struct sk_buff *skb, struct uml_net_private 
*lp)
{
        struct vde_data *pri = (struct vde_data *) &lp->user;

        if (pri->conn != NULL)
                return vde_user_write((void *)pri->conn, skb->data,
                                      skb->len);

        printk(KERN_ERR "vde_write - we have no VDECONN to write to");
        return -EBADF;
}



> 
> 
> 
