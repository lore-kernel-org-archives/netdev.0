From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH RESEND] sctp: fix incorrect overflow check on autoclose
Date: Tue, 13 Dec 2011 17:15:28 -0500
Message-ID: <4EE7CE80.9050307@hp.com>
References: <1323393883-3759-1-git-send-email-xi.wang@gmail.com> <4EE2478B.5010409@hp.com> <8EEC521A-CA38-4CE9-BCFD-BA6FC9A85D18@gmail.com> <4EE67DC6.3000500@hp.com> <702540E4-9FD3-4B71-B53A-FE5D4323A898@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:9936 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789Ab1LMWPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 17:15:36 -0500
In-Reply-To: <702540E4-9FD3-4B71-B53A-FE5D4323A898@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2011 05:00 PM, Xi Wang wrote:
> On Dec 12, 2011, at 5:18 PM, Vladislav Yasevich wrote:
>> Hm..  this is a bit strange.  This makes it so that on 32 bit platforms
>> we have one upper bound for autoclose and on 64 we have another even though
>> the type is platform dependent.  This could be considered a regression by
>> applications.
> 
> Either looks good to me.  Timeout limit is essentially different on 32/64
> platforms.

I don't think it really should be different.  Notice that our rto values
remain consistent.  I really thing that this should be consistent from
the user's point of view.

> 
> Another (probably uglier) option is to limit the value on 32-bit platform
> only, like sock_setsockopt() in net/core/sock.c.
> 
> #if (BITS_PER_LONG == 32)
> 	if (sp->autoclose > MAX_SCHEDULE_TIMEOUT / HZ)
> 		sp->autoclose = MAX_SCHEDULE_TIMEOUT / HZ;
> #endif

I agree, this is ugly.  It might make more sense to define a max autoclose
value and expose it through /sys.  That way the values remains consistent.

-vlad

> 
>> In addition this would result in confusion to user since the values
>> between setsockopt() and getsockopt() for autoclose would be different.
> 
> Are you suggesting to reject the value and return -EINVAL, rather than
> silently limiting the autoclose value?
> 
> - xi
> 
