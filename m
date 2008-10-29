From: Joe Perches <joe@perches.com>
Subject: Re: oh crap...
Date: Wed, 29 Oct 2008 12:13:34 -0700
Message-ID: <1225307615.5269.379.camel@localhost>
References: <1225294760.5269.301.camel@localhost>
	 <1225301082.5688.24.camel@brick> <1225304214.5269.339.camel@localhost>
	 <20081029.113142.135680097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:4588 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436AbYJ2TNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 15:13:41 -0400
In-Reply-To: <20081029.113142.135680097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-29 at 11:31 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 29 Oct 2008 11:16:54 -0700
> > On Wed, 2008-10-29 at 10:24 -0700, Harvey Harrison wrote:
> > > Putting a modifier after the format specifier seems a little strange to me.
> > Harvey, please remember the whole %p<foo> concept is based on
> > modifier after format specifier.
> I don't think there is any such strict rule, or even that we'd
> want to enforce that.

Of course there's a strict rule.

"%<flags>p" is a normal format conversion specifier.
It takes a pointer as its argument.
Character(s) immediately after the pointer conversion
specifier "p" may be linux-specific format modifiers.

> There is nothing wrong with saying something like %pI6 where
> the "I" signifies "internet address in 'natural' form" and
> "6" is the 'modifier' which you love so much which means
> "oh btw, it's ipv6"

True enough.  6 and I6 are both modifiers.

I have been doodling with sparse to verify the pointer types.
I just want a simple rule: char after "%<flag>p" specifies pointer type.

Ideally it would be:

4: __be32 *
6: struct in6_addr *
R: struct resource *
M: char *

cheers, Joe

