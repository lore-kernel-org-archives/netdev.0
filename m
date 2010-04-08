From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] xfrm: add x86 CONFIG_COMPAT support
Date: Wed, 07 Apr 2010 22:00:12 -0700 (PDT)
Message-ID: <20100407.220012.86972786.davem@davemloft.net>
References: <1270506431-25578-1-git-send-email-fw@strlen.de>
	<20100407.030850.04450543.davem@davemloft.net>
	<20100407133528.GD22518@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36548
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751004Ab0DHFAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 01:00:09 -0400
In-Reply-To: <20100407133528.GD22518@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 7 Apr 2010 15:35:28 +0200

> But whats really bothering me is the number of sys_compat_* functions
> needed to make all possibilities work;. e.g. to make (unmodified)
> strongwan work, sys_compat_write and sys_compat_sendto are needed.

Thank the BSD socket API designer(s) for adding N different ways to
essentially say the same thing instead of just having sendmsg/recvmsg
and saying "if you don't want to specify X, just pass in NULL" or
whatever. :-)

Because that's all that sendto() is, it's a sendmsg() without
an arg or two.  But in the end the kernel internally has to
come up with pretend arguments for all of this stuff anyways
since the protocols end up having to accomodate all of
the sendmsg() cases anyways.

And it's not all that bad, we just need the numerous compat entry
points to set the compat flag bit, the rest of the implementation is
going to be %100 shared code.

And once it's there, we can use it for other similar cases, not
just xfrm netlink.
