From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 04 May 2006 16:11:48 -0700 (PDT)
Message-ID: <20060504.161148.44973535.davem@davemloft.net>
References: <200604261147.34221.kelly@au.ibm.com>
	<20060426.005949.125174303.davem@davemloft.net>
	<200605041728.27131.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54404
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751524AbWEDXL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 19:11:58 -0400
To: kelly@au1.ibm.com
In-Reply-To: <200605041728.27131.kelly@au.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kelly Daly <kelly@au1.ibm.com>
Date: Thu, 4 May 2006 17:28:27 +1000

> On Wednesday 26 April 2006 17:59, David S. Miller wrote:
> > Next, you can't even begin to work on the protocol channels before you
> > do one very important piece of work.  Integration of all of the ipv4
> > and ipv6 protocol hash tables into a central code, it's a total
> > prerequisite.  Then you modify things to use a generic
> > inet_{,listen_}lookup() or inet6_{,listen_}lookup() that takes a
> > protocol number as well as saddr/daddr/sport/dport and searches
> > from a central table.
> 
> Back here again  ;)
> 
> Is this on the right track (see patch below)?

It is on the right track.

I very much fear abuse of the inet_hashes[] array.  So I'd rather
hide it behind a programmatic interface, something like:

extern struct sock *inet_lookup_proto(u16 protocol, u32 saddr, u16 sport,
				      u32 daddr, u16 dport, int ifindex);

and export that from inet_hashtables.c

Then you have registry and unregistry functions in inet_hashtables.c
that setup the static inet_hashes[] array.  So TCP would go:

	inet_hash_register(IPPROTO_TCP, &tcp_hashinfo);

instead of the direct assignment to inet_hashes[] it makes right
now in your patch.

Thanks!
