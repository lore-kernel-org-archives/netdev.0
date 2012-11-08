From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2 (2012-11-08) and tunnel mode vti problems
Date: Thu, 8 Nov 2012 16:33:10 +0100
Message-ID: <20121108163310.48c67965@s6510.linuxnetplumber.net>
References: <20121108121502.GC2838@puettmann.net>
	<20121108140717.72bac4e7@s6510.linuxnetplumber.net>
	<20121108131305.GD2838@puettmann.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Saurabh Mohan <saurabh.mohan@vyatta.com>, netdev@vger.kernel.org
To: Ruben Herold <ruben@puettmann.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52118 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753767Ab2KHPdS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 10:33:18 -0500
In-Reply-To: <20121108131305.GD2838@puettmann.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I have here some problems with the newest iproute2 taken from git today.
> I will play around with the new vti mode. 
> 
> First problem ist after loading the ip_vti module I got an ioctl error
> on ip tunnel show:
> 
> ---------------------------------------------------------------------
> root@ipsec0:[~] > ip -V
> ip utility, iproute2-ss121108
> root@ipsec0:[~] > uname -a
> Linux ipsec0 3.6.6 #1 SMP Tue Nov 6 16:21:05 CET 2012 i686 GNU/Linux
> root@ipsec0:[~] > modprobe ip_vti 
> root@ipsec0:[~] > ip tunnel show
> ip_vti0: ioctl 89f4 failed: Invalid argument
> ip_vti0: ip/ip  remote any  local any  ttl inherit  nopmtudisc key 0
> root@ipsec0:[~] > 
> --------------------------------------------------------------------

Found the cause of the problem. It is a kernel issue.

The kernel implementation of VTI uses same flag bit as SIT tunnel,
and 'ip tunnel show' is using SIT flag to decide whether to look
up sit tunnel parameters, which fails on VTI.

It is a bug introduced in ioctl definition for VTI. Not sure
what the best way to fix it is? Add more kludge code in ip command,
or change definition of flag bit, and risk userspace ABI incompatibility.

Also, there is the issue that i_flags is a confusing mix of
network byte order bits or'd with host byte order bits. The initial
definition of SIT was broken long, long ago.


Copying netdev list.
