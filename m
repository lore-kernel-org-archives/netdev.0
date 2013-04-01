From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net-sysfs: make flags symmetrical
Date: Mon, 01 Apr 2013 14:32:44 -0700
Message-ID: <5159FCFC.1000407@candelatech.com>
References: <20130401115315.1f8e4213@nehalam.linuxnetplumber.net> <5159EB2B.7070504@candelatech.com> <20130401.171858.2177408540657698898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60697 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757104Ab3DAVcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 17:32:47 -0400
In-Reply-To: <20130401.171858.2177408540657698898.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2013 02:18 PM, David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Mon, 01 Apr 2013 13:16:43 -0700
>
>> I am depending on this feature.  There is no other way I know
>> of to determine if an interface is actually currently acting
>> PROMISC or not.
>
> Netlink interface dump, SIOGIFCONF, etc. should provide this
> information in one form or another.

 From looking elsewhere in my code, I think you are right, at least
about netlink.

The IFLA_PROMISCUITY field seems to give good results, but if you try
to parse the ifinfomsg->ifi_flags method, it may lie to you
and tell you the netdev is not PROMISSC when it really is PROMISC.

I haven't tried SIOGIFCONF...

Either way, I'd prefer the sysfs flags stay as is...while I have
the netlink interface coded up in my app, it is not exactly light
programming and other tools may find it much easier to use
the sysfs flags.  And, since I've been using the sysfs flags
to double-check netlink in some cases, I'll have to add yet more
hacks if this compatibility is broken in newer kernels...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
