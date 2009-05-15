From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: removing a bonding_master (ver 3.3.0 driver) results in leftover kernel process?
Date: Fri, 15 May 2009 09:19:10 -0700
Message-ID: <883.1242404350@death.nxdomain.ibm.com>
References: <9a2da8520905141838x3081f96l190e230823d79098@mail.gmail.com>
Cc: netdev@vger.kernel.org
To: Deepjyoti Kakati <dkakati73@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:43259 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbZEOQTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2009 12:19:10 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4FGErHQ001657
	for <netdev@vger.kernel.org>; Fri, 15 May 2009 12:14:54 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4FGJ9Io253374
	for <netdev@vger.kernel.org>; Fri, 15 May 2009 12:19:09 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4FGH63p014703
	for <netdev@vger.kernel.org>; Fri, 15 May 2009 12:17:09 -0400
In-reply-to: <9a2da8520905141838x3081f96l190e230823d79098@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Deepjyoti Kakati <dkakati73@gmail.com> wrote:

>using bonding driver ver 3.3.0 (on fedora 10)
>
>I am using the sysfs  to add a couple of interfaces as bonding_masters
>and repeatedly removing and adding  during test cycles as in:
>
>echo +bond_data > /sys/class/net/bonding_masters
>..add slave eth ports..
>...do work...
>......
>echo -bond_data > /sys/class/net/bonding_masters
>
>every time I add it, seems to start a kernel process named after that
>bond interface
>but when removing, that proc is not killed.
>
>it builds up after a period of testing and even kill -9/kill -15 isnt
>killing them
>
>Am I doing something wrong ? Can I prevent the buildup of these unwanted
>processes that are presumably consuming resources ?

	Upgrade your kernel, this problem was fixed by the following:

commit a434e43f3d844192bc23bd7b408bac979c40efe7
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Thu Oct 30 17:41:15 2008 -0700

    bonding: Clean up resource leaks
    
    This patch reworks the resource free logic performed at the time
    a bonding device is released.  This (a) closes two resource leaks, one
    for workqueues and one for multicast lists, and (b) improves commonality
    of code between the "destroy one" and "destroy all" paths by performing
    final free activity via destructor instead of explicitly (and differently)
    in each path.
    
    "Sean E. Millichamp" <sean@bruenor.org> reported the workqueue
    leak, and included a different patch.
    
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>


	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
