From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/10] MLSXFRM: Add security context to acquire messag
 es using PF_KEY
Date: Thu, 13 Jul 2006 22:30:09 -0700 (PDT)
Message-ID: <20060713.223009.68157153.davem@davemloft.net>
References: <36282A1733C57546BE392885C06185920138E0F0@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12469
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964796AbWGNFaF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 01:30:05 -0400
To: vyekkirala@TrustedCS.com
In-Reply-To: <36282A1733C57546BE392885C06185920138E0F0@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Date: Thu, 13 Jul 2006 10:54:14 -0400

> > > +static inline void security_xfrm_skb_secid(struct sk_buff 
> > *skb, u32 *secid)
> > > {
> > > -	return security_ops->xfrm_decode_session(skb, fl);
> > > +	BUG_ON(security_ops->xfrm_decode_session(skb, secid, 0));
> > > 
> > 
> > BUG_ON looks wrong here, in that you don't know why the LSM 
> > returned an 
> > error, and why should the box panic at this point at all?
> 
> This hook must not fail when the ckall parameter is set to zero,
> which is what the BUG_ON is asserting. I see I didn't comment
> the hook def in security.h to this effect; will correct this. Thanks.

The real problem is that when debugging is disabled, BUG_ON() is
defined to do nothing, it will not even evaluate the expression once.
So it is not valid to put things with expected side effects in there.

This is the same thing that happens to assert() in userspace if
you define "NDEBUG".
