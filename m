From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] Add netpoll/netconsole support to vlan devices
Date: Mon, 25 Sep 2006 22:34:36 -0700 (PDT)
Message-ID: <20060925.223436.08322700.davem@davemloft.net>
References: <200609252343.k8PNhAKO002851@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesper.juhl@gmail.com, davem@redhat.com,
	greearb@candelatech.com, mingo@redhat.com, mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51641
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751276AbWIZFec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 01:34:32 -0400
To: akpm@osdl.org
In-Reply-To: <200609252343.k8PNhAKO002851@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 25 Sep 2006 16:43:10 -0700

> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	new_dev->poll_controller = real_dev->poll_controller;
> +#endif
> +

I don't see how this part can be correct.  If netpoll actually
calls new_dev->poll_controller it will pass new_dev in
(ie. the VLAN device) yet this method is for real_dev.

If the only side effect of this assignment is that netpoll recognizes
the device as being usable with netpoll, that's really a nasty way to
accomplish that.

In any event, propagating this method pointer to the wrong device
structure is a bug.
