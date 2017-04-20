From: Myungho Jung <mhjungk@gmail.com>
Subject: Re: [PATCH] p54: Prevent from dereferencing null pointer when
 releasing SKB
Date: Thu, 20 Apr 2017 16:23:49 -0700
Message-ID: <20170420232349.GA25174@fqdn.specialj.com>
References: <1492712723-9350-1-git-send-email-mhjungk@gmail.com>
 <1492729423.17866.6.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edumazet@google.com, netdev@vger.kernel.org
To: Greg Rose <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32912 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946123AbdDTXXw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 19:23:52 -0400
Received: by mail-io0-f194.google.com with SMTP id k87so22082278ioi.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 16:23:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492729423.17866.6.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 04:03:43PM -0700, Greg Rose wrote:
> On Thu, 2017-04-20 at 11:25 -0700, Myungho Jung wrote:
> > Added NULL check to make __dev_kfree_skb_irq consistent with kfree
> > family of functions.
> > 
> > Link: https://bugzilla.kernel.org/show_bug.cgi?id=195289
> > 
> > Signed-off-by: Myungho Jung <mhjungk@gmail.com>
> 
> Hi,
> 
> I think the patch is fine but I'm confused by the subject.  You mention
> p54 driver but the change is in dev.c.  I know the bugzilla references
> the p54 but that's not where the change is.
> 
> Seems odd to me.
> 
> - Greg
> 
> > ---
> >  net/core/dev.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 7869ae3..22be2a6 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -2450,6 +2450,9 @@ void __dev_kfree_skb_irq(struct sk_buff *skb, enum skb_free_reason reason)
> >  {
> >  	unsigned long flags;
> >  
> > +	if (unlikely(!skb))
> > +		return;
> > +
> >  	if (likely(atomic_read(&skb->users) == 1)) {
> >  		smp_rmb();
> >  		atomic_set(&skb->users, 0);
> 
> 
> 

Hi Greg,

Thank you for checking my patch. I missed that I moved change from p54
to net/dev. Do I need to resubmit patch v2 to modify subject?

Thanks,
Myungho
