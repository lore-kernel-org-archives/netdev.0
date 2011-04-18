From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v2 00/27] HFI: minimal device driver/ip driver
Date: Sun, 17 Apr 2011 23:21:32 -0400
Message-ID: <1303096919-7367-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:54994 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418Ab1DRDW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:22:27 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3I30JEY027668
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:00:19 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3I3MPU8324880
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:26 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3I3MPR2001041
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

The HFI ("Host Fabric Interface") network interface is the internal cluster
fabric of IBM's PERCS supercomputer. The hardware design is under US export
control, so we cannot release hardware specs. There is a writeup of
publically available information about the system available here:
http://sourceforge.net/projects/hfidevicedriver/files/docs/hfi_general_desc_v2.1.txt

hfi_core contains the resource management to set up communications paths for
network traffic. Calls are provided for kernel drivers, and also for setting
up direct user-space access to HFI windows.
hfi_ip contains the kernel network driver.

The driver has been running in the lab for several months. The full patch is
around 22000 lines, so we've split out a minimal device/network driver that
can send and receive through the simplest path.  Once that much gets accepted
we'll start adding on to it.

Patches are against net-next-2.6.

Jim Dykman

Changelog:
----------
v2:
	Remove return; at the end of void funcs
	hfidd_free_adapter: p_acs = NULL unneccesssary, remove
	remove net_stats, and use netdev->stats, remove hf_get_stats
	rename network driver to hfi_ip
	hf_inet_event: NETDEV_UP needs to check event is for us, check 
		netdev->netdev_ops == ours
	change printk()s to netdev_err() and friends
	hf_net_close: remove redundant CLOSE check
	hf_change_mtu: minimum mtu should be 68
	remove NETIF_F_SG flag
	hf_init_netdev: Use ERR_PTR
	hf_init_module: %ld / formatting
			pass up return code from failed call 
	use unsigned int instead of u32 for bit fields <32 bits
	use struct ethhdr instead of hf_hwhdr 
	hf_get_sset_count: default return -EINVAL not -EOPNOTSUPP
	Remove "hfidd_callback_event: enter" message that printed on every 
		recv interrupt
	hfidd_destroy_devices: hfidd_rmdev() after hfidd_free_adapter() so 
		dev_printk doesn't oops on rmmod
