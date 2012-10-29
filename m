From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: fix a potential NULL deref
Date: Mon, 29 Oct 2012 14:49:26 +0800
Message-ID: <1351493366.8221.2.camel@cr0>
References: <1351482620-11008-1-git-send-email-amwang@redhat.com>
	 <1351491005.7394.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12171 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113Ab2J2Gtd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 02:49:33 -0400
In-Reply-To: <1351491005.7394.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-29 at 07:10 +0100, Eric Dumazet wrote:
> > -		dst_release(&rt->dst);
> > +		if (rt)
> > +			dst_release(&rt->dst);
> >  	}
> >  
> 
> dst_release() is like kfree(), it accepts a NULL argument.
> 

'rt->dst' already dereferences 'rt', no matter dst_release() accepts
NULL or not.
