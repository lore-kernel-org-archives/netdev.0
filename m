From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 6610] New: dummy interface broadcast
 destination hardware address is not ff:ff:ff:ff:ff:ff
Date: Thu, 25 May 2006 15:16:02 -0700 (PDT)
Message-ID: <20060525.151602.102574435.davem@davemloft.net>
References: <20060523.165343.104035136.davem@davemloft.net>
	<E1Fihtm-0003dO-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30108
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030471AbWEYWP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 18:15:57 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1Fihtm-0003dO-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 24 May 2006 11:10:54 +1000

> David Miller <davem@davemloft.net> wrote:
> > From: Andrew Morton <akpm@osdl.org>
> > Date: Tue, 23 May 2006 16:31:42 -0700
> > 
> >> >            Summary: dummy interface broadcast destination hardware address
> >> >                     is not ff:ff:ff:ff:ff:ff
> > 
> > Very strange because the dummy device driver calls
> > ether_setup() which does:
> 
> It's caused by the NO_ARP flag.

Perhaps RTN_BROADCAST should take precedence over IFF_NOARP
(but not IFF_LOOPBACK)?  I'm talking about the code in
net/ipv4/arp.c that causes this behavior.

