From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 2 of 2] netconsole: add write-only tty driver
Date: Fri, 28 Nov 2008 00:47:01 +0300
Message-ID: <20081127214701.GA7195@ioremap.net>
References: <patchbomb.1227820260@localhost.localdomain> <1a5d52ff499998079f4b.1227820262@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mpm@selenic.com
To: Hollis Blanchard <hollisb@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:43204 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752803AbYK0VrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 16:47:04 -0500
Content-Disposition: inline
In-Reply-To: <1a5d52ff499998079f4b.1227820262@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Looks good. A short note below.

On Thu, Nov 27, 2008 at 03:11:02PM -0600, Hollis Blanchard (hollisb@us.ibm.com) wrote:
> +static int __init netconsole_tty_init(void)
> +{
> +	netconsole_tty_driver = alloc_tty_driver(1);
> +	if (!netconsole_tty_driver)
> +		return -ENOMEM;
> +
> +	netconsole_tty_driver->owner = THIS_MODULE;
> +	netconsole_tty_driver->driver_name = "netcon";
> +	netconsole_tty_driver->name = "netcon";
> +	netconsole_tty_driver->minor_start = 0;
> +	netconsole_tty_driver->type = TTY_DRIVER_TYPE_SYSTEM;
> +	netconsole_tty_driver->init_termios = tty_std_termios;
> +	netconsole_tty_driver->init_termios.c_cflag = B9600 | CS8 | CREAD | HUPCL;
> +	netconsole_tty_driver->init_termios.c_ispeed = 9600;
> +	netconsole_tty_driver->init_termios.c_ospeed = 9600;
> +	netconsole_tty_driver->flags = TTY_DRIVER_REAL_RAW;
> +	tty_set_operations(netconsole_tty_driver, &netconsole_tty_ops);
> +
> +	if (tty_register_driver(netconsole_tty_driver))
> +		printk(KERN_ERR "Couldn't register netconsole tty driver\n");
> +
> +	return 0;
> +}
> +device_initcall(netconsole_tty_init);

Would it be better called from init_netconsole()?

-- 
	Evgeniy Polyakov
