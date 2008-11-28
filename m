From: Hollis Blanchard <hollisb@us.ibm.com>
Subject: Re: [PATCH 2 of 2] netconsole: add write-only tty driver
Date: Thu, 27 Nov 2008 23:25:15 -0600
Message-ID: <200811272325.15452.hollisb@us.ibm.com>
References: <patchbomb.1227820260@localhost.localdomain> <1a5d52ff499998079f4b.1227820262@localhost.localdomain> <20081127214701.GA7195@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mpm@selenic.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:49826 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbYK1FZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 00:25:17 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAS5OdxA002588
	for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 22:24:39 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAS5PGZD130016
	for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 22:25:16 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAS5PGgl015482
	for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 22:25:16 -0700
In-Reply-To: <20081127214701.GA7195@ioremap.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008 15:47:01 Evgeniy Polyakov wrote:
> Hi.
> 
> Looks good. A short note below.
> 
> On Thu, Nov 27, 2008 at 03:11:02PM -0600, Hollis Blanchard 
(hollisb@us.ibm.com) wrote:
> > +static int __init netconsole_tty_init(void)
> > +{
> > +	netconsole_tty_driver = alloc_tty_driver(1);
> > +	if (!netconsole_tty_driver)
> > +		return -ENOMEM;
> > +
> > +	netconsole_tty_driver->owner = THIS_MODULE;
> > +	netconsole_tty_driver->driver_name = "netcon";
> > +	netconsole_tty_driver->name = "netcon";
> > +	netconsole_tty_driver->minor_start = 0;
> > +	netconsole_tty_driver->type = TTY_DRIVER_TYPE_SYSTEM;
> > +	netconsole_tty_driver->init_termios = tty_std_termios;
> > +	netconsole_tty_driver->init_termios.c_cflag = B9600 | CS8 | CREAD | 
HUPCL;
> > +	netconsole_tty_driver->init_termios.c_ispeed = 9600;
> > +	netconsole_tty_driver->init_termios.c_ospeed = 9600;
> > +	netconsole_tty_driver->flags = TTY_DRIVER_REAL_RAW;
> > +	tty_set_operations(netconsole_tty_driver, &netconsole_tty_ops);
> > +
> > +	if (tty_register_driver(netconsole_tty_driver))
> > +		printk(KERN_ERR "Couldn't register netconsole tty driver\n");
> > +
> > +	return 0;
> > +}
> > +device_initcall(netconsole_tty_init);
> 
> Would it be better called from init_netconsole()?

Hmm, I don't remember what the ordering is here. "console_initcall", used with 
most other console-providing drivers, is done before alloc_tty_driver() can 
work. However, since init_netconsole() is a "module_initcall", I guess that 
should work. Well, it must, since init_netconsole() calls kzalloc() already...

-- 
Hollis Blanchard
IBM Linux Technology Center
