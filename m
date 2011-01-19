From: Ingo Molnar <mingo@elte.hu>
Subject: netconsole build breakage (Re: [GIT] Networking)
Date: Wed, 19 Jan 2011 10:59:20 +0100
Message-ID: <20110119095920.GA10543@elte.hu>
References: <20110114.130323.201674039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Nicholas Bellinger <nab@linux-iscsi.org>,
	James Bottomley <James.Bottomley@suse.de>,
	Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110114.130323.201674039.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


FYI, there's a .38-rc1 build failure that triggers rather often:

 drivers/built-in.o: In function `drop_netconsole_target':
 netconsole.c:(.text+0x130146): undefined reference to `config_item_put'
 drivers/built-in.o: In function `write_msg':
 netconsole.c:(.text+0x1301aa): undefined reference to `config_item_get'
 netconsole.c:(.text+0x130217): undefined reference to `config_item_put'
 drivers/built-in.o: In function `netconsole_netdev_event':
 netconsole.c:(.text+0x1302ab): undefined reference to `config_item_get'
 ...

Triggered by this configuration:

 CONFIG_CONFIGFS_FS=m
 CONFIG_NETCONSOLE=y

Probably caused by:

 d9f9ab51e55e: net: Make NETCONSOLE_DYNAMIC depend on CONFIGFS_FS

The commit appears to have gone upstream via the iscsi tree. The commit is going in 
the wrong direction as well, beyond being buggy.

The original problem was caused by this iscsi commit:

 e205117285d6: configfs: change depends -> select SYSFS

and the dependency problems snowballed from there, and one side-effect was patched 
up - but others remain.

Thanks,

	Ingo
