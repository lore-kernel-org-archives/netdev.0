From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC net-next 9/9] xfrm: add a small xdst pcpu cache
Date: Thu, 29 Jun 2017 15:17:58 +0200
Message-ID: <20170629131758.GE9307@breakpoint.cc>
References: <20170628132652.1275-1-fw@strlen.de>
 <20170628132652.1275-10-fw@strlen.de>
 <AM4PR0501MB194005DDDF772CE960D1E6F5DBD20@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Steffen Klassert <steffen.klassert@secunet.com>
To: Ilan Tayari <ilant@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:40012 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752684AbdF2NTC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 09:19:02 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB194005DDDF772CE960D1E6F5DBD20@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilan Tayari <ilant@mellanox.com> wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> > Subject: [RFC net-next 9/9] xfrm: add a small xdst pcpu cache
> > 
> > retain last used xfrm_dst in a pcpu cache.
> > On next request, reuse this dst if the policies are the same.
> > 
> > UDP tests used 64byte packets, tests ran for one minute each,
> > value is average over ten iterations.
> 
> Hi Florian,
> 
> I want to give this a go with hw-offload and see the impact on performance.
> It may take us a few days to do that.

Sure, take your time, thanks for testing!

> > +void xfrm_policy_dev_unreg(void)
> 
> Maybe name it xfrm_policy_cache_flush() or something similar, and call it from some places where xfrm_garbage_collect() used to be called?
> 
> Such as from xfrm_policy_flush()
> And maybe even from xfrm_flush_sa() as well
> 
> This would allow to unload esp4 and/or esp4_offload (or other algo module) after 'ip x s f' (or the swan equivalent)

Good point.  I did not consider module unload just device removal.
