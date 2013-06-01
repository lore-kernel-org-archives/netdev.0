From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] icmp: avoid allocating large struct on stack
Date: Sat, 01 Jun 2013 11:42:46 +0800
Message-ID: <1370058166.4723.1.camel@cr0>
References: <1370057053-20519-1-git-send-email-amwang@redhat.com>
	 <1370057669.10556.104.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755270Ab3FADm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 23:42:56 -0400
In-Reply-To: <1370057669.10556.104.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-31 at 20:34 -0700, Joe Perches wrote:
> On Sat, 2013-06-01 at 11:24 +0800, Cong Wang wrote:
> > struct icmp_bxm is a large struct, reduce stack usage
> > by allocating it on heap.
> []
> > diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> []
> > @@ -558,6 +558,10 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
> >  		}
> >  	}
> >  
> > +	icmp_param = kzalloc(sizeof(*icmp_param), GFP_ATOMIC);
> 
> why kzalloc if the previous stack was uninitialized?
> 
> 

Right, kmalloc() should be sufficient here...
