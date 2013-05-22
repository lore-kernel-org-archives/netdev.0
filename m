From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Wed, 22 May 2013 12:26:12 -0700
Message-ID: <1369250772.3301.349.camel@edumazet-glaptop>
References: <1368068665.13473.81.camel@edumazet-glaptop>
	 <1369244868.3301.343.camel@edumazet-glaptop>
	 <1369246816.2143.84.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Patrick McHardy <kaber@trash.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33703 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755190Ab3EVT0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 15:26:14 -0400
In-Reply-To: <1369246816.2143.84.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 11:20 -0700, Joe Perches wrote:
> On Wed, 2013-05-22 at 10:47 -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > nf_conntrack_lock is a monolithic lock and suffers from huge contention
> > on current generation servers (8 or more core/threads).
> []
> > diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
> []
> > @@ -76,7 +76,8 @@ struct nf_conn {
> >             plus 1 for any connection(s) we are `master' for */
> >  	struct nf_conntrack ct_general;
> >  
> > -	spinlock_t lock;
> > +	spinlock_t	lock;
> > +	u16		cpu;
> 
> trivia:
> 
> What's the real value in not using int here?
> 

On some machines, sizeof(spinlock_t) is 2

So this addition doesn't increase size of the structure, as I fill a
hole.

Thats the case on x86 when NR_CPUS < 256
