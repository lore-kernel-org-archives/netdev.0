From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH 2/2] xfrm: force a garbage collection after deleting a policy
Date: Thu, 23 May 2013 16:26 -0400
Message-ID: <3745713.ydSpZNh4x7@sifl>
References: <20130523185659.19212.56853.stgit@localhost> <20130523190746.19212.6027.stgit@localhost> <519E6E36.4070600@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, omoris@redhat.com,
	pwouters@redhat.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42876 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759207Ab3EWU0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 16:26:07 -0400
In-Reply-To: <519E6E36.4070600@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, May 23, 2013 11:29:58 PM Sergei Shtylyov wrote:
> Hello.
> 
> On 05/23/2013 11:07 PM, Paul Moore wrote:
> > In some cases after deleting a policy from the SPD the policy would
> > remain in the dst/flow/route cache for an extended period of time
> > which caused problems for SELinux as its dynamic network access
> > controls key off of the number of XFRM policy and state entries.
> > This patch corrects this problem by forcing a XFRM garbage collection
> > whenever a policy is sucessfully removed.
> > 
> > Reported-by: Ondrej Moris <omoris@redhat.com>
> > Signed-off-by: Paul Moore <pmoore@redhat.com>
> > ---
> > 
> >   include/net/xfrm.h     |    6 ++++++
> >   net/key/af_key.c       |    4 ++++
> >   net/xfrm/xfrm_policy.c |    3 ++-
> >   net/xfrm/xfrm_user.c   |    2 ++
> >   4 files changed, 14 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> > index ae16531..918e4cd 100644
> > --- a/include/net/xfrm.h
> > +++ b/include/net/xfrm.h
> 
> [...]
> 
> > @@ -1194,6 +1196,10 @@ static inline int xfrm6_policy_check_reverse(struct
> > sock *sk, int dir,> 
> >   {
> >   
> >   	return 1;
> >   
> >   }
> > 
> > +static inline void xfrm_garbage_collect(struct net *net)
> > +{
> > +	return;
> 
>      Not needed.
> 
> > +}

True, I added it for the sake of completeness, but I'll go ahead and remove 
it.

-- 
paul moore
security and virtualization @ redhat
