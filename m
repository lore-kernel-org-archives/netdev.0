From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/11] benet: Kconfig, MAINTAINETS, drivers/net Makefile
Date: Tue, 09 Dec 2008 22:54:53 -0800 (PST)
Message-ID: <20081209.225453.183512699.davem@davemloft.net>
References: <1228832471.6435.104.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, subbus@serverengines.com
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50009
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751820AbYLJGyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 01:54:52 -0500
In-Reply-To: <1228832471.6435.104.camel@sperla-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok I looked at this driver some more and I have many comments.

The hardware library abstraction has to go.  You aren't writing a
native linux driver if you split things up like this.  I know you want
code sharing with your other supported platforms, but that's too bad.
If we let every vendor do this the whole tree would be one big
unmaintainable mess.

Many structures have all-caps or capitalized names.  Good coding style
indicates that only CPP macros are to be named with capital letters.
(capital letterd symbols say to the reader "I'm a CPP macro and
probably have side-effects, beware") What's happening here looks ugly
and is inconsistent with the rest of the linux kernel.

The definition of the access to the chip registers is overly
obfuscated.  All of this structure stuff and offsetof() business
adds complexity to the driver and makes it harder to understand.

The bit twiddling is difficult to understand and makes the compiler
work too hard.

I would suggest to fix all of this by simply using macros which
define chip register offsets, and next to those offset define
macros which define the bit values within the register.  Endianness
is not an issue, and all read*()/write*() calls will write out
to the chip in little endian regardless of cpu endianness.

See other drivers such as drivers/net/tg3.[ch] or drivers/net/niu.[ch]
As you'll notice even such huge drivers as those can be done cleanly
in a single source file with no hardware abstraction library layer and
no funny register access structures and bit twiddling, so you can
strive for that as well.

So, this driver still needs a lot of work. :)

