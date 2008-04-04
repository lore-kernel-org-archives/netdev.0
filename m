From: Paul Moore <paul.moore@hp.com>
Subject: Re: speaking of stacks
Date: Fri, 4 Apr 2008 08:32:33 -0400
Message-ID: <200804040832.33785.paul.moore@hp.com>
References: <1206969356.4424.120.camel@localhost> <20080403.141815.218859276.davem@davemloft.net> <1207311852.4402.63.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	joern@lazybastard.org, herbert@gondor.apana.org.au,
	James Morris <jmorris@namei.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:33095 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351AbYDDMch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 08:32:37 -0400
In-Reply-To: <1207311852.4402.63.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 April 2008 8:24:12 am jamal wrote:
> On Thu, 2008-03-04 at 14:18 -0700, David Miller wrote:
> > This whole song and dance here is for SELINUX to set only
> > the policy->security, so that we can pass that back down
> > into the subsequent xfrm_policy_bysel_ctx().
> >
> > The thing to do is to rearrange these security layer hooks
> > so that they take a "struct xfrm_sec_ctx **" instead of
> > a full policy pointer.
> >
> > Then the code would look like:
> >
> > 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
> > 		struct xfrm_sec_ctx *ctx;
> >
> > 		err = verify_sec_ctx_len(attrs);
> > 		if (err)
> > 			return err;
> >
> > 		if (rt) {
> > 			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
> >
> > 			if ((err = security_xfrm_policy_alloc(&ctx, uctx)))
> > 				return err;
> > 		}
> > 		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, ctx,
> > 					   delete, &err);
> > 		security_xfrm_policy_free(ctx);
> >
> > And thus the xfrm_policy wouldn't need to be on the stack
> > any longer.
>
> Yes, that would be cleaner than what i did; i will give the
> opportunity to the SELinux folks to take a first crack at it with the
> above approach.
>
> CCing some of the SElinux folks.
> Thanks Dave.

Sorry, I've been stuck under a rock for about the past month. Unless 
somebody is really anxious to do this I'll see if I can whip up an RFC 
patch and get it out either today or early next week.

-- 
paul moore
linux @ hp
