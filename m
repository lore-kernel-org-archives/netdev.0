From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] sysfs directory scaling: rbtree for dirent name lookups
Date: Tue, 03 Nov 2009 14:28:32 -0800
Message-ID: <m18wen5jlb.fsf@fess.ebiederm.org>
References: <20091101163130.GA7911@kvack.org>
	<20091103035058.GA19515@kroah.com> <4AEFCA49.4020305@gmail.com>
	<20091103160715.GD23857@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59622 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755339AbZKCW2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 17:28:30 -0500
In-Reply-To: <20091103160715.GD23857@kroah.com> (Greg KH's message of "Tue\, 3 Nov 2009 08\:07\:15 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <greg@kroah.com> writes:

> On Tue, Nov 03, 2009 at 07:14:33AM +0100, Eric Dumazet wrote:
>> Greg KH a ?crit :
>> > On Sun, Nov 01, 2009 at 11:31:30AM -0500, Benjamin LaHaise wrote:
>> >> Use an rbtree in sysfs_dirent to speed up file lookup times
>> >>
>> >> Systems with large numbers (tens of thousands and more) of network 
>> >> interfaces stress the sysfs code in ways that make the linear search for 
>> >> a name match take far too long.  Avoid this by using an rbtree.
>> > 
>> > What kind of speedups are you seeing here?  And do these changes cause a
>> > memory increase due to the structure changes which outweigh the
>> > speedups?
>> > 
>> > What kind of test are you doing to reproduce this?
>> > 
>> 
>> Its curious because in my tests the biggest problems come from
>> kernel/sysctl.c (__register_sysctl_paths) consuming 80% of cpu
>> in following attempt to create 20.000 devices
>> 
>> (disable hotplug before trying this, and ipv6 too !)
>> modprobe dummy numdummies=20000
>> 
>> I believe we should address __register_sysctl_paths() scalability
>> problems too.
>
> But registering 20000 devices is a far different problem from using
> those 20000 devices :)
>
> I think the "use the device" path should be the one we care the most
> about fixing up, as that is much more common than the register path for
> all users.

Definitely.  Of the three proc sysctl and sysfs.  sysctl tends to have
the worst costs across the board.  They are all rarely used so a lot
of what gets hit when scaling are rare path events that even the most
horrible code works fine on small systems.

Usually slow registration times indicate an O(N^2) or worse data
structure for filename lookup.

Eric
