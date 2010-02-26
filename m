From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [RFC PATCH] accounting for socket backlog
Date: Fri, 26 Feb 2010 10:34:43 +0800
Message-ID: <1267151683.16986.1646.camel@debian>
References: <1267067593.16986.1583.camel@debian>
	 <1267097080.2822.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shi, Alex" <alex.shi@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14926 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934998Ab0BZCdS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 21:33:18 -0500
In-Reply-To: <1267097080.2822.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-25 at 19:24 +0800, Eric Dumazet wrote:
> > @@ -253,6 +253,7 @@ struct sock {
> >       struct {
> >               struct sk_buff *head;
> >               struct sk_buff *tail;
> > +             atomic_t len;
> 
> This adds a hole on 32bit arches.
> 
> I am pretty sure we dont need an atomic here, since we must own a lock
> before manipulating sk_backlog{head,tail,len}.

Good point. bh_lock_sock is always held for backlog operations.

> UDP/IPV6 should be addressed too in your patch.

Will do, this is only a RFC anyway.

> Other questions raised by your discovery :
> - What about other protocols that also use a backlog ?

I don't think protocols with flow/congestion control capability have
such issue. We have tested TCP is immune. Other current backlog users
are dccp, sctp, tipc, x.25 and llc. We didn't test all of them. But
looks like only llc here is possible but unlikely?

> - __release_sock() could run forever with no preemption, even with a
> limit on backlog. 

Yes, but there is no critical impact like memory exhausted for this
case.

Thanks,
-yi

