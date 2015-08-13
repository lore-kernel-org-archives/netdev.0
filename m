From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 0/2] ppp: implement x-netns support
Date: Thu, 13 Aug 2015 15:28:02 +0200
Message-ID: <cover.1439471390.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:34694 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752046AbbHMN2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 09:28:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series allows PPP devices to reside in a different netns from the
PPP unit/channels. Packets only cross netns boundaries when they're
transmitted between the net_device and the PPP unit (units and channels
always remain in their creation namespace).
So only PPP units need to handle cross namespace operations. Channels
and lower layer protocols aren't affected.

Patch #1 is a bug fix for an existing namespace deletion bug and has
been separetly sent to net.
Patch #2 is the actual x-netns implementation.


Guillaume Nault (2):
  ppp: fix device unregistration upon netns deletion
  ppp: implement x-netns support

 drivers/net/ppp/ppp_generic.c | 94 ++++++++++++++++++++++++++-----------------
 1 file changed, 57 insertions(+), 37 deletions(-)

-- 
2.5.0
