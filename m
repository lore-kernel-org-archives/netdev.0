From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking for 2.6.28
Date: Sat, 11 Oct 2008 15:04:56 -0700 (PDT)
Message-ID: <20081011.150456.193701531.davem@davemloft.net>
References: <alpine.LFD.2.00.0810111057020.3402@nehalem.linux-foundation.org>
	<20081011.121930.193700319.davem@davemloft.net>
	<alpine.LFD.2.00.0810111303510.3402@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, philipl@overt.org, hmh@hmh.eng.br,
	linville@tuxdriver.com
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45921
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755390AbYJKWFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 18:05:21 -0400
In-Reply-To: <alpine.LFD.2.00.0810111303510.3402@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 11 Oct 2008 13:10:52 -0700 (PDT)

> On Sat, 11 Oct 2008, David Miller wrote:
> > This patch should fix that case, let me know if it works:
> 
> How about you test it? 

Yep, indeed I did give it a try.

> It wasn't my bug-report, I just reported another 
> report from somebody who _does_ run randconfig.

Where did you see this?  I wouldn't have asked all of these idiotic
questions if I had a link to the report.  Then I could go grab the
config used to produce the problem and then ping the reporter with
a test patch. :-)

> Here's another one:
> 
> 	drivers/built-in.o: In function `bt_poll_rfkill':
> 	toshiba_acpi.c:(.text+0x37346): undefined reference to `input_event'
> 
> where the cause seems to be a totally broken Kconfig entry ACPI_TOSHIBA.

Where are these reports coming from?  Some automated randconfig thing
that gets posted somewhere?  I'd really like to look at this stuff, it
seems very useful.

> You can't just do
> 
> 	select INPUT_POLLDEV
> 
> since that in turn needs all the _other_ input stuff. Yes, yes, things 
> like various keyboard drivers do exactly that, but they are already inside 
> "if INPUT_KEYBOARD/INPUT_MISC" or similar.
> 
> So at the very least, you'd now have to have it do a "depends on INPUT" or 
> something like that.
> 
> Or perhaps just make that particular _feature_ depend on it, rather than 
> make the whole driver depend on or select it. 

Do you want me to fix this ACPI build failure in the networking tree?
I'm more than happy to :-)

