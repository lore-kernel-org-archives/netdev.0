From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] tg3: Bugfixes and 5719 support
Date: Sun, 06 Jun 2010 18:00:29 -0700 (PDT)
Message-ID: <20100606.180029.42789560.davem@davemloft.net>
References: <1275794679-11085-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43527
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754313Ab0FGBAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jun 2010 21:00:19 -0400
In-Reply-To: <1275794679-11085-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Sat, 5 Jun 2010 20:24:29 -0700

> This patchset adds some bugfixes and adds 5719 device support.

All applied to net-next-2.6 but there are two things I'm very disappointed
with in this series:

1) Naming register bits things like "TX_MBUF_FIX" isn't descriptive,
   and I suspect the actual bit name used in your programming manuals
   is very different and would be more helpful to someone reading the
   code and trying to understand exactly what that bit does.

   How does it change the chips internal MBUF handling behavior?  Does
   it insert a delay in accesses or state changes?  Does it change
   the MBUF arbitration?  What the heck does that bit do exactly?

2) Removing register definitions is something we really shouldn't do.
   Just because you're not using the register any more in the driver,
   doesn't mean you should remove it's definition from tg3.h

   What if some other developer wants to play with that register and
   use it for some other purpose or experiment?

You really have to handle situations like #1 and #2 better especially
since you guys do not public post the full PDF hardware programming
manuals of your chips online for other developers to use.

I wouldn't, therefore, impose these rules on Intel and their drivers
because they do public the programming manuals for their networking
chips.
