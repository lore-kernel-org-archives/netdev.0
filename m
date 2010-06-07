From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 00/11] tg3: Bugfixes and 5719 support
Date: Sun, 6 Jun 2010 20:59:34 -0700
Message-ID: <20100607035934.GB11599@mcarlson.broadcom.com>
References: <1275794679-11085-1-git-send-email-mcarlson@broadcom.com>
 <20100606.180029.42789560.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4717 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756097Ab0FGD7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jun 2010 23:59:45 -0400
In-Reply-To: <20100606.180029.42789560.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 06, 2010 at 06:00:29PM -0700, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Sat, 5 Jun 2010 20:24:29 -0700
> 
> > This patchset adds some bugfixes and adds 5719 device support.
> 
> All applied to net-next-2.6 but there are two things I'm very disappointed
> with in this series:
> 
> 1) Naming register bits things like "TX_MBUF_FIX" isn't descriptive,
>    and I suspect the actual bit name used in your programming manuals
>    is very different and would be more helpful to someone reading the
>    code and trying to understand exactly what that bit does.

Actually, the programming manual describes this register just as
tersely.

>    How does it change the chips internal MBUF handling behavior?  Does
>    it insert a delay in accesses or state changes?  Does it change
>    the MBUF arbitration?  What the heck does that bit do exactly?

The programming manual says this bit prevents a tx state machine lockup
due to tx mbuf corruption.  The conditions under which the tx mbufs get
corrupted is complicated, but the net effect of this bit is that the
RDMA engine acts a little more conservatively.

> 2) Removing register definitions is something we really shouldn't do.
>    Just because you're not using the register any more in the driver,
>    doesn't mean you should remove it's definition from tg3.h
> 
>    What if some other developer wants to play with that register and
>    use it for some other purpose or experiment?

The problem is that register definitions can change from asic rev to
asic rev.  Someone interested in playing with their hardware would have
to know more about their chip before it could even be considered safe to
use these bits.  Rather than have a bit do something other than appears
advertised, it would be safer to just remove it from view.

The patch that removed the register definition exists precisely because
that register definition was changing.  The motivating reason for the
patch was to make the code cleaner and more maintainable, but anyone
attempting to use that definition on a non-5717 device would be using it
incorrectly.

> You really have to handle situations like #1 and #2 better especially
> since you guys do not public post the full PDF hardware programming
> manuals of your chips online for other developers to use.
> 
> I wouldn't, therefore, impose these rules on Intel and their drivers
> because they do public the programming manuals for their networking
> chips.

Understood.

