From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH] include/net/genetlink.h: Allow genlmsg_cancel to accept
 a NULL argument
Date: Wed, 2 Feb 2011 06:51:55 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1102020650280.9302@ask.diku.dk>
References: <Pine.LNX.4.64.1101281642080.8546@pc-004.diku.dk>
 <20110201.145410.115936566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paul.moore@hp.com, kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110201.145410.115936566.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Feb 2011, David Miller wrote:

> From: Julia Lawall <julia@diku.dk>
> Date: Fri, 28 Jan 2011 16:43:40 +0100 (CET)
> 
> > nlmsg_cancel can accept NULL as its second argument, so for similarity,
> > this patch extends genlmsg_cancel to be able to accept a NULL second
> > argument as well.
> > 
> > Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> I did a scan of all of the cases where this interface is used, and
> I cannot find a situation where this capability would even be useful.
> 
> The use pattern is always:
> 
> 	hdr = genlmsg_put(skb, ...);
> 	if (!hdr)
> 		goto out;
> 
> 	NLA_PUT_*();
> 	NLA_PUT_*();
> 	....
> 
> 	return genlmsg_end(skb, hdr);
> 
> nla_put_failure:
> 	genlmsg_cancel(skb, hdr);
> out:
> 	return -EWHATEVER;
> 
> Always, hdr will be non-NULL.
> 
> We have to allocate the header first, then put the netlink
> attributes.
> 
> Looking over users of nlmsg_cancel(), the situation seems to
> match identically.
> 
> Therefore, it seems to me that it makes more sense to remove
> the NULL check from nlmsg_cancel() than to add the NULL check
> to genlmsg_cancel().

I saw lots of cases that could be done like this, but were not; they had 
goto nla_put_failure instead.

I will double check.

julia
