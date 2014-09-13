From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Sat, 13 Sep 2014 16:21:01 -0400 (EDT)
Message-ID: <20140913.162101.515634682549373073.davem@davemloft.net>
References: <54146A37.5010108@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbaIMUVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 16:21:02 -0400
In-Reply-To: <54146A37.5010108@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Sat, 13 Sep 2014 12:00:55 -0400

> This patch allows an admin to set the MTU on a sunvnet device to arbitrary
> values between the minimum (68) and maximum (65535) IPv4 packet sizes.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

I personally find this scheme where we pretend that the device can
have an arbitrary MTU, when in fact the effective MTU is a product of
the sub-ports, quite ugly.

In fact, that ugly ICMP stuff in the next patch is absolutely required
to avoid bogus behavior possible after this patch.  You have to
combine #2 and #3 otherwise you are adding an intermediate regression.

Logic wise, at the very least you should limit the MTU setting to the
largest MTU of all of the individual ports.
