From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch 5/7] bonding: replace system timer with work queue
Date: Mon, 26 Mar 2007 23:25:07 -0700
Message-ID: <25159.1174976707@death>
References: <200703270550.l2R5o16M008387@shell0.pdx.osdl.net> <20070326215648.58cb392b.akpm@linux-foundation.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, perex@suse.cz,
	oleg@tv-sign.ru, shemminger@linux-foundation.org,
	Andy Gospodarek <andy@greyhouse.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:51139 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965105AbXC0GZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 02:25:12 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l2R6NEN3007304
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 02:23:14 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2R6PAfT064226
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 00:25:10 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2R6P9Wq010437
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 00:25:10 -0600
In-reply-to: <20070326215648.58cb392b.akpm@linux-foundation.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:

>On Mon, 26 Mar 2007 21:50:01 -0800 akpm@linux-foundation.org wrote:
>
>> Replace system timer with work queue in monitor functions.  The reason for
>> this change is that bonding handlers calls various sleeping functions from
>> the timer handler which is not allowed.  Because we cannot share the main
>> workqueue threads (rtnl_lock is used also in linkwatch_event) - new bond
>> workqueue thread is created.
>
>I have a note here that this patch needs additional work.
>
>I forget what it was, there has since been no followup and hence I shall now
>drop this patch.

	Andy Gospodarek <andy@greyhouse.net> and I have been working off
list to come up with a comprehensive scheme to resolve the various
locking problems in bonding all at once, rather than piecemeal.
Currently, we believe we've identified all of the problem areas, have
worked up a set of locking rules, and are now hashing out an
implementation that (hopefully) doesn't suck.

	The patch referenced above is more or less a functional subset
of the work we're doing, in that we'll also be moving the timers to
workqueues.

	Andy, anything to add?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
