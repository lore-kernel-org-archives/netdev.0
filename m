From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [NETNS] Oops in register_pernet_operations() with CONFIG_NET_NS=n
Date: Thu, 25 Oct 2007 09:03:37 -0600
Message-ID: <m1bqan6xti.fsf@ebiederm.dsl.xmission.com>
References: <47209317.8000802@bull.net> <4720A181.3060003@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	Pavel Emelianov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:44034 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761561AbXJYPFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 11:05:25 -0400
In-Reply-To: <4720A181.3060003@sw.ru> (Denis V. Lunev's message of "Thu, 25
	Oct 2007 18:00:33 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Denis V. Lunev" <den@sw.ru> writes:

> The patch attached should help. The idea is simple. The "init" should be
> called only once without NETNS. Period. No need for any lists.
>
> I'll resend it to Dave after the ACK.

First in the case of the code that is currently merged none of 
the __net_init __net_exit or __net_initdata can be modular, so for
2.6.24 there is no fix needed. Yeah.

Second the whole concept of concept pernet_operations being __init
doesn't work when you have modular code that calls unregister_pernet_subsys().
Because unregister calls the exit method from the pernet_operations
structure.  So the patch doesn't even begin to address the real
issue.

Third from my perspective CONFIG_NET_NS is a temporary measure
designed to last only until we have enough implementation experience 
so that we can feel comfortable removing the experimental status of
the network namespace work.  It was not my intention for it to be a
space saving measure.  So I think it is silly to go marking up the
patches in development with __net_initdata etc.

At least so far I think __net_initdata is a totally bogus concept
and I'm not certain about the other two. 

Eric
