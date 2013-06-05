From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v1 1/3] igmp: avoid taking RTNL for
 ip_mc_find_dev()
Date: Wed, 05 Jun 2013 13:23:19 +0800
Message-ID: <1370409799.2609.7.camel@cr0>
References: <1370403211-6851-1-git-send-email-amwang@redhat.com>
	 <1370405222.24311.231.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60870 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243Ab3FEFX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 01:23:26 -0400
In-Reply-To: <1370405222.24311.231.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-04 at 21:07 -0700, Eric Dumazet wrote:
> On Wed, 2013-06-05 at 11:33 +0800, Cong Wang wrote:
> > +		rcu_read_lock();
> >  		imr->imr_ifindex = dev->ifindex;
> > -		idev = __in_dev_get_rtnl(dev);
> > +		idev = __in_dev_get_rcu(dev);
> > +		rcu_read_unlock();
> >  	}
> >  	return idev;
> >  }
> 
> 
> You must be kidding.
> 
> This is obviously wrong.
> 

Oops, rcu_read_lock should be taken for the whole life of 'idev'...
