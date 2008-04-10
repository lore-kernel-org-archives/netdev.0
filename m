From: vincent-perrier <vincent-perrier@club-internet.fr>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Fri, 11 Apr 2008 01:51:03 +0200
Message-ID: <1207871463.13528.4.camel@localhost>
References: <1207869029.19683.13.camel@localhost>
	 <20080410.161453.52032573.davem@davemloft.net>
	 <1207870334.13150.11.camel@localhost>
	 <20080410.164106.192045155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, tilman@imap.cc, lkml@rtr.ca,
	yoshfuji@linux-ipv6.org, jeff@garzik.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758026AbYDJXvX@vger.kernel.org>
In-Reply-To: <20080410.164106.192045155.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks to you, and also to Jesper for the "git bisect" explanation,
you have powerfull tools, it is all for the best, millions of users
are relying on you!

On Thu, 2008-04-10 at 16:41 -0700, David Miller wrote:
> From: vincent-perrier <vincent-perrier@club-internet.fr>
> Date: Fri, 11 Apr 2008 01:32:14 +0200
> 
> [ Please use netdev@vger.kernel.org so that this discussion
>   reaches the networking develops. ]
> 
> > Even if the patch is not good, the line dst_free(&rt->u.dst); 
> > when rt is still in tree leads to a crash, but when you do not
> > do the dst_free, when rt is in tree, then it may have hidden 
> > other bugs, but at least I can keep working.
> > 
> > 
> > I never said my patch was good, but it does the minimum to avoid my bug:
> > 
> > 
> >                 if (fn->leaf == NULL) {
> >                         bug_8895_clownix_provisional_workaround = 1;
> >                         fn->leaf = rt;
> >                         atomic_inc(&rt->rt6i_ref);
> >                 }
> > ...
> > 
> > ip6_fib.c, line 796:
> > 
> >                 if (!bug_8895_clownix_provisional_workaround)
> >                         dst_free(&rt->u.dst);
> > 
> > That way at least it does not crash.
> > 
> > I cannot provide more than the line and the reason for the crash, I am
> > one of the numerous brainless users.
> 
> Now that the discussion has reached the mailing list, it won't die in
> bugzilla like most such bugs do, and very likely will get fixed
> quickly as a result.
> 
> Thank you.
> &#0;
> 
