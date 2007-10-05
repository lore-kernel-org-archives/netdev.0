From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: e1000e oops, sysfs related?
Date: Fri, 05 Oct 2007 15:21:41 -0600
Message-ID: <m1zlyxgsuy.fsf@ebiederm.dsl.xmission.com>
References: <20071005131115.GA31453@stro.at> <47066838.7030209@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: maximilian attems <max@stro.at>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@suse.de>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35013 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbXJEVWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 17:22:16 -0400
In-Reply-To: <47066838.7030209@intel.com> (Auke Kok's message of "Fri, 05 Oct
	2007 09:37:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Kok, Auke" <auke-jan.h.kok@intel.com> writes:

> maximilian attems wrote:
>> Linux tau 2.6.23-rc8-mm2-686 #1 SMP Wed Oct 3 23:56:32 CEST 2007 i686
>> GNU/Linux
>> 
>> eth0 renamed to eth1
>> sysfs: duplicate filename 'eth1' can not be created
>> WARNING: at fs/sysfs/dir.c:433 sysfs_add_one()
>>  [<c0104f9c>] dump_trace+0x68/0x1d5
>>  [<c0105121>] show_trace_log_lvl+0x18/0x2c
>>  [<c0105b9b>] show_trace+0xf/0x11
>>  [<c0105c81>] dump_stack+0x12/0x14
>>  [<c01ac02e>] sysfs_add_one+0x54/0xb8
>>  [<c01acc2a>] sysfs_create_link+0xb3/0x125
>>  [<c023c05f>] device_rename+0x13d/0x196
>>  [<c025a970>] dev_change_name+0x137/0x205
>>  [<c025b12c>] dev_ioctl+0x357/0x44f
>>  [<c017b05f>] do_ioctl+0x1f/0x62
>>  [<c017b2d9>] vfs_ioctl+0x237/0x249
>>  [<c017b330>] sys_ioctl+0x45/0x5d
>>  [<c0103eda>] syscall_call+0x7/0xb
>>  [<b7edbde4>] 0xb7edbde4
>>  =======================
>> net eth1: device_rename: sysfs_create_symlink failed (-17)
>> 

> I'm seeing the same when removing/inserting network drivers frequently, ixgbe
> does
> the same thing: (git://davem/net-2.6.24)
>
> ixgbe 0000:01:00.0: (PCI Express:2.5Gb/s:Width x8) 00:1a:64:3b:81:c3
> ixgbe 0000:01:00.0: MAC: 0, PHY: 0, PBA No: d95854-003
> ixgbe 0000:01:00.0: Intel(R) 10 Gigabit Network Connection
> net eth2: device_rename: sysfs_create_symlink failed (-17)
>
> but I can't make it throw a stack trace.
>
> perhaps one of the sysfs knowledgeable people can take a look at this. We might
> be
> doing something wrong in e1000e / ixgbe at setup time, but I have no idea what.

To reach this path you need to run the equivalent of:
ip link set eth0 name eth1

I have seen this a bit and my memory is that the error is generally
harmless.  It is trying to create a symlink with the same name as the
directory or something like that.  Which makes with one setting of
CONFIG_SYSFS_DEPRECATED but not the other.

So I don't believe this is a driver bug, and I suspect the renames
come from using something like /etc/mactab which forces ethernet
devices with specific mac addresses to specific ethernet device
names.

With whatever is sitting in my development tree I'm pretty certain
this error isn't present.  I don't recall if I did anything specific
to fix this though.  In particular I don't recall if this still
happens with gregkh's queued sysfs patches applied.

Eric
