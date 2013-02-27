From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: af_packet: Validate parameter size for
 PACKET_HDRLEN control message
Date: Wed, 27 Feb 2013 15:19:28 -0500 (EST)
Message-ID: <20130227.151928.395277104109202104.davem@davemloft.net>
References: <1361994418-1403-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab3B0UTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 15:19:31 -0500
In-Reply-To: <1361994418-1403-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The first thing this function does is test whether len < 0, therefore
your change is unnecessary.

If the user gives us something between 0 and sizeof(int), that's
their problem, and they'll get a partial int copied back into
userspace as a result instead of the complete integer.

Please don't blindly silence warnings like this, thanks.
