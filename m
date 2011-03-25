From: Brian Haley <brian.haley@hp.com>
Subject: Re: disabling ipv6 (when ipv6 module is already loaded or built in)
Date: Fri, 25 Mar 2011 16:22:08 -0400
Message-ID: <4D8CF970.7020601@hp.com>
References: <201103251817.04583.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:29257 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384Ab1CYUWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 16:22:10 -0400
In-Reply-To: <201103251817.04583.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/2011 01:17 PM, Arkadiusz Miskiewicz wrote:
> 
> Hi,
> 
> There are two options for disabling some ipv6 functionality in ipv6 module - 
> disable and disable_ipv6. The second option is also available as sysctl and 
> can be switched runtime.
> 
> First is nicer because it also prevents apps from creating sockets by using 
> socket(AF_INET6, ...). Various apps use AF_INET6 socket creation to deterine 
> if ipv6 is supported on the system. Unfortunately "disable" one doesn't exist 
> as sysctl and this is a problem.
> 
> Is it possible to make "disable" sysctl option, too? Currently there is no 
> runtime way to disable ipv6 (or I'm unaware of such way).

Not really, the module parameter causes IPv6 to be loaded just enough to
allow other modules that rely on it to load, but it never registers
any of the protocol handlers, sysctls, tables, etc. to make it usable.
And the IPv6 module isn't unloadable, so you have to reboot to change
this setting.

When there are no addresses it's not very usable since you can't send
out packets...

-Brian
