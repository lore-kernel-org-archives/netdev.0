From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: [PATCH 1/1 V3] bridge: fix br_multicast_ipv6_rcv for paged skbs
Date: Mon, 03 Jan 2011 11:04:18 +0100
Message-ID: <1294049058.4165.3.camel@jlt3.sipsolutions.net>
References: <1293999538-9298-1-git-send-email-tomas.winkler@intel.com>
	 <1294047254.4165.1.camel@jlt3.sipsolutions.net>
	 <6F5C1D715B2DA5498A628E6B9C124F04019BF9E404@hasmsx504.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Winkler, Tomas" <tomas.winkler@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:60264 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab1ACKEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 05:04:22 -0500
In-Reply-To: <6F5C1D715B2DA5498A628E6B9C124F04019BF9E404@hasmsx504.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-03 at 11:43 +0200, Winkler, Tomas wrote:

> > > -		struct mld_msg *mld = (struct mld_msg *)icmp6h;
> > > +		struct mld_msg *mld;
> > > +		if (!pskb_may_pull(skb2, sizeof(*mld))) {
> > > +			err = -EINVAL;
> > > +			goto out;
> > > +		}
> > > +		mld = (struct mld_msg *)icmp6h;
> > 
> > This (and the second instance) is incorrect afaict -- the pointer
> > "icmp6h" should be reloaded after the pskb_may_pull(), no?
> 
> mld_msg is bigger than icmp6h by sizeof(in6_addr) so we have to try pull again a bigger chunk. 

Right, I know, the pskb_may_pull() is needed, but I believe you need to
re-calculate icmp6h here.

> > Also, the "out_nopush" thing is pointless since the push is completely
> > unnecessary as "skb2 != skb" is always true.
> 
> You are right if skb_clone doesn't return the same pointer then yes.
> Shame, but I'm not a sbk expert. I'm diving into it now.

I'm pretty sure it's guaranteed to return a new pointer.

johannes

