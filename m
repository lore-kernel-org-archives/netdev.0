From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH][NETNS] Use list_for_each_entry_continue_reverse in setup_net
Date: Fri, 14 Sep 2007 15:53:21 -0600
Message-ID: <m1bqc429ta.fsf@ebiederm.dsl.xmission.com>
References: <46EA3AB4.7060904@openvz.org> <20070914144938.3ba643a5@oldman>
	<m1lkb92tto.fsf@ebiederm.dsl.xmission.com>
	<20070914220714.3a1e87f8@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:39623 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965AbXINVyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 17:54:20 -0400
In-Reply-To: <20070914220714.3a1e87f8@oldman> (Stephen Hemminger's message of
	"Fri, 14 Sep 2007 22:07:14 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> Could we just make it so dev->init is not allowed to fail? Then it
> can be a void function and the nasty unwind code can go?

Unfortunately we need to allocate memory, and perform other operations
that can fail.  That's the nature of the problem.

So I think not allowing init to fail would be optimizing for the wrong
the case.  Allowing init to fail makes the rest of the code simpler
because we don't have to perform the impossible when the highly
unlikely happens.

The ugly unwind is only about 5 lines of code that never need to
change (except for beautification).  So I don't think the cost
is prohibitive.

Eric


