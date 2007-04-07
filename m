From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Add etun driver
Date: Fri, 06 Apr 2007 23:37:03 -0600
Message-ID: <m1irc84uf4.fsf@ebiederm.dsl.xmission.com>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>
	<4616B9A5.7090800@candelatech.com>
	<m1y7l53pl8.fsf@ebiederm.dsl.xmission.com>
	<461710A7.4040108@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:52398 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbXDGFiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2007 01:38:52 -0400
In-Reply-To: <461710A7.4040108@candelatech.com> (Ben Greear's message of "Fri,
	06 Apr 2007 20:31:51 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> writes:

> I guess that will do, but then if you ever change the strings, any user-space
> that is
> depending on this will break or have to be modified with additional cruft.  It
> seems
> cleaner to me to have an ioctl or a specific place in /proc or some other
> virtual
> fs, but I can deal with it either way...

True if the name of the driver changes from etun there is an issue.

>>> Also, how do you find the peer device from user-space?  This would be very
>>> useful
>>> for anyone trying to manage these devices with a user-space program.
>>>
>>
>> Currently "ethtool -S <interface>"
>> And read the partner_ifindex.
>>
> Ok, that will work.  Again, my personal preference is for a single specific
> ioctl or proc'ish file
> to read the specific value instead of having to parse strings, but this will do.

Hmm. I guess there is string parsing to identify the index.

I guess a sysfs device attribute would work as well.

>> Further whoever generates the pair specifies the initial set of names.
>>
> Yeah, but you can't depend on knowing that in an interesting environment.

Frankly.  In an interesting environment I haven't been able to think of a
way to successfully say anything about the partner device.

The problem is that all identifiers are namespace local so the remote side
is not in the current namespace the ifindex or the device name mean nothing.

In that case the only remotely usable value I can return is the mac address
of the other side.

Eric
