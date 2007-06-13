From: Patrick McHardy <kaber@trash.net>
Subject: Re: cannot set IP for ethernet
Date: Wed, 13 Jun 2007 13:14:02 +0200
Message-ID: <466FD17A.8040900@trash.net>
References: <200706121441.13561.oliver@neukum.org> <466EA861.2070509@trash.net> <200706131039.32011.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60930 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758054AbXFMLRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 07:17:16 -0400
In-Reply-To: <200706131039.32011.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> Am Dienstag, 12. Juni 2007 schrieb Patrick McHardy:
> 
>>Oliver Neukum wrote:
>>
>>>with 2.6.22-rc4-git2 I am getting errors when setting IP for ethernet
>>>interfaces:
>>>
>>>ioctl(4, SIOCSIFADDR, 0x7fff94931600)   = -1 ENOBUFS (No buffer space available)
>>>
>>>The error is independant of the interface. It happens to all interfaces.
>>>There's nothing in the syslog.
>>>
>>>valisk:/home/oliver # uname -a
>>>Linux valisk 2.6.22-rc4-git2-default #3 SMP Tue Jun 12 13:27:54 CEST 2007 x86_64 x86_64 x86_64 GNU/Linux
>>
>>
>>This can happen if the initial inetdev allocation when the netdevice is
>>registered fails. I think it would make sense to try to allocate again
>>when adding addresses in that case, otherwise there is no way of
>>recovery other than unregistering and registering the device again.
> 
> 
> With your patch the problem has gone away. Is there a way to especially
> stress the system in that regard?


Its a failed allocation at NETDEV_REGISTER time. I guess you could
keep unloading + reloading the driver module to try to reproduce it.
