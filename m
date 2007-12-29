From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH] Make FC, FDDI, HIPPI and TR tristate
Date: Sat, 29 Dec 2007 02:09:30 +0200
Message-ID: <20071229000930.GD9105@does.not.exist>
References: <Pine.LNX.4.64.0712282348280.29013@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:52652 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751926AbXL2Ae4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2007 19:34:56 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0712282348280.29013@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 29, 2007 at 12:45:12AM +0100, Jan Engelhardt wrote:
> Turn CONFIG_FC, CONFIG_FDDI, CONFIG_HIPPI and CONFIG_TR into tristate
> so they can be built as modules. This will allow CONFIG_LLC to be
> built as a module too, overall reducing the core kernel image size.
>...

Just an example of code you have to fix if you do this:

$ grep -r "#ifdef CONFIG_TR" net/
net/802/sysctl_net_802.c:#ifdef CONFIG_TR
net/802/sysctl_net_802.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/atm/lec.c:#ifdef CONFIG_TR
net/ipv4/arp.c:#ifdef CONFIG_TR
net/llc/llc_output.c:#ifdef CONFIG_TR
net/sysctl_net.c:#ifdef CONFIG_TR
net/sysctl_net.c:#ifdef CONFIG_TR
$ 

For all variables you change to tristates you have to check every single 
#ifdef in C code in the kernel using this variable whether it needs to
be fixed when it's modular.

You also have to check all usages of these variables in Kconfig files, 
but my first impression is they are all OK.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

