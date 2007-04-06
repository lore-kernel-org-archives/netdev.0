From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net: Add etun driver
Date: Fri, 06 Apr 2007 14:20:37 -0700
Message-ID: <4616B9A5.7090800@candelatech.com>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:57146 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933054AbXDFVVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 17:21:53 -0400
In-Reply-To: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> etun is a simple two headed tunnel driver that at the link layer looks
> like ethernet.  It's target audience is communicating between network
> namespaces but it is general enough it has other valid uses as well.
>
> Ben Greear implemented a similar device called redir-dev, for network
> emulation.
>
> OpenVZ has a similar device that goes by the name veth.
>
> I didn't want to mess with ioctls or weird non-general network
> interfaces for creating devices, so I used sysfs as my control
> mechanism.
>
> To create a pair of devices called veth0 and veth1:
>   echo -n 'veth0,veth1' > /sys/module/etun/parameters/newif
>
> To destroy a pair of devices:
>   echo -n 'veth0' > /sys/module/etun/parameters/delif
>   
Is there any way to tell for certain if an interface is a etun or not?  
Maybe
a file could be found (or not) in sysfs somewhere?

Also, how do you find the peer device from user-space?  This would be 
very useful
for anyone trying to manage these devices with a user-space program.

When you are creating new devices, I think you should check to make
sure there isn't already a device with that name.

In general though, I look forward to this being in the kernel so I can drop
my redirect device code from my out-of-tree patch.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


