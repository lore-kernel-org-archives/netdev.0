From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: mv643xx broken on pegasos
Date: Mon, 19 Jan 2009 11:42:25 +0100
Message-ID: <20090119104225.GI17124@xi.wantstofly.org>
References: <20090115012232.3852.qmail@kosh.dhis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Gabriel Paubert <paubert@iram.es>,
	Matt Sealey <matt@genesi-usa.com>
To: pacman@kosh.dhis.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:47380 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758405AbZASKm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 05:42:27 -0500
Content-Disposition: inline
In-Reply-To: <20090115012232.3852.qmail@kosh.dhis.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 08:22:32PM -0500, pacman@kosh.dhis.org wrote:

> In 2.6.28, it behaves like 2.6.27 with a bonus bug: the port has
> moved to eth2, and eth1 is now a phantom port with MAC address
> 00:00:00:00:00:00. And the old 2.6.26 code doesn't compile so the
> workaround is dead.

This is probably because mv643xx_eth now no longer fails registration
of the interface if no valid PHY could be found.  Gabriel Paubert
(CC'ed) had a patch for this that basically amounted to removing the
initialisation for eth1 (called "eth0" in the Pegasos platform code).
He's away for a couple of days but should be back soon.

Also, since the mv643xx_eth phylib conversion, it appears that the
PHY on the Pegasos board fails to initialise properly, and this can
apparently be worked around by turning the Marvell phylib driver off.
Are you seeing this as well?


thanks,
Lennert
