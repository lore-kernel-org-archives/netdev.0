From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: [PATCH 1/1 V3] bridge: fix br_multicast_ipv6_rcv for paged skbs
Date: Mon, 03 Jan 2011 11:41:59 +0100
Message-ID: <1294051319.4165.5.camel@jlt3.sipsolutions.net>
References: <1293999538-9298-1-git-send-email-tomas.winkler@intel.com>
	 <1294047254.4165.1.camel@jlt3.sipsolutions.net>
	 <6F5C1D715B2DA5498A628E6B9C124F04019BF9E404@hasmsx504.ger.corp.intel.com>
	 <1294049058.4165.3.camel@jlt3.sipsolutions.net>
	 <6F5C1D715B2DA5498A628E6B9C124F04019BF9E48E@hasmsx504.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Winkler, Tomas" <tomas.winkler@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:47468 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258Ab1ACKmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 05:42:03 -0500
In-Reply-To: <6F5C1D715B2DA5498A628E6B9C124F04019BF9E48E@hasmsx504.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-03 at 12:17 +0200, Winkler, Tomas wrote:

> > > > > -		struct mld_msg *mld = (struct mld_msg *)icmp6h;
> > > > > +		struct mld_msg *mld;
> > > > > +		if (!pskb_may_pull(skb2, sizeof(*mld))) {
> > > > > +			err = -EINVAL;
> > > > > +			goto out;
> > > > > +		}
> > > > > +		mld = (struct mld_msg *)icmp6h;
> > > >
> > > > This (and the second instance) is incorrect afaict -- the pointer
> > > > "icmp6h" should be reloaded after the pskb_may_pull(), no?
> > >
> > > mld_msg is bigger than icmp6h by sizeof(in6_addr) so we have to try pull
> > again a bigger chunk.
> > 
> > Right, I know, the pskb_may_pull() is needed, but I believe you need to
> > re-calculate icmp6h here.
> 
> You are right, it can be moved to new memory buffer.
> 
> Probably something like that will do it:
> 
> if (!pskb_may_pull(skb2, sizeof(*mld))) {
> 	err = -EINVAL;
> 	goto out;
> }
> mld = (struct mld_msg *)skb_transport_header(skb2) 

Yeah, that'll do, although I see more callers of icmp6_hdr() here
instead even for mld stuff (which is an inline though doing just this)

johannes

