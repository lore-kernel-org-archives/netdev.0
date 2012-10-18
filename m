From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 10:00:44 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7051@saturn3.aculab.com>
References: <507F38D4.102@genband.com> <alpine.DEB.2.00.1210180946020.21297@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	"James Morris" <jmorris@namei.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>
To: "Mikael Abrahamsson" <swmike@swm.pp.se>,
	"Chris Friesen" <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40208 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754594Ab2JRJBh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 05:01:37 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17666-04 for <netdev@vger.kernel.org>;
 Thu, 18 Oct 2012 10:01:34 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <alpine.DEB.2.00.1210180946020.21297@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 2. When a network connection (physical interface) goes down, wait a few
> seconds, give up, reset all connectivity related to that connection,
> basically give up.

Doing that is almost pointless and gives people false expectations.

Consider the simple network host-hub-hub-host.
If you disconnect the link between the two hubs then
only timeouts can cause disconnects.
Such a remote fault is much more likely than the local one.

If the kernel takes down connections when a local interface
goes down (as windows does) then people doing testing
fail to test the correct scenario.

You also don't want a power glitch in the wiring cupboard
to disconnect all your connections.

In the past I've also moved IP addresses between physical
interfaces - modern HA systems might do the same.

	David
