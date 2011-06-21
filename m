From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] netconsole: fix build when CONFIG_NETCONSOLE_DYNAMIC
 is turned on
Date: Tue, 21 Jun 2011 13:45:09 +0100
Message-ID: <1308660309.3093.108.camel@localhost>
References: <bug-37992-10286@https.bugzilla.kernel.org/>
	 <20110620122835.444f16d7.akpm@linux-foundation.org>
	 <20110620212504.e639ad5c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	hilld@binarystorm.net
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:39844 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab1FUMpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 08:45:14 -0400
In-Reply-To: <20110620212504.e639ad5c.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-20 at 21:25 -0700, Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> When NETCONSOLE_DYNAMIC=y and CONFIGFS_FS=m, there are build errors
> in netconsole:
> 
> drivers/built-in.o: In function `drop_netconsole_target':
> netconsole.c:(.text+0x1a100f): undefined reference to `config_item_put'
> drivers/built-in.o: In function `make_netconsole_target':
> netconsole.c:(.text+0x1a10b9): undefined reference to `config_item_init_type_name'
> drivers/built-in.o: In function `write_msg':
> netconsole.c:(.text+0x1a11a4): undefined reference to `config_item_get'
> netconsole.c:(.text+0x1a1211): undefined reference to `config_item_put'
> drivers/built-in.o: In function `netconsole_netdev_event':
> netconsole.c:(.text+0x1a12cc): undefined reference to `config_item_put'
> netconsole.c:(.text+0x1a12ec): undefined reference to `config_item_get'
> netconsole.c:(.text+0x1a1366): undefined reference to `config_item_put'
> drivers/built-in.o: In function `init_netconsole':
> netconsole.c:(.init.text+0x953a): undefined reference to `config_group_init'
> netconsole.c:(.init.text+0x9560): undefined reference to `configfs_register_subsystem'
> drivers/built-in.o: In function `dynamic_netconsole_exit':
> netconsole.c:(.exit.text+0x809): undefined reference to `configfs_unregister_subsystem'
> 
> so make NETCONSOLE_DYNAMIC require CONFIGFS_FS=y to fix the build errors.
[...]

NETCONSOLE is tristate, and I think NETCONSOLE=m && NETCONSOLE_DYNAMIC=y
&& CONFIGFS_FS=m should be OK.

It seems like Kconfig should have a '>=' operator which behaves like a
numeric comparison with n=0, m=1, y=2.  Then we could use a dependency
of:
	NETCONSOLE && SYSFS && CONFIGFS_FS>=NETCONSOLE

But for now I think the correct dependency is:
	NETCONSOLE && SYSFS && CONFIGFS_FS && !(NETCONSOLE=y && CONFIGFS_FS=m)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

