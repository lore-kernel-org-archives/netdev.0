From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 5/6] net: calxedaxgmac: rework transmit ring handling
Date: Tue, 06 Nov 2012 18:57:04 -0500 (EST)
Message-ID: <20121106.185704.1212469675670236955.davem@davemloft.net>
References: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
	<1352132544-15809-6-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	rob.herring@calxeda.com
To: robherring2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822Ab2KFX5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 18:57:06 -0500
In-Reply-To: <1352132544-15809-6-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <robherring2@gmail.com>
Date: Mon,  5 Nov 2012 10:22:23 -0600

> Only generate tx interrupts on every ring size / 4 descriptors.

I thought we told you that you cannot do this.

With this change if we get a few packets, then stop generating any
traffic, there will be SKBs that just sit dead in your TX queue.

This cannot ever happen.  All TX SKBs must be freed up in a short,
finite, amount of time.  Under all conditions, and in every situation.

Otherwise memory accounted to sockets is not liberated, and such
sockets cannot be destroyed or closed.

SKBs also hold onto other kinds of resources, for which it is critical
to liberate in a finite amount of time.

I'm not applying this series, it still needs more work.
