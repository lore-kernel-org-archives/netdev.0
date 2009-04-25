From: David Miller <davem@davemloft.net>
Subject: Re: Loopback and net namespace
Date: Fri, 24 Apr 2009 22:19:23 -0700 (PDT)
Message-ID: <20090424.221923.232357312.davem@davemloft.net>
References: <alpine.LNX.2.00.0904242322490.1162@duch.mimuw.edu.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@maxwell.aristanetworks.com,
	daniel.lezcano@free.fr
To: emil@linux.org.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55770
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751032AbZDYFTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 01:19:30 -0400
In-Reply-To: <alpine.LNX.2.00.0904242322490.1162@duch.mimuw.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: emil@linux.org.pl
Date: Fri, 24 Apr 2009 23:55:36 +0200 (CEST)

> 
> Currently it is impossible to use both net namespace and sysfs
> because sysfs does not allow two devices with the same name
> and each net namespace has to have loopback device.
> 
> To have this working there must be possibility to
> create loopback devices with different names.
> 
> The easiest way to acomplish this seems to be with this patch below.
> 
> I know the devices will be seen in each namespace, but sometimes
> the only thing that is needed is network environment separation.
> For example when I need to run two different services on the same TCP
> port
> bound to 0.0.0.0.
> 
> This patch will not break anything and allow people to test
> net namespace functionality.

Can you please contact the namespace developers when you post things
like this (as I have on the CC: list now)?  I was sure this issue had
been resolved already or there was a larger plan to do so.

Also your patch is very poorly formatted, lacks a proper signoff, was
corrupted by your email client, etc. so we wouldn't be able consider
it anyways.

> ----------------------- CUT HERE ------------------------------
> 
> --- /usr/src/linux/drivers/net/loopback.c 2008-04-17 04:49:44.000000000
> --- +0200
> +++ /usr/src/linux/drivers/net/loopback.c.new 2009-04-24
> 23:27:43.000000000 +0200
> @@ -254,7 +254,11 @@
>         int err;
> 
>         err = -ENOMEM;
> +#ifdef CONFIG_SYSFS
> + dev = alloc_netdev(0, (net == &init_net) ? "lo" : "lo%d",
> loopback_setup);
> +#else
>         dev = alloc_netdev(0, "lo", loopback_setup);
> +#endif
>         if (!dev)
>                 goto out;
> 
