From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Sun, 20 May 2012 12:08:35 -0400
Message-ID: <20120520160835.GA21177@windriver.com>
References: <1337362769-4676-1-git-send-email-paul.gortmaker@windriver.com>
 <201205182016.51489.linux@rainbow-software.org>
 <20120518220305.GC15256@windriver.com>
 <20120519133038.282d0a7d@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ondrej Zary <linux@rainbow-software.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Alan Cox <alan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:61134 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960Ab2ETQJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2012 12:09:23 -0400
Content-Disposition: inline
In-Reply-To: <20120519133038.282d0a7d@bob.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.] On 19/05/2012 (Sat 13:30) Alan Cox wrote:

> > You miss the point.  We've got someone with a modern i7 machine who is
> > getting confused by seeing messages from some ancient 3c501 driver,
> > but he doesn't have the context to know it is ancient and the message
> > is a red herring.  Will it fix a distro's broken init that tries to
> > modprobe everything?  No.  Will it help by not muddying the waters
> > with meaningless printk from 3c501 that confuse users?  Yes.
> 
> That seems a totally bogus reason for removing stuff. The kernel cannot
> manage every possible distribution and user screw up. They have more
> variety so they will always win the battle.

Unfortunate that Ondrej's comment led folks to focus on the above as if
it was the primary reason.  It was not.  The sheer unusability of it as
a real networking interface in today's world (that I listed) was the
prime motivation for removal.  It was barely useable in the 1995 world,
and I can't imagine it has got better with age.

Getting rid of possibly misleading messages like the printk in the i7
user's messages is just a fringe benefit.  I can remove the text:

	"-- it is causing issues in some distros, and while
	 that might be fixable, it is just not worth it."

from the commit log[1] and I think the remaining description still stands
on its own as being justified.

> 
> Removing it because nobody is running one even in a museum might be a
> good reason, but then the driver still works fine.

I would suspect that is the case here though.  Based on its limitations
(one operation at a time please) - I can't imagine that anyone anywhere
is running one (with the possible exception of one or maybe two informal
museusms?).

> 
> Also btw: the 3c501 isn't all TTL it's integrated. The 3c500 is all
> TTL and an amazing beast, its so big it won't fit a 16bit slot as it
> has to drop down after the connector to get all the chips on.

It has been at least 15 years since I've seen one, and google couldn't
find me a picture, so I was going on memory.  3c501 definitely still had a
lot of discrete TTL chips for bus glue logic then, since I'm sure it was
a busy looking board.

> 
> (and yes I have a 3c500)

I've never seen one of those, and I count myself lucky.  :)

> 
> However I don't think this is the right way to tackle the ethernet
> history situation. As with MCA we should pull *all* the real
> historical interest only bits in one go so it's immediately obvious
> where the break point is for all devices.

MCA was fortunately reasonably bounded in time -- i.e. it was confined
largely to things unfit for any use today.  EISA is somewhat the same.

> 
> That or we'll replace confused distros and uses with confused ancient
> machine owners, and the latter can be far more persistent and
> irritating ;)
> 
> So should we dump ISA ?

Per Dave's comments, we'd have to restrict ISA in this context to mean
ISA _drivers_ that support _only_ physical pluggable 8/16bit ISA bus
cards.  With possible inclusion of onboard chips that were only deployed
on ancient motherboards well over 10 years ago -- e.g. onboard aha154x.c
and etherexpress on lp486e board type stuff.  Maybe that is what you
implicitly meant anyways?

But since ISA isn't as nicely bounded in time, I could easily envision
someone with a 1GHz socket370 P3 and an ISA SMC-Ultra PnP connected to a
cable modem in a closet somewhere.  Sure, it is old, but it could be
still doing the job of a _reliable_ workhorse.

Replace SMC-ultra with 3c501 in the above, and the story falls apart and
becomes laughable.  This is with no disrespect for the 3c501 driver.  It
is purely from the hardware being of a different era.  Both ISA, but one
is 10-15 years newer than the other.

If we throw away the ISA card drivers all at once, we'll end up keeping
some things well past their best before date, and throwing out some
stuff that might actually still be used by real people.  This isn't at
all fatal in itself, but something to consider when weighing against the
value of a consistent "all this stuff goes away on day X" message.

That, and the inevitable inability to get a consensus "yes" for a large
removal of ISA _card_ drivers from a decision committee, made me think
that piecemeal was better than no action.  If folks think I'm wrong on
the consensus part, I will gladly start forming an ISA _card_ driver
list of candidates for some yet to be determined scheduled removal...

Paul.

[1] http://patchwork.ozlabs.org/patch/160144/
--

> Alan
