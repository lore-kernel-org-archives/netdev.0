From: Joe Perches <joe@perches.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 13:34:35 -0700
Message-ID: <1250195675.28285.128.camel@Joe-Laptop.home>
References: <1250091560.6641.48.camel@fnki-nb00130>
	 <4A836D6D.1040400@hp.com> <1250174390.6641.89.camel@fnki-nb00130>
	 <4A843EF7.4010700@hp.com> <1250187034.28285.93.camel@Joe-Laptop.home>
	 <4A847669.7050508@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jens Rosenboom <jens@mcbone.net>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:4224 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932474AbZHMUek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 16:34:40 -0400
In-Reply-To: <4A847669.7050508@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-13 at 16:24 -0400, Brian Haley wrote:
> Is your arch "um"?  Seems like those are only defined there, I'm building
> a straight x86 kernel.

Nope.

I did make allyesconfig ; make lib/vsprintf.o lib ctype.o
allnoconfig works though.

> This core dumps when running "test", I'm still trying to track down why.

missing return on ip_addr_string

> I think we're thinking too hard about this, I would think we'd always
> want to print the shortened IPv6 address in debugging messages with %pI6.

True, but you can't tell in sprintf as it's used in seq.

for instance:
net/sunrpc/svcauth_unix.c:		seq_printf(m, "%s %pI6 %s\n", im->m_class, &addr, dom);

> The %pi6 places need to stay since they're an API to userspace.  I don't
> think we need the extra "c" and "c4" support.

I'm pretty sure it can't change and a new form is needed
so %pi6c should be OK.

I'd rather not use another %p<foo> letter.

> One comment on a quick scan of the code:
> ip6_addr[8 * 5] is fine here, we won't ever have all eight plus an IPv4 address.

I'm fixing it up and will resubmit something working in a little while.

cheers, Joe

