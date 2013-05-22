From: Flavio Leitner <fbl@redhat.com>
Subject: Re: RFC limit sk_mem_quantum to 8192
Date: Wed, 22 May 2013 11:31:00 -0300
Message-ID: <20130522143100.GE17292@obelix.rh>
References: <20130522004541.GA17240@obelix.rh>
 <1369184962.3301.264.camel@edumazet-glaptop>
 <20130522015858.GB17240@obelix.rh>
 <1369189261.3301.269.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752744Ab3EVObE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 10:31:04 -0400
Content-Disposition: inline
In-Reply-To: <1369189261.3301.269.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 21, 2013 at 07:21:01PM -0700, Eric Dumazet wrote:
> On Tue, 2013-05-21 at 22:58 -0300, Flavio Leitner wrote:
> > On Tue, May 21, 2013 at 06:09:22PM -0700, Eric Dumazet wrote:
> >  
> > > Are you sure a network driver doesn't provide skb using a full page ?
> > 
> > You lost me. You're saying that today we consider a page size
> > a minimum and so if we reduce that, the skb wouldn't fit in the
> > min sk memory?
> 
> SK_MEM_QUANTUM is also used in UDP stack, thats why I am asking.

Yeah, it is. SCTP too, but for the protocol cases, the most
complex one appears to be TCP, and it doesn't seem to be a problem
to replace the minimum with something not page sized.

For the drivers, it seems to have an indirect assumption that
page size bytes is a minimum acceptable, so changing this minimum
could cause a performance issue.

Well, this define is quite old, so I am not sure if there are
other historical reasons to keep it page size. However, if the
idea of fixing SK_MEM_QUANTUM to 4k seems reasonable, I am
willing to spend more time digging into this.

Thanks!
-- 
fbl
