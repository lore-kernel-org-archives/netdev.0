From: Ben Greear <greearb@candelatech.com>
Subject: Locking bug in 3.0.25, IPv6.
Date: Mon, 26 Mar 2012 09:51:54 -0700
Message-ID: <4F709EAA.6040700@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33320 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932969Ab2CZQvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 12:51:54 -0400
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q2QGpsjt014699
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 09:51:54 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has anyone seen this in 3.0.25?  My kernel has some other patches
applied, but we did not see this before 3.0.24.

BUG: sleeping function called from invalid context at /home/greearb/git/linux-3.0.dev.y/mm/memory.c:3904

================================================
[ BUG: lock held when returning to user space! ]
------------------------------------------------
ip/6696 is leaving the kernel with locks still held!
1 lock held by ip/6696:
  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffffa03051c4>] rcu_read_lock+0x0/0x35 [ipv6]
in_atomic(): 0, irqs_disabled(): 0, pid: 6694, name: ip
INFO: lockdep is turned off.
Pid: 6694, comm: ip Tainted: G         C  3.0.25+ #1
Call Trace:
  [<ffffffff8103e479>] __might_sleep+0x111/0x115
  [<ffffffff810c98bf>] might_fault+0x2f/0x9e
  [<ffffffff8138698e>] ? copy_from_user+0x2a/0x2c
  [<ffffffff810c98de>] ? might_fault+0x4e/0x9e
  [<ffffffff8137cc90>] move_addr_to_user+0x21/0x8e
  [<ffffffff8137ce7c>] __sys_recvmsg+0x17f/0x21e
  [<ffffffff810634a8>] ? up_read+0x1e/0x36
  [<ffffffff810fc06e>] ? fcheck_files+0xb7/0xee
  [<ffffffff810fc191>] ? fget_light+0x35/0xac
  [<ffffffff810d0023>] ? remove_vma+0x7a/0x82
  [<ffffffff8137d620>] sys_recvmsg+0x3d/0x5b
  [<ffffffff8144f092>] system_call_fastpath+0x16/0x1b

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
