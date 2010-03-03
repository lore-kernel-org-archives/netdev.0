From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH V2 2/7] tcp: use limited socket backlog
Date: Wed, 03 Mar 2010 17:06:02 +0800
Message-ID: <1267607162.2370.169.camel@debian>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
	 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
	 <1267606433.2997.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:12282 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751927Ab0CCJER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 04:04:17 -0500
In-Reply-To: <1267606433.2997.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-03 at 16:53 +0800, Eric Dumazet wrote:
> > @@ -1682,8 +1682,10 @@ process:
> >                       if (!tcp_prequeue(sk, skb))
> >                               ret = tcp_v4_do_rcv(sk, skb);
> >               }
> > -     } else
> > -             sk_add_backlog(sk, skb);
> > +     } else if (sk_add_backlog_limited(sk, skb)) {
> > +             bh_unlock_sock(sk);
> > +             goto discard_and_relse;
> > +     }
> >       bh_unlock_sock(sk);
> >  
> >       sock_put(sk);
> 
> So no counter is incremented to reflect this loss, sk->sk_drops (local
> counter) or SNMP ? 

I simply follow how the code is originally written. As you can see,
tcp_v4_do_rcv() doesn't always do so. And in the backlog queuing place,
we don't even bother to check.

Thanks,
-yi

