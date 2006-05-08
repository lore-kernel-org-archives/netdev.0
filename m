From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netdev: hotplug napi race cleanup
Date: Mon, 8 May 2006 12:02:24 -0700
Message-ID: <20060508120224.63c84ad6@localhost.localdomain>
References: <20060424152341.094b72d8@localhost.localdomain>
	<20060506.180947.35317492.davem@davemloft.net>
	<20060508095458.0debd022@localhost.localdomain>
	<20060508.113731.97080992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, patrakov@ums.usu.ru,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:33515 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751277AbWEHTC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 15:02:29 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060508.113731.97080992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 08 May 2006 11:37:31 -0700 (PDT)
"David S. Miller" <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Mon, 8 May 2006 09:54:58 -0700
> 
> > The issue is are there network devices that can't sleep during
> > register_netdevice?
> 
> Oh right, I forgot about that.

We could do something like this in register_netdevice()

	if (in_atomic() || irqs_disabled())
		net_set_todo(dev);
	else {
		dev->reg_state = NETREG_REGISTERED;
		ret = netdev_register_sysfs(dev);
		if (ret) {
			... 
	}

It seems a bit grotty, and might cause pain later.
