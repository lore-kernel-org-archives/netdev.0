From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Thu, 13 Apr 2017 11:38:10 -0400 (EDT)
Message-ID: <20170413.113810.703136630867928001.davem@davemloft.net>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
        <20170413042036.GA46229@ast-mbp.thefacebook.com>
        <1492063856.19193.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60554 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751423AbdDMPiM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 11:38:12 -0400
In-Reply-To: <1492063856.19193.4.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 13 Apr 2017 08:10:56 +0200

> On Wed, 2017-04-12 at 21:20 -0700, Alexei Starovoitov wrote:
> 
>> > +	if (skb_linearize(skb))
>> > +		goto do_drop;
>> 
>> when we discussed supporting jumbo frames in XDP, the idea
>> was that the program would need to look at first 3+k bytes only
>> and the rest of the packet will be in non-contiguous pages.
>> If we do that, it means that XDP program would have to assume
>> that the packet is more than [data, data_end] and this range
>> only covers linear part.
>> If that's the future, we don't need to linearize the skb here
>> and can let the program access headlen only.
> 
> I'm not sure how you think that would work - at least with our (wifi)
> driver, the headlen should be maybe ETH_HLEN or so at this point. We'd
> let the program know that it can only look at so much, but then the
> program can't do anything at all with those frames. At some point then
> we go back to bpf_skb_load_bytes() being necessary in one form or
> another, no?

Agreed, this is completely unusable.  Some wired ethernet drivers do the
same exact thing.
