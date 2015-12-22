From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: suspicious RCU usage (netlink/rhashtable)
Date: Tue, 22 Dec 2015 16:54:00 -0500
Message-ID: <20151222215400.GA14148@codemonkey.org.uk>
References: <CAEfhGiz1FnghHRpcYUVKhWNV=4yjfU-pAsjynKTgwPctsNQ5Gw@mail.gmail.com>
 <20151222.164225.926367017579760543.davem@davemloft.net>
 <20151222214734.GB13231@codemonkey.org.uk>
 <20151222.165020.297576414018581950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kraigatgoog@gmail.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:58886 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932680AbbLVVyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:54:04 -0500
Content-Disposition: inline
In-Reply-To: <20151222.165020.297576414018581950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 04:50:20PM -0500, David Miller wrote:
 
 > >  > > Simple fix is below.  Though, I don't understand the history of the
 > >  > > multiple locks in this structure to be sure it's correct.  I'll send
 > >  > > it as a formal patch.  Please reject if it's not the right approach.
 > >  > > 
 > >  > > diff --git a/lib/rhashtable.c b/lib/rhashtable.c
 > >  > > index 1c149e9..cc80870 100644
 > >  > > --- a/lib/rhashtable.c
 > >  > > +++ b/lib/rhashtable.c
 > >  > > @@ -516,7 +516,8 @@ int rhashtable_walk_init(struct rhashtable *ht,
 > >  > > struct rhashtable_iter *iter)
 > >  > >                 return -ENOMEM;
 > >  > > 
 > >  > >         spin_lock(&ht->lock);
 > >  > > -       iter->walker->tbl = rht_dereference(ht->tbl, ht);
 > >  > > +       iter->walker->tbl =
 > >  > > +               rcu_dereference_protected(ht->tbl, lockdep_is_held(&ht->lock));
 > >  > >         list_add(&iter->walker->list, &iter->walker->tbl->walkers);
 > >  > >         spin_unlock(&ht->lock);
 > >  > 
 > >  > How can this be the "fix"?  That's exactly what's in the tree.
 > > 
 > > I should have made clear, this is Linus' tree I'm hitting this on,
 > > which matches what Craig posted.
 > 
 > Ok, so this should be fixed in my 'net' tree and I'll send that to Linus
 > soon.

Great, thanks Dave.  Sorry for the fire-alarm :)

	Dave
