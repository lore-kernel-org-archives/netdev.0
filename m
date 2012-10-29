From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: fix a potential NULL deref
Date: Mon, 29 Oct 2012 15:25:23 +0800
Message-ID: <1351495523.8221.8.camel@cr0>
References: <1351482620-11008-1-git-send-email-amwang@redhat.com>
	 <1351491005.7394.7.camel@edumazet-glaptop>  <1351493366.8221.2.camel@cr0>
	 <1351494334.7394.64.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7602 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753549Ab2J2HZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 03:25:29 -0400
In-Reply-To: <1351494334.7394.64.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-29 at 08:05 +0100, Eric Dumazet wrote:
> On Mon, 2012-10-29 at 14:49 +0800, Cong Wang wrote:
> > On Mon, 2012-10-29 at 07:10 +0100, Eric Dumazet wrote:
> > > > -		dst_release(&rt->dst);
> > > > +		if (rt)
> > > > +			dst_release(&rt->dst);
> > > >  	}
> > > >  
> > > 
> > > dst_release() is like kfree(), it accepts a NULL argument.
> > > 
> > 
> > 'rt->dst' already dereferences 'rt', no matter dst_release() accepts
> > NULL or not.
> > 
> > 
> 
> &rt->dst doesnt dereference rt, you are quite mistaken.
> 
> if rt is NULL, &rt->dst is also NULL
> 

Oh, yeah, gcc should be smart enough to do calculation without deref it
given it has the offset and the address. And dst happens to be first
field of rt, so offset is 0, &rt->dst should be NULL too if rt is NULL.

But this will be a problem if someone moved dst inside rt, as there is
no comment saying dst has to be the first one?
