From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/10] MLSXFRM: Add security context to acquire
 messages using PF_KEY
Date: Thu, 13 Jul 2006 23:04:45 -0700 (PDT)
Message-ID: <20060713.230445.106436593.davem@davemloft.net>
References: <44B56642.6060500@trustedcs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31469
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161271AbWGNGEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 02:04:44 -0400
To: vyekkirala@trustedcs.com
In-Reply-To: <44B56642.6060500@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Date: Wed, 12 Jul 2006 16:14:42 -0500

> This labels the flows that could utilize IPSec xfrms at the points they
> are defined so that IPSec policy and SAs at the right label can be used.
> 
> The following protos are currently not handled, but they should continue
> to be able to use single-labeled IPSec like they currently do.
> 
> ipmr
> ip_gre
> ipip
> igmp
> sit
> sctp
> ip6_tunnel (IPv6 over IPv6 tunnel device)
> decnet
> 
> Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>

This isn't the most beautiful way to handle this, but I cannot
dream up a better way at the current time.

I think the names and arguments of these funcitons could be nicer,
may I suggest:

static inline void security_sk_classify_flow(struct sock *sk, struct flowi *f);
static inline void security_skb_classify_flow(struct sk_buff *skb, struct flowi *f);

These interfaces describe better what is happening, in a way that
doesn't divulge the details of the fact that there is security ID and
it's a 32-bit integer, etc.

With the above interfaces you can change the implementation easily
without having to dork with all the call sites all over again if
something other than a 32-bit integer is ever needed.

The other changes I'm either OK with, or they are outside my scope of
knowledge (the stuff that lives inside of SELINUX).
