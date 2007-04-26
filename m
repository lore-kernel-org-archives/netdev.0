From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [RFC][PATCH -mm take4 2/6] support multiple logging
Date: Thu, 26 Apr 2007 13:02:04 +0900
Message-ID: <4630243C.4010402@bx.jp.nec.com>
References: <462605DC.2080804@bx.jp.nec.com>	<462609D1.50300@bx.jp.nec.com>	<20070419210813.a599c54f.akpm@linux-foundation.org>	<46288D11.4000801@bx.jp.nec.com>	<20070420111526.01ad7f4c.akpm@linux-foundation.org>	<462DBC64.9070102@bx.jp.nec.com>	<20070424012902.1089bc02.akpm@linux-foundation.org> <20070424082117.354341d3@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, mpm@selenic.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:34723 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695AbXDZECl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 00:02:41 -0400
In-Reply-To: <20070424082117.354341d3@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>> Well..  before you can finish this work we need to decide upon what the
>>>> interface to userspace will be.
>>>>
>>>> - The miscdev isn't appropriate
>>>>
>>> Why isn't miscdev appropriate? 
>>> We just shouldn't use miscdev for networking conventionally?
>>>
>> Yes it's rather odd, especially for networking.
>>
>> What does the miscdev _do_ anyway?  Is it purely a target for the ioctls?

Yes, I purely use miscdev for the ioctls.

I want to use sysfs and ioctl to implement the dynamic configurabillity.
The sysfs shows/changes netconsole configurations(IP address, port and so on).
A userland application using the ioctl adds/removes netconsole port.

I thought that the dynamic configurability could be realized without a 
userland application. in the kernel only.
(e.g. only sysfs, no userland application)
But I think we need the function to automatically resolve the destination 
MAC address from IP address because of the resolving cost and 
I should implement a userland application, not netconsole kernel module.
The netconsle will become more useful by implementing the above function.

> Some other speculations:
> 1. Would it be possible to add ioctl's to /dev/console? This would be more in
>     keeping with older Unix style model.
> 
> 2. Using sysfs makes sense if there is a device object that exists to
>    add the sysfs attributes to.
> 
> 3. Procfs is handy for summary type tables.
> 
> 4. Netlink does feel like overkill for this. Although newer generic netlink
>    makes it easier.

If I use sysfs, Is it proper location that adds each attributes of netconsole 
port in "/sys/class/misc/netconsole/port[0-9]*", or another locations in /sys/?

Stephen Hemminger said "The configuration of netconsole's looks like the 
configuration of routes".
I think so too.
So I think ioctl commands for adding/removing port and the following userland 
application like route(8) command by using the ioctl.

e.g.
1. add port
# netconfig add 192.168.0.10 6666

2. remove port
# netconfig remove 1

3. show port info
# netconfig
id status  Source IP   Source Port Destination IP Destination Port Destination MAC
1  enable  192.168.0.1 6665        192.168.0.10   6666             00:11:22:33:44:55
2  disable 192.168.0.1 6665        192.168.0.20   6666             00:11:22:33:44:66

route(8) command uses ioctl for Netlink.
But, I'm going to implement ioctl's to /dev/console because of the above comments.

Thank you for your comments.
Any comments very welcome.
-- 
Keiichi KII
NEC Corporation OSS Promotion Center
E-mail: k-keiichi@bx.jp.nec.com

