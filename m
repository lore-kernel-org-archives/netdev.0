From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Xen-devel] kernel BUG at net/core/dev.c:1133!
Date: Fri, 07 Jul 2006 22:06:08 +0200
Message-ID: <44AEBEB0.8020704@trash.net>
References: <E1FyrUg-0003FA-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Petersson, Mats" <Mats.Petersson@amd.com>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:25568 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932306AbWGGUGK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 16:06:10 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FyrUg-0003FA-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Petersson, Mats <Mats.Petersson@amd.com> wrote:
> 
>>Looks like the GSO is involved?
> 
> 
> It's certainly what crashed your machine :) It's probably not the
> guilty party though.  Someone is passing through a TSO packet with
> checksum set to something other than CHECKSUM_HW.
> 
> I bet it's netfilter and we just never noticed before because real
> NICS would simply corrupt the checksum silently.
> 
> Could you confirm that you have netfilter rules (in particular NAT
> rules) and that this goes away if you flush all your netfilter tables?
> 
> Patrick, do we really have to zap the checksum on outbound NAT? Could
> we update it instead?

Are you refering to this code in ip_nat_fn()?

        /* If we had a hardware checksum before, it's now invalid */
        if ((*pskb)->ip_summed == CHECKSUM_HW)
                if (skb_checksum_help(*pskb, (out == NULL)))
                        return NF_DROP;

Doing incremental updates should work fine. This is something
I wanted to take care of at some point, but didn't get to it
yet.

