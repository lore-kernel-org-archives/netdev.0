From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/6] Bonding simplifications and netns support
Date: Fri, 30 Oct 2009 14:12:30 -0700
Message-ID: <21200.1256937150@death.nxdomain.ibm.com>
References: <m1tyxhwxah.fsf@fess.ebiederm.org> <20091030.124153.00934819.davem@davemloft.net>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:45070 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932861AbZJ3VMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 17:12:42 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9UL6hen020853
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 15:06:43 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n9ULCgUr247688
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 15:12:42 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9ULECq5024130
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 15:14:12 -0600
In-reply-to: <20091030.124153.00934819.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: ebiederm@xmission.com (Eric W. Biederman)
>Date: Thu, 29 Oct 2009 17:16:54 -0700
>
>> I recently had it pointed out to me that the bonding driver does not
>> work in a network namespace.  So I have simplified the bonding driver
>> a bit, added support for ip link add and ip link del, and finally made
>> the bonding driver work in multiple network namespaces.
>> 
>> The most note worthy change in the patchset is the addition of support
>> in the networking core for registering a sysfs group for a device.
>> 
>> Using this in the bonding driver simplifies the code and removes a
>> userspace race between actions triggered by the netlink event and the
>> bonding sysfs attributes appearing.
>
>I've tossed patches 1-7 into net-next-2.6, thanks Eric.

	I put patches 1-7 on a recent net-next-2.6, and from a simple
"insmod bonding.ko; rmmod bonding" I'm seeing the following:

------------[ cut here ]------------
WARNING: at fs/proc/generic.c:847 remove_proc_entry+0x1a8/0x1c7()
Hardware name: IBM eserver xSeries 220 -[8645]-
remove_proc_entry: removing non-empty directory 'net/bonding', leaking at least 
'bond0'
Modules linked in: bonding(-) ipv6 microcode loop ppdev sworks_agp parport_pc tg
3 e100 agpgart parport mii libphy e1000 edd pata_serverworks [last unloaded: spe
edstep_lib]
Pid: 6216, comm: rmmod Not tainted 2.6.32-rc3-devel #19
Call Trace:
 [<c012ec9d>] warn_slowpath_common+0x60/0x90
 [<c012ed01>] warn_slowpath_fmt+0x24/0x27
 [<c01e3e55>] remove_proc_entry+0x1a8/0x1c7
 [<e0906435>] ? bond_net_exit+0x0/0xa3 [bonding]
 [<e09064c3>] bond_net_exit+0x8e/0xa3 [bonding]
 [<c02e6ee8>] unregister_pernet_gen_subsys+0x23/0x3d
 [<e0910baa>] bonding_exit+0x3a/0x66 [bonding]
 [<c015ccf3>] sys_delete_module+0x191/0x1f1
 [<c0147a30>] ? up_read+0x16/0x2a
 [<c0102a18>] ? restore_all_notrace+0x0/0x18
 [<c0353357>] ? do_page_fault+0x0/0x393
 [<c0102904>] sysenter_do_call+0x12/0x32
---[ end trace 8f3eaeee682a572c ]---

	Any thoughts?  I have not as yet investigated further.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
