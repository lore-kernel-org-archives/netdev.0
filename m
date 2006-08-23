From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: eth interface enumeration order
Date: Wed, 23 Aug 2006 09:13:07 -0700
Message-ID: <44EC7E93.2080604@intel.com>
References: <44EC79D8.3050402@paradigmgeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61556 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S965026AbWHWQOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 12:14:53 -0400
To: Victor Secarin <vsecarin@paradigmgeo.com>
In-Reply-To: <44EC79D8.3050402@paradigmgeo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Victor Secarin wrote:
> VERSION
> With kernel 2.4.33.1:
> HARDWARE
> I have a server with two eepro100 and one e1000 interfaces
> BEHAVIOR
> When the kernel boots the drivers report (/var/log/messages) the 
> interfaces they find and what they are named (eth0, eth1, eth2)
> 1. With the drivers configured monolithically in the kernel:
> e1000 reports eth0 and then eepro100 reports eth1 and eth2
> 2. With the drivers configured as modules:
> eepro100 reports eth0 and eth1 and then e1000 reports eth2
> PROBLEM
> 1. On a red  hat distribution, different interfaces may have different 
> configuration scripts, which assign IP addresses and more, and the 
> scripts are identified by the ethx name.
> 2. It is necessary to control which interface becomes eth0 as various 
> programs use the MAC address of eth0 to identify the computer. In my 
> case that is "lmhostid" and all the FLEXlm software,
> as I run a license server on that machine.

[ Please don't mail tree maintainers with this sort of question. ]

[ Try using the e100 driver instead of eepro100 ;) ]

there are several answers to this solution. First of all, you can build the 
e100 driver into the kernel and use e1000 as a module, at which point the 
in-kernel driver will always load first.

second of all, you can set `alias eth0 e100` in your /etc/modules.conf and 
force that nic to be bound to the first interface.

other handwork includes manually installing the modules in the right order at 
boot time.

Cheers,

Auke

