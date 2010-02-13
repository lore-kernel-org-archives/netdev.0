From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] atm : fix /sys/devices/virtual/atm/X/carrier(ATM_PHY_SIG_UNKNOWN)
Date: Sat, 13 Feb 2010 18:24:34 -0500
Message-ID: <201002132324.o1DNOY0F030510@thirdoffive.cmf.nrl.navy.mil>
References: <20100213215633.GA4345@frolo.macqel>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: Philippe De Muyter <phdm@macqel.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:42902 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758016Ab0BMXiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2010 18:38:23 -0500
In-reply-to: <20100213215633.GA4345@frolo.macqel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <20100213215633.GA4345@frolo.macqel>,Philippe De Muyter writes:
>value '1' while actually carrier was not yet established and real carrier
>state was not yet known to linux.  I propose to fix that by using '?' as the
>/sys/devices/virtual/atm/cxacru0/carrier value when carrier state is not yet
>known to linux.  Any other value except '1' would also be OK for me.

this is sort of intentional because some drivers dont actually implement
atm_dev->signal.  ATM_PHY_SIG_UNKNOWN and ATM_PHY_SIG_LOST should
likely be carrier = 0.  if the driver doesnt isnt going to handle
changing the state of atm_dev->signal it should just set the value to
ATM_PHY_SIG_FOUND.

i dont like the idea of carrier being '?' -- carrier is either true or false.
you have it or you dont.
