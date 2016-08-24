From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH ipsec-next 8/8] xfrm: policy: convert policy_lock to
 spinlock
Date: Wed, 24 Aug 2016 13:30:43 +0200
Message-ID: <20160824113043.GA7905@breakpoint.cc>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
 <1470921479-25592-9-git-send-email-fw@strlen.de>
 <20160824112847.GP3735@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45434 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753057AbcHXLas (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 07:30:48 -0400
Content-Disposition: inline
In-Reply-To: <20160824112847.GP3735@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steffen Klassert <steffen.klassert@secunet.com> wrote:
> On Thu, Aug 11, 2016 at 03:17:59PM +0200, Florian Westphal wrote:
> > @@ -972,14 +972,14 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
> >  			if (pol->type != type)
> >  				continue;
> >  			__xfrm_policy_unlink(pol, dir);
> > -			write_unlock_bh(&net->xfrm.xfrm_policy_lock);
> > +			spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
> >  			cnt++;
> >  
> >  			xfrm_audit_policy_delete(pol, 1, task_valid);
> >  
> >  			xfrm_policy_kill(pol);
> >  
> > -			write_lock_bh(&net->xfrm.xfrm_policy_lock);
> > +			spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
> 
> I've just noticed that you accidentally replaced write_lock_bh
> with spin_unlock_bh here.

Sorry about this, thanks for fixing this up.
