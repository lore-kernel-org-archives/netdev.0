From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: change spinlocks and remove timers in favor of workqueues
Date: Wed, 6 Dec 2006 21:01:17 -0500
Message-ID: <bdfc5d6e0612061801wc276619l3c4b6d498ca4e8fd@mail.gmail.com>
References: <20061130162322.GA8772@gospo.rdu.redhat.com>
	 <200611301938.kAUJchgv020451@death.nxdomain.ibm.com>
	 <bdfc5d6e0611301215o3e3e0c73wb22156b57ba7ed0f@mail.gmail.com>
	 <200612050049.kB50nwgv023439@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:8549 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937950AbWLGCBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 21:01:18 -0500
Received: by ug-out-1314.google.com with SMTP id 44so331534uga
        for <netdev@vger.kernel.org>; Wed, 06 Dec 2006 18:01:17 -0800 (PST)
To: "Jay Vosburgh" <fubar@us.ibm.com>
In-Reply-To: <200612050049.kB50nwgv023439@death.nxdomain.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/4/06, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> [...]
> >>         Let me see if I can dust off the extensive patch that does
> >> change the locking model; I'll see if I can bring it up to the current
> >> git and post it.
> >>
> >
> >It would seem ideal if we could combine the two into one big patch.
>
>         Appended is my working development patch for rearranging a bunch
> of stuff in bonding.  This is a work in progress, and is not likely to
> be very stable.  This largely reimplements the entire link monitor
> scheme, along with associated locking changes.  It's not split into
> functional pieces, and is just a big kitchen sink blob at the moment.
> It's still very experimental.

Jay,

Thanks for sending it.  I've finally got some time to digest it.  I
didn't get a chance to test it, but I did have a chance to take a look
at it in detail.

I certainly agree with the design points you laid out in your
description.  I like the fact that you've restructured a lot of the
code and moved the monitoring to a common place.  It is also nice to
have it in one spot so you can report link status and bond membership.
 I don't think the bh-locking is necessary since the workqueues
eliminate the possibility that you will be preempted by the bonding
driver -- I dropped them all from my patch.

Overall this seems like a good way to go, but it [obviously] seems
like it would be good to work towards this functionality rather than
simply dumping this huge blob all at once.  I would like to use a
smaller patch to switch to workqueues (my patch or a partial of yours
-- it makes no difference to me) as a start with the intent to let
that soak-in for a while and follow it with chunks that will
eventually get the entire driver closer to the functionality that your
big patch has.

Thoughts?

-andy
