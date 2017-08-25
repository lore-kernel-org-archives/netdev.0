From: Jean Tourrilhes <jt@labs.hpe.com>
Subject: Re: Possible race in nsc-ircc.ko
Date: Fri, 25 Aug 2017 09:48:47 -0700
Message-ID: <20170825164847.GA18854@labs.hpe.com>
References: <4a33a281-f8bd-305b-e580-0e594feea799@ispras.ru>
Reply-To: jean.tourrilhes@hpe.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dagb@cs.uit.no, samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org,
        Alexey Khoroshilov <khoroshilov@ispras.ru>
To: Anton Volkov <avolkov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4a33a281-f8bd-305b-e580-0e594feea799@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 25, 2017 at 05:05:25PM +0300, Anton Volkov wrote:
> Hello.
> 
> While searching for races in the Linux kernel I've come across
> "drivers/net/irda/nsc-ircc.ko" module. Here is a question that I came up
> with while analyzing results. Lines are given using the info from Linux
> v4.12.
> 
> Consider the following case:
> 
> Thread 1:                   Thread 2:
> nsc_ircc_init
> ->nsc_ircc_open
>     self = netdev_priv(dev)
>     register_netdev(dev)
>                             nsc_ircc_net_ioctl
>                             ->nsc_ircc_change_speed
>     self->dongle_id = ...       <READ self->io.dongle_id>
>     (nsc-ircc.c: line 485)      (nsc-ircc.c: line 1318)
>     platform_device_register_simple
> 
> Before the initialization of self->dongle_id in msc_ircc_open() its value is
> 0. Thus if read access to its value in nsc_ircc_change_speed occurs before
> the initialization there will be an attempt to change speed of dongle with
> undesired id (if the dongle with id 0 exists). Is this case feasible from
> your point of view?
> 
> Thank you for your time.
> 
> -- Anton Volkov

	A first glance, that seems like a valid race. I'm not sure if
there is a netdev lock/status to protect the driver, because it looks
like doing any operation on a device before "open" has completed would
be dangerous for most drivers.
	I don't have time to check the code paths, as I have not
looked at that code in ages.
	Good luck !

	Jean
