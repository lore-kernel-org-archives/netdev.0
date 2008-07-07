From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 0/9] selective (per/namespace) flush of rt_cache
Date: Mon, 07 Jul 2008 03:29:23 -0700
Message-ID: <m1fxqmyol8.fsf@frodo.ebiederm.org>
References: <1215177360.27873.50.camel@iris.sw.ru>
	<20080705.205548.122498335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: den@openvz.org, containers@lists.osdl.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:34993 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbYGGKbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 06:31:49 -0400
In-Reply-To: <20080705.205548.122498335.davem@davemloft.net> (David Miller's
	message of "Sat, 05 Jul 2008 20:55:48 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: "Denis V. Lunev" <den@openvz.org>
> Date: Fri, 04 Jul 2008 17:16:00 +0400
>
>> This series of patches implements selective rt cache flushing to make
>> sure that in one namespace we'll not been able to affect the performance
>> of other from the user space.
>
> Applied and pushed out to net-next-2.6, thanks.
>
> Although I wish patch 9 didn't have to be so ugly. :-/ Also, is it
> really the right thing to do if another namespace's RT cache entries
> are in fact chewing up all the slots in a hash chain?  I think
> the replacement garbage collection algorithm should be namespace
> agnostic.

My VM experience agrees.  The requested flushes from inside the namespace
and for namespace exit really should just flush the routes for that namespace.
However for general route caching and expiry I don't see the point of making
the code per namespace, and my gut feel is that is likely to reduce average
case performance at the cost of better isolation between namespaces.

Denis did I read the patches right and you are making all route cache flushes
per namespace?  Including the periodic expiry?

Eric


