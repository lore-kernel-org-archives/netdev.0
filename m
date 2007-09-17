From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH][NETNS] Use list_for_each_entry_continue_reverse in setup_net
Date: Sun, 16 Sep 2007 18:06:00 -0600
Message-ID: <m1odg2w3yv.fsf@ebiederm.dsl.xmission.com>
References: <20070914144938.3ba643a5@oldman>
	<m1lkb92tto.fsf@ebiederm.dsl.xmission.com>
	<20070914220714.3a1e87f8@oldman>
	<20070916.164914.15264075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, xemul@openvz.org,
	netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, dlezcano@fr.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:53497 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbXIQAHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 20:07:00 -0400
In-Reply-To: <20070916.164914.15264075.davem@davemloft.net> (David Miller's
	message of "Sun, 16 Sep 2007 16:49:14 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Fri, 14 Sep 2007 22:07:14 +0200
>
>> Could we just make it so dev->init is not allowed to fail? Then it
>> can be a void function and the nasty unwind code can go?
>
> Someone (not me :-) need to do an audit to find all current
> users of this function and determine if they all can live
> without returning errors.
>
> If so, sure let's make the change and simplify things.

I did that audit when I replied to Stephen the first time and I just
redid it to verify myself.  We are calling functions that can fail
from the init function (kmalloc in the most common).  So the
init function can fail.

So short of adding a bunch of BUG_ON's to the kernel to trap those
failure cases we can't remove the backwards list walk.  Especially
since I can initiate this code path as root by calling 
"clone(CLONE_NEWNET...)".

Eric
