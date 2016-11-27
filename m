From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: Large performance regression with 6in4 tunnel (sit)
Date: Sun, 27 Nov 2016 13:02:29 +1100
Message-ID: <20161127130229.4c88cc2c@canb.auug.org.au>
References: <20161125120947.142c3af5@canb.auug.org.au>
        <cf2fff0a-7d41-1416-0056-3718ea50a5bd@gmx.com>
        <20161125134520.68ca0969@canb.auug.org.au>
        <a4a7b888-04d1-55ce-28de-cc15f01a15fc@gmx.com>
        <20161127115441.7654a4e0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eli Cooper <elicooper@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:42269 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752236AbcK0CCf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 26 Nov 2016 21:02:35 -0500
In-Reply-To: <20161127115441.7654a4e0@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eli,

On Sun, 27 Nov 2016 11:54:41 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> On Fri, 25 Nov 2016 14:05:04 +0800 Eli Cooper <elicooper@gmx.com> wrote:
> >
> > I think this is similar to the bug I fixed in commit ae148b085876
> > ("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()").
> > 
> > I can reproduce a similar problem by applying xfrm to sit traffic.
> > TSO/GSO packets are dropped when IPSec is enabled, and IPv6 throughput
> > drops to 10s of Kbps. I am not sure if this is the same issue you
> > experienced, but I wrote a patch that fixed at least the issue I had.
> > 
> > Could you test the patch I sent to the mailing list just now?  
> 
> Thanks for the patch!
> 
> Its a bit tricky to test since the problem only occurs in a production
> machine (I tried reproducing in a VM, but the problem did not occur),
> but I will try to just rebuild the sit module and see if I can insert
> the modified one.

OK, I tried your patch and unfortunately, it doesn't seem to have
worked ... I still get the large packets dropped and resent smaller.

-- 
Cheers,
Stephen Rothwell
