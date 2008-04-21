From: Jason Uhlenkott <juhlenko@akamai.com>
Subject: [RFC 0/4] net: enable timestamps on a per-socket basis
Date: Sun, 20 Apr 2008 22:34:02 -0700
Message-ID: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay03.akamai.com ([72.247.150.167]:57112 "EHLO
	prod-mail-xrelay03.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750776AbYDUFkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 01:40:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if anyone enables the SOCK_TIMESTAMP flag on any socket
(via the SO_TIMESTAMP socket option or the SIOCGSTAMP ioctl), we start
recording timestamps for *every* packet coming into the system.  We do
this because timestamps are recorded very early by the net core,
before the upper protocol layers have a chance to look up the
socket(s) associated with each incoming packet.

A number of common apps enable timestamps, including ping, tcpdump,
and named.  named probably has the biggest impact -- most people don't
leave ping running all the time, and expect that leaving tcpdump
running will cost a bit of performance, but it's unfortunate that the
mere presence of a local caching nameserver has a global negative
effect on incoming packet overhead.


This patchset creates a mechanism for protocols to opt in to handling
timestamps at a higher layer, and uses this mechanism to implement
per-socket SOCK_TIMESTAMP support for several common protocols.
