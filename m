From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver
Date: Mon, 25 Aug 2008 17:21:26 +0100
Message-ID: <20080825162125.GU7908@solarflare.com>
References: <48AFA8A8.6070604@cooldavid.org> <48AFB137.9020506@pobox.com> <48B03522.9020604@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Ethan <ethanhsiao@jmicron.com>,
	akeemting <akeem@jmicron.com>, netdev@vger.kernel.org
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:49670 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754535AbYHYQVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 12:21:39 -0400
Content-Disposition: inline
In-Reply-To: <48B03522.9020604@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guo-Fu Tseng wrote:
> Jeff Garzik wrote:
[...]
> >* we prefer not to add custom ioctls, but rather add functionality to 
> >ethtool.  in particular, JMESPIIOCTL does not appear to have any 
> >security checks, and is a potential security hole that permits an 
> >unpriveleged user direct access to hardware
> >
> 
> Should I add privilege check, or should(could?) I send a patch that add 
> ethtool interface for flash(For storing PXE code) read/write?

Flash devices are normally handled by MTD drivers.  However an MTD
driver that works through a network controller will normally need to
coordinate with the network driver.  We have an MTD driver for exactly
the purpose of updating boot code, but the coordinating mechanism
("driverlink") has not been accepted in-tree.

I think we would be happy to implement an ethtool API for flash
memory if this was agreed to be the right interface.  It just seems
like it would be duplicating the MTD API.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
