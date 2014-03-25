From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] ipv6: move DAD and addrconf_verify processing to
 workqueue
Date: Tue, 25 Mar 2014 14:20:04 -0700
Message-ID: <20140325142004.7507d310@samsung-9>
References: <20140317161853.2e880469@nehalam.linuxnetplumber.net>
	<20140323020351.GA3984@order.stressinduktion.org>
	<20140325080301.GA22086@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:64375 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbaCYVUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 17:20:09 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so973378pde.39
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 14:20:08 -0700 (PDT)
In-Reply-To: <20140325080301.GA22086@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Mar 2014 09:03:01 +0100
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

>  
> -static void addrconf_verify(unsigned long foo)
> +static void addrconf_verify_rtnl(void)
>  {
>  	unsigned long now, next, next_sec, next_sched;
>  	struct inet6_ifaddr *ifp;
>  	int i;
>  
> +	ASSERT_RTNL();
> +
>  	rcu_read_lock_bh();
>  	spin_lock(&addrconf_verify_lock);

Since RTNL is now held in addrconf_verify(), is addrconf_verify_lock is not needed.

Since RTNL is held, rcu is not needed either.

Also, I would skip the wrapper (addrconf_verify_rtnl) and just
put it all in addrconf_verify_work
