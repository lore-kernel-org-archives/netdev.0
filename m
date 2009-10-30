From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/6] Bonding simplifications and netns support
Date: Fri, 30 Oct 2009 03:39:53 -0700
Message-ID: <m1d445qi6e.fsf@fess.ebiederm.org>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
	<20091029.232523.66969302.davem@davemloft.net>
	<m11vkltj4z.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45823 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757007AbZJ3Kjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 06:39:52 -0400
In-Reply-To: <m11vkltj4z.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Fri\, 30 Oct 2009 00\:50\:52 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> David Miller <davem@davemloft.net> writes:
>
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Thu, 29 Oct 2009 17:16:54 -0700
>>
>>> I recently had it pointed out to me that the bonding driver does not
>>> work in a network namespace.  So I have simplified the bonding driver
>>> a bit, added support for ip link add and ip link del, and finally made
>>> the bonding driver work in multiple network namespaces.
>>> 
>>> The most note worthy change in the patchset is the addition of support
>>> in the networking core for registering a sysfs group for a device.
>>> 
>>> Using this in the bonding driver simplifies the code and removes a
>>> userspace race between actions triggered by the netlink event and the
>>> bonding sysfs attributes appearing.
>>
>> I have no objections to these patches, but I'd like the bonding
>> folks to have a chance to look at it before I apply to net-next-2.6
>
> Sure.
>
>> One question though, are you sure this clever extra slot scheme
>> in patch #1 works for, f.e., a bond of wireless devices?  It seems
>> like it would work out, but I wanted to ask to make sure you
>> considered that case.
>
> I have not explicitly tested wireless devices.  But I did make certain
> we have enough slots in the array.  I did write the code so that a
> device driver can use at most one slot (the next slot gets
> unconditionally stomped).  Other that it is just shifting of where
> sysfs_create_group and sysfs_remove_group are called.  So I would
> be totally stunned if bonded wireless devices started failing from
> this change.

Bah.  The argument is better than that.  The bond_group that I am
messing with only applies to the virtual bonding devices.  The virtual
bond device is never a wireless device.  So we will never see in
practice all three groups on the same network device.

Eric
