From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 3/7] ipv6: improve ipv6_find_hdr() to skip
 empty routing headers
Date: Mon, 3 Dec 2012 19:06:11 +0100
Message-ID: <20121203180611.GA20305@1984>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
 <1354214149-33651-4-git-send-email-jesse@nicira.com>
 <20121203140458.GA1596@1984>
 <CAEP_g=-D6f-O1F0B4+xLKfZnY_LjFiHF-UaXD4zVUYctGG3-Ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dev@openvswitch.org, Ansis Atteka <aatteka@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40124 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210Ab2LCSGR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 13:06:17 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=-D6f-O1F0B4+xLKfZnY_LjFiHF-UaXD4zVUYctGG3-Ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2012 at 09:28:55AM -0800, Jesse Gross wrote:
> On Mon, Dec 3, 2012 at 6:04 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > On Thu, Nov 29, 2012 at 10:35:45AM -0800, Jesse Gross wrote:
> >> @@ -159,9 +162,10 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
> >>       }
> >>       len = skb->len - start;
> >>
> >> -     while (nexthdr != target) {
> >
> > If the offset is set as parameter via ipv6_find_hdr, we now are always
> > entering the loop even if we found the target header we're looking
> > for, before that didn't happen.
> >
> > Something seems wrong here to me.
> 
> If the target header is a routing header then you might still need to
> continue searching because the first one that you see could be empty.

OK, but if it's not a routing header what we're searching for (which
seems to be the case of netfilter/IPVS) we waste way more cycles on
copying the IPv6 header again and with way more things that are
completely useless.
