From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] i40e: Fix dependencies in the i40e driver on
 configfs
Date: Tue, 03 Mar 2015 15:45:15 -0500 (EST)
Message-ID: <20150303.154515.1426526534548261925.davem@davemloft.net>
References: <1425415135-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756619AbbCCUpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 15:45:18 -0500
In-Reply-To: <1425415135-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  3 Mar 2015 12:38:55 -0800

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Module dependencies are broken in the case where CONFIG_I40E=y and
> CONFIG_CONFIGFS_FS=m.  This fixes the broken dependency.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

This doesn't fix anything, nothing tests I40E_CONFIGFS_FS:

[davem@abraco net-next]$ make -s -j8
scripts/Makefile.kasan:16: Cannot use CONFIG_KASAN: -fsanitize=kernel-address is not supported by compiler
scripts/Makefile.kasan:16: Cannot use CONFIG_KASAN: -fsanitize=kernel-address is not supported by compiler
kernel/Makefile:133: *** No X.509 certificates found ***
kernel/Makefile:133: *** No X.509 certificates found ***
drivers/built-in.o: In function `i40e_cfgfs_group_make_item':
i40e_configfs.c:(.text+0x192db7): undefined reference to `config_item_init_type_name'
drivers/built-in.o: In function `i40e_configfs_init':
(.text+0x192df1): undefined reference to `config_group_init'
drivers/built-in.o: In function `i40e_configfs_init':
(.text+0x192e25): undefined reference to `configfs_register_subsystem'
drivers/built-in.o: In function `i40e_configfs_exit':
(.text+0x192e7a): undefined reference to `configfs_unregister_subsystem'
make: *** [vmlinux] Error 1
[davem@abraco net-next]$ git am --signoff diff
Applying: i40e: Fix dependencies in the i40e driver on configfs
[davem@abraco net-next]$ make oldconfig
scripts/kconfig/conf --oldconfig Kconfig
#
# configuration written to .config
#
[davem@abraco net-next]$ make -s -j8
scripts/Makefile.kasan:16: Cannot use CONFIG_KASAN: -fsanitize=kernel-address is not supported by compiler
scripts/Makefile.kasan:16: Cannot use CONFIG_KASAN: -fsanitize=kernel-address is not supported by compiler
kernel/Makefile:133: *** No X.509 certificates found ***
kernel/Makefile:133: *** No X.509 certificates found ***
drivers/built-in.o: In function `i40e_cfgfs_group_make_item':
i40e_configfs.c:(.text+0x192db7): undefined reference to `config_item_init_type_name'
drivers/built-in.o: In function `i40e_configfs_init':
(.text+0x192df1): undefined reference to `config_group_init'
drivers/built-in.o: In function `i40e_configfs_init':
(.text+0x192e25): undefined reference to `configfs_register_subsystem'
drivers/built-in.o: In function `i40e_configfs_exit':
(.text+0x192e7a): undefined reference to `configfs_unregister_subsystem'
make: *** [vmlinux] Error 1
[davem@abraco net-next]$ 
