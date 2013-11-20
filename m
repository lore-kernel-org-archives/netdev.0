From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] cipso: simplify cipso_v4_translate() when !CONFIG_NETLABEL
Date: Wed, 20 Nov 2013 14:59:33 -0500
Message-ID: <2049996.Ospk96ghpo@sifl>
References: <20131120192548.5616.74526.stgit@localhost> <4007061.3MtKnenLV1@sifl> <20131120.145511.1303114952026497883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754843Ab3KTT7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 14:59:39 -0500
In-Reply-To: <20131120.145511.1303114952026497883.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, November 20, 2013 02:55:11 PM David Miller wrote:
> From: Paul Moore <pmoore@redhat.com>
> Date: Wed, 20 Nov 2013 14:45:19 -0500
> 
> > Looking at the original conditional:
> >  if ((tag_len == 0) || (opt[opt_iter + 1] > (opt_len - opt_iter))
> > 
> > ... and the replacement:
> >  if ((tag_len == 0) || (tag_len > (opt_len - opt_iter)))
> > 
> > ... we notice that "(opt[opt_iter + 1] > (opt_len - opt_iter))" has been
> > replaced with "(tag_len > (opt_len - opt_iter))", substituting 'tag_len'
> > for 'opt[opt_iter + 1]'.  This is acceptable because the the first
> > statement in> 
> > the for loop is:
> >  tag_len = opt[opt_iter + 1]
> > 
> > ... which matches the substitution in the conditional.  I'm not sure how
> > much more explicit I can be about this change, it is really pretty minor.
>
> Then, two things:
> 
> 1) This is a cleanup, and therefore not suitable for submission right now
>    because the net-next tree is closed.

I wasn't expecting it to go into the current merge window, I was just sending 
it out now so you'd have it for when things started moving again.  Think of it 
as spreading the pain out a bit.
 
> 2) A more suitable commit log message would have been "Don't needlessly
>    recompute 'opt[opt_iter + 1]' as we already have it stored in tag_len".
> 
>    Then anyone who reads this commit message can say "yes, obviously this
>    is a correct change and matches what the patch is doing"

Fair enough.  Do you want a resubmit with your wording once the merge window 
closes?

> Thanks.

-- 
paul moore
security and virtualization @ redhat
