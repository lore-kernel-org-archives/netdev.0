From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH 7/8] ethtool: Add GGRO and SGRO ops
Date: Sun, 14 Dec 2008 14:00:18 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0812141351560.12712@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20081212053116.GA2927@gondor.apana.org.au>
 <E1LB0d2-0000rq-Dr@gondolin.me.apana.org.au> <1229112677.3051.9.camel@achroite>
 <20081212214835.GD11046@gondor.apana.org.au> <1229121327.3051.69.camel@achroite>
 <20081212224954.GA11636@gondor.apana.org.au>
 <Pine.WNT.4.64.0812141124040.13556@ppwaskie-MOBL2.amr.corp.intel.com>
 <20081214210916.GA26325@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49078 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772AbYLNWAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2008 17:00:45 -0500
In-Reply-To: <20081214210916.GA26325@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Dec 2008, Herbert Xu wrote:

> On Sun, Dec 14, 2008 at 11:36:14AM -0800, Waskiewicz Jr, Peter P wrote:
> >
> > I'm confused then.  You're adding two ethtool entry points with
> > ETHTOOL_GGRO and ETHTOOL_SGRO, adding the callpoints in dev_ethtool with
> > set_gro and get_gro, but how do you manipulate this without adding to the
> > userspace application?  Adding this functionality to the set/get_flags
> > will keep the userspace app from needing a patch to support the new
> > callbacks.
> 
> Huh? Whether you use get_flags or not you still need to patch the
> user-space application so that it knows how to handle
> 
>         ethtool -K eth0 gro on/off
> 
> There is no way around that.
> 
> As I said earlier, I didn't use get_flags/set_flags because of the
> need to depend on RX checksum offload.

Ok, that makes sense.  

> 
> BTW, here is the patch for ethtool to set the GRO flags.

Thanks Herbert.  I was slightly confused when you said you wouldn't need 
to affect the ethtool_ops struct, which you don't.  But my initial read 
didn't think to just pop it into the existing offload ethtool_ops entry 
point after seeing the get/set ops you had in the kernel interface.  I've 
been enlightened now (or my brain has finally slipped into gear).  :-)

> -static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso, int lro)
> +static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
> +                       int gro, int lro)

Would it make better sense to add GRO after LRO?  I suppose it doesn't 
make any difference, but I'm thinking of any possible way to provide ABI 
compatibility.  I don't think it's possible though; just thinking out loud 
here.

Cheers,
-PJ Waskiewicz
