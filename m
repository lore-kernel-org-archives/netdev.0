From: James Morris <jmorris@namei.org>
Subject: RE: [PATCH 08/10] MLSXFRM: Add security context to acquire messag
 es using PF_KEY
Date: Thu, 13 Jul 2006 11:18:32 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607131115130.6169@d.namei>
References: <36282A1733C57546BE392885C06185920138E0F0@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:56525 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030228AbWGMPSe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 11:18:34 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C06185920138E0F0@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Jul 2006, Venkat Yekkirala wrote:

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

I'd suggest assigning the return value to a variable and asserting that, 
in case defines BUG_ON to nothing and the function won't be called.  Not 
sure what kernel policy is on this (ISTR people used to worry about it), 
but it's better not to take uncecessary chances.


- James
-- 
James Morris
<jmorris@namei.org>
