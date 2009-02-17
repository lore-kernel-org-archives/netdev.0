From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Tue, 17 Feb 2009 13:06:28 -0800
Message-ID: <16929.1234904788@death.nxdomain.ibm.com>
References: <alpine.LFD.2.00.0902131413120.3179@localhost.localdomain> <20090217095232.5da06b9f@werewolf.home> <200902172001.41804.arvidjaar@mail.ru> <200902172117.22671.arvidjaar@mail.ru> <499B19AF.1000003@hp.com>
Cc: Andrey Borzenkov <arvidjaar@mail.ru>,
	=?ISO-8859-1?Q?=22J=2EA=2E_Magall?=@us.ibm.com,
	=?ISO-8859-1?Q?=F3n=22?= <jamagallon@ono.com>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	bonding-devel@lists.sourceforge.net
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:60582 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400AbZBQVGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2009 16:06:24 -0500
In-reply-to: <499B19AF.1000003@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote:

>Andrey Borzenkov wrote:
[...]
>> This hard dependency was apparently introduced by this commit:
>> 
>> commit 305d552accae6afb859c493ebc7d98ca3371dae2
>> Author: Brian Haley <brian.haley@hp.com>
>> Date:   Tue Nov 4 17:51:14 2008 -0800
>> 
>>     bonding: send IPv6 neighbor advertisement on failover
>
>I initially had bonding IPv6 support as a Kconfig option, but it was 
>decided it would be cleaner if it just got built-in whenever CONFIG_IPV6 
>was set like SCTP, with the assumption you might want it.
>
>Is it a common configuration to not allow a module to load like you're 
>doing in modprobe.conf?  I don't know how hard it would be to rip this 
>out into it's own bonding_ipv6.ko module, simply turning-off CONFIG_IPV6 
>seems better.

	I'm not sure either of those really helps.  Distro kernels are
built with CONFIG_IPV6 (and would have the CONFIG_BONDING_IPV6_DINGUS
enabled as well), so the common case users would have it enabled, too.

	Putting the ipv6 bits into a different module might not help,
either, because the "core" bonding code would still have the call to the
ipv6 functions.  Unless there's some magic way to somehow know at
runtime whether or not the ipv6 module is loaded, and only try to
resolve those symbols if ipv6 is loaded.  That seems complicated.

	To answer your question, I have come across this (aliasing ipv6
to nothing in modprobe.conf to disable IPv6) from time to time, but
didn't think of it when the NA code was added to bonding.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
