From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: Regarding VRF support in Linux Kernel
Date: Wed, 22 Jun 2016 15:03:23 -0700
Message-ID: <576B0B2B.1070509@infradead.org>
References: <CADAe=++ATxxEeKiUC6MUSCmXiauvB=6ZFCuuwd2h6ZOQU99p5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Ajith Adapa <adapa.ajith@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:48125 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbcFVWD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 18:03:26 -0400
In-Reply-To: <CADAe=++ATxxEeKiUC6MUSCmXiauvB=6ZFCuuwd2h6ZOQU99p5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/22/16 14:05, Ajith Adapa wrote:
> Hi,
> 
> I am following the steps present in
> (https://www.kernel.org/doc/Documentation/networking/vrf.txt) and
> trying to create IPv4 VRF in latest Fedora 24 distribution with 4.5
> Linux kernel.
> 
> [root@localhost ip]# uname -a
> Linux localhost.localdomain 4.5.5-300.fc24.x86_64 #1 SMP Thu May 19
> 13:05:32 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
> 
> I am getting operation not supported error as shown below
> 
> # ip link add vrf-blue type vrf table 10
> RTNETLINK answers: Operation not supported
> 
> Is there any CONFIG option to enable VRF in Linux kernel ?

Yes, in drivers/net/Kconfig:

config NET_VRF
	tristate "Virtual Routing and Forwarding (Lite)"
	depends on IP_MULTIPLE_TABLES
	depends on NET_L3_MASTER_DEV
	depends on IPV6 || IPV6=n
	depends on IPV6_MULTIPLE_TABLES || IPV6=n
	---help---
	  This option enables the support for mapping interfaces into VRF's. The
	  support enables VRF devices.




-- 
~Randy
