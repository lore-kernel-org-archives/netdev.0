From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: ethernet: davinci_cpdma: Add boundary for
 rx and tx descriptors
Date: Tue, 11 Dec 2012 13:30:58 -0500 (EST)
Message-ID: <20121211.133058.2238010228178961245.davem@davemloft.net>
References: <1355197433-7492-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, s.hauer@pengutronix.de
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948Ab2LKSbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 13:31:06 -0500
In-Reply-To: <1355197433-7492-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You cannot do this.

After your changes the driver no longer does any TX flow control.

It never stops the TX queue and never wakes it up later.

It just drops packets on the floor when it runs out of descriptors.

This breaks everything, and in particular packet schedulers and
TCP.

I'm not applying this.
