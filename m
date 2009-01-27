From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: fix hard hang with netconsoling and iface going
 up
Date: Tue, 27 Jan 2009 10:19:03 -0800 (PST)
Message-ID: <20090127.101903.144575010.davem@davemloft.net>
References: <20090127132718.GA10001@x200.localdomain>
	<20090127133504.GA10091@x200.localdomain>
	<20090127094928.534ff6f6@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57273
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753133AbZA0STG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 13:19:06 -0500
In-Reply-To: <20090127094928.534ff6f6@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 27 Jan 2009 09:49:28 -0800

> Netconsole should be smart enough to not try and print to
> a device that is not marked running.

I think the hardware is marked running.

This is at the beginning of the driver's ->open() method.

The netpoll layer is in fact checking those states:

static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
{
 ...
	if (!npinfo || !netif_running(dev) || !netif_device_present(dev)) {
		__kfree_skb(skb);
		return;
	}
