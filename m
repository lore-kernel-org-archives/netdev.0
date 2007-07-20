From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] IP_VS should depend on EXPERIMENTAL ?
Date: Fri, 20 Jul 2007 08:11:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707200805070.11571@localhost.localdomain>
References: <46A0A01A.7030403@googlemail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:37909 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260AbXGTMNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 08:13:40 -0400
In-Reply-To: <46A0A01A.7030403@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  as a short followup to my previous post, at the *very least*, a
cleanup that could be done now is to find all entries which have an
actual dependency on "EXPERIMENTAL" but don't advertise themselves as
such:

...
config MA600_DONGLE
        tristate "Mobile Action MA600 dongle"
        depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
	...

and determine which of those should have the dependency on
"EXPERIMENTAL" removed.  no, don't go adding "(EXPERIMENTAL)" to the
prompt -- just deal with *only* those for which the dependency is
clearly out of date and not relevant anymore, and delete it.

that would be, at least, a place to start.  and, yes, there's piles of
potential (net/ipv4/Kconfig):

config TCP_CONG_HSTCP
        tristate "High Speed TCP"
        depends on EXPERIMENTAL
	...
config TCP_CONG_HYBLA
        tristate "TCP-Hybla congestion control algorithm"
        depends on EXPERIMENTAL
	...
config TCP_CONG_VEGAS
        tristate "TCP Vegas"
        depends on EXPERIMENTAL
	...
... etc etc ...


rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
