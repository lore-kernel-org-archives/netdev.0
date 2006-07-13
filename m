From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 08/10] MLSXFRM: Add security context to acquire messag
	es using PF_KEY
Date: Thu, 13 Jul 2006 10:54:14 -0400
Message-ID: <36282A1733C57546BE392885C06185920138E0F0@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:30619 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1030199AbWGMOyh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 10:54:37 -0400
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +static inline void security_xfrm_skb_secid(struct sk_buff 
> *skb, u32 *secid)
> > {
> > -	return security_ops->xfrm_decode_session(skb, fl);
> > +	BUG_ON(security_ops->xfrm_decode_session(skb, secid, 0));
> > 
> 
> BUG_ON looks wrong here, in that you don't know why the LSM 
> returned an 
> error, and why should the box panic at this point at all?

This hook must not fail when the ckall parameter is set to zero,
which is what the BUG_ON is asserting. I see I didn't comment
the hook def in security.h to this effect; will correct this. Thanks.
