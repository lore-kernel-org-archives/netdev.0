From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC 00/14] shrink skb cb to 44 bytes
Date: Tue, 3 Mar 2015 12:43:02 +0100
Message-ID: <20150303114302.GE9762@breakpoint.cc>
References: <1425325763.5130.123.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150302.171747.1423128180512348489.davem@davemloft.net>
 <1425355325.5130.157.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150302.230534.2012113468290945834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56906 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752603AbbCCLnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 06:43:07 -0500
Content-Disposition: inline
In-Reply-To: <20150302.230534.2012113468290945834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 02 Mar 2015 20:02:05 -0800
> 
> > About the GRO layout change, reason why 'struct sk_buff *last;' is at
> > the end of struct napi_gro_cb is that this field is not used in fast
> > path.
> 
> Understood.

Moved it back to end, thanks!

> While reviewing this I noticed that the jiffies timestamp in GRO cb
> could really be u32 if we want instead of full "unsigned long".

Made it an u16 at the moment -- then __packed is no longer needed
and it fits in 40 bytes.

> > Note : We could try to use one bit in skb to advertise zero shinfo(skb).
> > 
> > Many skbs have a zeroed shinfo() (but shinfo->dataref == 1) , and
> > dereferencing skb_shinfo adds a cache line miss. 
> > 
> > -> We could avoid memset(shinfo, 0, offsetof(struct skb_shared_info,
> > dataref)) & atomic_set(&shinfo->dataref, 1); 
> > 
> >  in alloc_skb() and friends completely.
> > 
> > Unfortunately this kind of change would be quite invasive...
>
> Right, all these kinds of things touch everything.

Indeed, but thanks for the hint Eric -- I'll investigate.
