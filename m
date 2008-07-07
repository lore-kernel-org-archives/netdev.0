From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/2][RFC] mv643xx_eth: hw tx checksumming support for vlan-tagged packets
Date: Mon, 7 Jul 2008 22:56:15 +0200
Message-ID: <20080707205615.GA12997@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@cam.org>,
	Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:57529 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755735AbYGGU4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 16:56:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches let mv643xx_eth use hardware TX checksumming in the
presence of extra data between the ethernet header and the IP header
(e.g. vlan tags, or DSA switch tags (for which I'll hopefully submit
some code soon)).

The main thing I'd like feedback on is that I had to switch
vlan_check_reorder_header() from using skb_copy() to using pskb_copy()
to have fragmented skbs survive the trip through the stack to the
driver's ->hard_start_xmit() function at all.  The patch to the driver
itself (2/2) should be pretty straightforward.

(These patches depend on Patrick McHardy's patch "vlan: fix
network_header/mac_header adjustments".)
