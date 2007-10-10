From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Evict tmp variable from the stack in ip6_evictor
Date: Wed, 10 Oct 2007 16:31:47 -0700 (PDT)
Message-ID: <20071010.163147.84363864.davem@davemloft.net>
References: <470CE38C.2020607@trash.net>
	<470CE724.8030807@openvz.org>
	<470CEA5F.7050508@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58818
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756839AbXJJXbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 19:31:45 -0400
In-Reply-To: <470CEA5F.7050508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 10 Oct 2007 17:06:07 +0200

> Pavel Emelyanov wrote:
> > Patrick McHardy wrote:
> >> Pavel Emelyanov wrote:
> >>> The list_head *tmp is used to help getting the first entry in
> >>> the ip6_frag_lru_list list. There is a simpler way to do it
> >>
> >> The exact same code exists in ip_fragment.c and nf_conntrack_reasm.c,
> >> please also change it there.
> > 
> > Hm, indeed. But I see that the structs frag_queue in reassembly.c, ipq 
> > in ip_fragment.c and nf_ct_frag6_queue in nf code looks VERY similar 
> > and very much of code (like link/unlink or evict) looks the same too.
> > 
> > Maybe it's worth creating something like struct skb_fragment and
> > consolidate all the common stuff into some net/core/lib_frag.c? Or
> > is there some hidden reason for keeping this code splitted?
> 
> I'm not sure if its possible between IPv4 and IPv6, but sharing code
> between IPv6 reassembly and netfilter/ipv6 would be nice.

And besides I think it's an independant change to this tmp
variable removal, so let's just do that first.
