From: Dave Jones <davej@codemonkey.org.uk>
Subject: bluetooth lockdep trace. (.25rc5-git4)
Date: Thu, 27 Mar 2008 12:21:56 -0400
Message-ID: <20080327162156.GA8098@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from testure.choralone.org ([194.9.77.134]:45409 "EHLO
	testure.choralone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756352AbYC0QWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 12:22:04 -0400
Received: from c-66-30-206-50.hsd1.ma.comcast.net ([66.30.206.50] helo=gelk.kernelslacker.org)
	by testure.choralone.org with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <davej@gelk.kernelslacker.org>)
	id 1Jeunf-0007jz-Sx
	for netdev@vger.kernel.org; Thu, 27 Mar 2008 16:18:00 +0000
Received: from davej by gelk.kernelslacker.org with local (Exim 4.68)
	(envelope-from <davej@gelk.kernelslacker.org>)
	id 1JeurU-0006AA-KK
	for netdev@vger.kernel.org; Thu, 27 Mar 2008 12:21:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This came in this morning from a user of a slightly old kernel now, but
I don't see anything obvious post rc5 that would fix this.

	Dave

Mar 27 08:10:57 localhost kernel: =============================================
Mar 27 08:10:57 localhost kernel: [ INFO: possible recursive locking detected ]
Mar 27 08:10:57 localhost kernel: 2.6.25-0.121.rc5.git4.fc9 #1
Mar 27 08:10:57 localhost kernel: ---------------------------------------------
Mar 27 08:10:57 localhost kernel: obex-data-serve/3611 is trying to acquire lock:
Mar 27 08:10:57 localhost kernel:  (sk_lock-AF_BLUETOOTH){--..}, at: [<f8bd9321>] l2cap_sock_bind+0x29/0x108 [l2cap]
Mar 27 08:10:57 localhost kernel: 
Mar 27 08:10:57 localhost kernel: but task is already holding lock:
Mar 27 08:10:57 localhost kernel:  (sk_lock-AF_BLUETOOTH){--..}, at: [<f8dae136>] rfcomm_sock_connect+0x35/0xc2 [rfcomm]
Mar 27 08:10:57 localhost kernel: 
Mar 27 08:10:57 localhost kernel: other info that might help us debug this:
Mar 27 08:10:57 localhost kernel: 2 locks held by obex-data-serve/3611:
Mar 27 08:10:57 localhost kernel:  #0:  (sk_lock-AF_BLUETOOTH){--..}, at: [<f8dae136>] rfcomm_sock_connect+0x35/0xc2 [rfcomm]
Mar 27 08:10:57 localhost kernel:  #1:  (rfcomm_mutex){--..}, at: [<f8dad337>] rfcomm_dlc_open+0x28/0x294 [rfcomm]
Mar 27 08:10:57 localhost kernel: 
Mar 27 08:10:57 localhost kernel: stack backtrace:
Mar 27 08:10:57 localhost kernel: Pid: 3611, comm: obex-data-serve Not tainted 2.6.25-0.121.rc5.git4.fc9 #1
Mar 27 08:10:57 localhost kernel:  [__lock_acquire+2287/3089] __lock_acquire+0x8ef/0xc11
Mar 27 08:10:57 localhost kernel:  [sched_clock+8/11] ? sched_clock+0x8/0xb
Mar 27 08:10:57 localhost kernel:  [lock_acquire+106/144] lock_acquire+0x6a/0x90
Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] ? l2cap_sock_bind+0x29/0x108 [l2cap]
Mar 27 08:10:57 localhost kernel:  [lock_sock_nested+182/198] lock_sock_nested+0xb6/0xc6
Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] ? l2cap_sock_bind+0x29/0x108 [l2cap]
Mar 27 08:10:57 localhost kernel:  [security_socket_post_create+22/27] ? security_socket_post_create+0x16/0x1b
Mar 27 08:10:57 localhost kernel:  [__sock_create+388/472] ? __sock_create+0x184/0x1d8
Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] l2cap_sock_bind+0x29/0x108 [l2cap]
Mar 27 08:10:57 localhost kernel:  [kernel_bind+10/13] kernel_bind+0xa/0xd
Mar 27 08:10:57 localhost kernel:  [<f8dad3d7>] rfcomm_dlc_open+0xc8/0x294 [rfcomm]
Mar 27 08:10:57 localhost kernel:  [lock_sock_nested+187/198] ? lock_sock_nested+0xbb/0xc6
Mar 27 08:10:57 localhost kernel:  [<f8dae18c>] rfcomm_sock_connect+0x8b/0xc2 [rfcomm]
Mar 27 08:10:57 localhost kernel:  [sys_connect+96/125] sys_connect+0x60/0x7d
Mar 27 08:10:57 localhost kernel:  [__lock_acquire+1370/3089] ? __lock_acquire+0x55a/0xc11
Mar 27 08:10:57 localhost kernel:  [sys_socketcall+140/392] sys_socketcall+0x8c/0x188
Mar 27 08:10:57 localhost kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Mar 27 08:10:57 localhost kernel:  =======================

-- 
http://www.codemonkey.org.uk
