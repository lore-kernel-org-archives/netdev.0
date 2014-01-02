From: jiang.biao2@zte.com.cn
Subject: Re: [Patch] netxen_nic: Bugfix for wrong RUNNING status of NX3031 NICs
 with no link
Date: Thu, 2 Jan 2014 17:16:17 +0800
Message-ID: <OFEE191896.FD28476A-ON48257C54.003205EE-48257C54.0032F33D@zte.com.cn>
References: <20140102.032423.2130522873875479421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: li.fengmao@zte.com.cn, manish.chopra@qlogic.com,
	netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	sony.chacko@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.zte.com.cn ([202.103.147.172]:38714 "EHLO zte.com.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750721AbaABJQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 04:16:45 -0500
In-Reply-To: <20140102.032423.2130522873875479421.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You cannot do this, because at the very exact moment you call
> register_netdevice() the device can be brought up and once the
> device is up the link can be brought up.

> Therefore if you invoke netif_carrier_off() right after
> register_netdevice(), it can cancel out a legitimate
> netif_carrier_on() call.

register_netdevice() should be call in probe(), at that time, is
it impossible to bring up device because the driver loading has
not finished?

Even that, the netif_carrier_off() will be called before
netif_carrier_on(), and that will not be a problem.

Besides, the other net drivers(e.g igb, e1000, e1000e) I saw all
call netif_carrier_off() after register_netdev(). There is no such
problems in these drivers.
