From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RFC 0/2] skb recycling (and example implementation for mv643xx_eth)
Date: Wed,  3 Sep 2008 15:54:59 +0200
Message-ID: <1220450101-21317-1-git-send-email-buytenh@wantstofly.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:57999 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752747AbYICNzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 09:55:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements skb recycling, which is basically just reusing skbuffs
that have finished transmitting as receive buffers, avoiding skbuff
freeing/reallocation overhead.  This is done by having the networking
provide skb_recycle_check(), which drivers can then use in their tx
ring cleanup (example implementation for mv643xx_eth included).

On mv643xx_eth, this gives a nice performance increase (~25%) when
doing packet routing, but it might be considered too ugly for mainline
-- so, feedback welcome.
