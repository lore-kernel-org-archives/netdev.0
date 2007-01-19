From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding: sysfs patch broke module renaming
Date: Fri, 19 Jan 2007 14:53:05 -0800
Message-ID: <200701192253.l0JMr522009426@death.nxdomain.ibm.com>
References: <45B0C893.1090809@trash.net>
Cc: mitch.a.williams@intel.com, linville@tuxdriver.com,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:48643 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932795AbXASWxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 17:53:10 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0JMr8qm015909
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 17:53:08 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0JMr84v356180
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 15:53:08 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0JMr60h007789
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 15:53:07 -0700
To: Patrick McHardy <kaber@trash.net>
In-reply-to: <45B0C893.1090809@trash.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:

>The sysfs patch broke using multiple instances of the bonding module
>through module renaming (modprobe -o). In recent kernels it fails
>with -EEXIST when trying to add the bonding_masters file for the
>second time, in older kernels (where sysfs_add_file didn't check
>for duplicates) it will crash when unloading the modules.

	Ok, I see what the problem is; it's got to do with out device
creation was changed at some point for the sysfs stuff that broke the
multiple load logic.  I don't think it has to do with the sysfs_add_file
duplicate check business; I can see the error in how bond_create() is
called in the new (post-sysfs) stuff, although I haven't tracked it down
to a particular changeset.

	There'a also a separate error handling bug I see in
bond_create() that I don't even get to because it bails out first.

	Anyway, let me see what I can work out to fix this up.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
