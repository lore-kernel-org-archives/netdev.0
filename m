From: Trent Piepho <tpiepho@gmail.com>
Subject: Re: [RFC 0/3] arm: mxs: sanitize =?utf-8?b?ZW5ldF9vdXQ=?= clock handling
Date: Fri, 15 Mar 2013 05:30:50 +0000 (UTC)
Message-ID: <loom.20130315T033230-729@post.gmane.org>
References: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:44742 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750872Ab3COFoo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 01:44:44 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UGNRv-0004ow-Qp
	for netdev@vger.kernel.org; Fri, 15 Mar 2013 06:45:04 +0100
Received: from 174-31-195-141.tukw.qwest.net ([174.31.195.141])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 06:45:03 +0100
Received: from tpiepho by 174-31-195-141.tukw.qwest.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 06:45:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfram Sang <w.sang <at> pengutronix.de> writes:
> Handling enet_out on MX28 is cumbersome at the moment. Most boards need it
> enabled and for that, they have to add code to mach-mxs.c (see sps1 as an
> example). Since this is board specific, we better encode it in the devicetree,
> that is the reason it was made for.
> 
> My proposal will overwrite the generic "clock" and "clock-names" properties
> from imx28.dtsi in the board file. The original one has 2 entries, and boards
> needing enet_out will overload it with three entries. The network driver will
> enable the clock if it was specified. The old code enabling the clock will be
> backward compatible but print a WARN if the legacy mode needs to be used.

I was annoyed by this problem when adding a new imx28 board.  Ethernet stopped
working as soon as I changed the board id in the dts from imx28evk to a new one.
Looks like a good solution, but one suggestion.  Since as you say most boards
need enet_out would it be better to specify enet_out in the dtsi file and then
override it in the dts file of the boards that do not have it?
