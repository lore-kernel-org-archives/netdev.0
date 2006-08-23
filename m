From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: eth interface enumeration order
Date: Wed, 23 Aug 2006 18:46:21 +0200
Message-ID: <20060823164620.GO969@harddisk-recovery.com>
References: <44EC79D8.3050402@paradigmgeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@zip.com.au, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dtp.xs4all.nl ([80.126.206.180]:32255 "HELO abra2.bitwizard.nl")
	by vger.kernel.org with SMTP id S965059AbWHWQqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 12:46:23 -0400
To: Victor Secarin <vsecarin@paradigmgeo.com>
Content-Disposition: inline
In-Reply-To: <44EC79D8.3050402@paradigmgeo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 23, 2006 at 09:52:56AM -0600, Victor Secarin wrote:
> VERSION
> With kernel 2.4.33.1:
> HARDWARE
> I have a server with two eepro100 and one e1000 interfaces
> BEHAVIOR
> When the kernel boots the drivers report (/var/log/messages) the 
> interfaces they find and what they are named (eth0, eth1, eth2)
> 1. With the drivers configured monolithically in the kernel:
> e1000 reports eth0 and then eepro100 reports eth1 and eth2

Bus order.

> 2. With the drivers configured as modules:
> eepro100 reports eth0 and eth1 and then e1000 reports eth2

Module load order.

> PROBLEM
> 1. On a red  hat distribution, different interfaces may have different 
> configuration scripts, which assign IP addresses and more, and the 
> scripts are identified by the ethx name.
> 2. It is necessary to control which interface becomes eth0 as various 
> programs use the MAC address of eth0 to identify the computer. In my 
> case that is "lmhostid" and all the FLEXlm software,
> as I run a license server on that machine.

Manually load the modules in the correct order, that should solve your
problems. Or use nameif to rename the network devices (on 2.6 that
should be done using udev).


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands
