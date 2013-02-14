From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] bridge: add some missing __rcu marks
Date: Thu, 14 Feb 2013 16:23:25 +0800
Message-ID: <1360830205.3279.1.camel@cr0>
References: <1360822350-26882-1-git-send-email-amwang@redhat.com>
	 <20130213223935.122d035b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33095 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756160Ab3BNIXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 03:23:35 -0500
In-Reply-To: <20130213223935.122d035b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-13 at 22:39 -0800, Stephen Hemminger wrote:
> On Thu, 14 Feb 2013 14:12:30 +0800
> Cong Wang <amwang@redhat.com> wrote:
> >  #ifdef CONFIG_NET_POLL_CONTROLLER
> > -static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
> > +static inline struct netpoll_info __rcu *br_netpoll_info(struct net_bridge *br)
> >  {
> >  	return br->dev->npinfo;
> >  }
> 
> 
> This doesn't seem right since there is no rcu_dereference() here.

But we don't dereference ->npinfo here, we only check if it is NULL.
