From: Julian Anastasov <ja@ssi.bg>
Subject: Re: what's causing "ip_rt_bug"?
Date: Tue, 28 Jun 2011 12:05:37 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1106281156180.2233@ja.ssi.bg>
References: <alpine.LFD.2.00.1106182036001.1425@ja.ssi.bg> <20110627.205544.111681152997205782.davem@davemloft.net> <alpine.LFD.2.00.1106281029490.1880@ja.ssi.bg> <20110628.014117.92807428115239742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mangoo@wpkg.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bazsi@balabit.hu, hidden@balabit.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:45986 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756692Ab1F1JCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 05:02:41 -0400
In-Reply-To: <20110628.014117.92807428115239742.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 28 Jun 2011, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Tue, 28 Jun 2011 11:13:25 +0300 (EEST)
> 
> > On Mon, 27 Jun 2011, David Miller wrote:
> > 
> >> TPROXY has special code to make sure that time-wait sockets
> >> are not assigned to skb->sk, as explained in commit
> >> d503b30bd648b3cb4e5f50b65d27e389960cc6d9, that would cause
> >> all kinds of crashes in nfnetlink_log etc.
> >> 
> >> Therefore we would see skb->sk==NULL at ip_route_me_harder()
> >> in that case.
> > 
> > 	Aha, after this clarification other changes should not
> > be needed.
> 
> By this do you mean that you think your patch in this thread
> is completely sufficient?

	Yes. My worry was for the skb->sk != NULL not being
handled by inet_sk_flowi_flags for TW sockets. But it seems
it is not needed, so the patch in this form should be ok.

Regards

--
Julian Anastasov <ja@ssi.bg>
