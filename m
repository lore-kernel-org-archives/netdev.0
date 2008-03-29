From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: bluetooth lockdep trace. (.25rc5-git4)
Date: Sat, 29 Mar 2008 20:45:56 +0800
Message-ID: <a8e1da0803290545r1a1652d6i506b146ccfe1dc65@mail.gmail.com>
References: <20080327162156.GA8098@codemonkey.org.uk>
	 <20080328.182021.46780895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:56957 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbYC2Mp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 08:45:57 -0400
Received: by yw-out-2324.google.com with SMTP id 5so77212ywb.1
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2008 05:45:56 -0700 (PDT)
In-Reply-To: <20080328.182021.46780895.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 29, 2008 at 9:20 AM, David Miller <davem@davemloft.net> wrote:
> From: Dave Jones <davej@codemonkey.org.uk>
>  Date: Thu, 27 Mar 2008 12:21:56 -0400
>
>  > Mar 27 08:10:57 localhost kernel: Pid: 3611, comm: obex-data-serve Not tainted 2.6.25-0.121.rc5.git4.fc9 #1
>  > Mar 27 08:10:57 localhost kernel:  [__lock_acquire+2287/3089] __lock_acquire+0x8ef/0xc11
>  > Mar 27 08:10:57 localhost kernel:  [sched_clock+8/11] ? sched_clock+0x8/0xb
>  > Mar 27 08:10:57 localhost kernel:  [lock_acquire+106/144] lock_acquire+0x6a/0x90
>  > Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] ? l2cap_sock_bind+0x29/0x108 [l2cap]
>  > Mar 27 08:10:57 localhost kernel:  [lock_sock_nested+182/198] lock_sock_nested+0xb6/0xc6
>  > Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] ? l2cap_sock_bind+0x29/0x108 [l2cap]
>  > Mar 27 08:10:57 localhost kernel:  [security_socket_post_create+22/27] ? security_socket_post_create+0x16/0x1b
>  > Mar 27 08:10:57 localhost kernel:  [__sock_create+388/472] ? __sock_create+0x184/0x1d8
>  > Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] l2cap_sock_bind+0x29/0x108 [l2cap]
>  > Mar 27 08:10:57 localhost kernel:  [kernel_bind+10/13] kernel_bind+0xa/0xd
>  > Mar 27 08:10:57 localhost kernel:  [<f8dad3d7>] rfcomm_dlc_open+0xc8/0x294 [rfcomm]
>  > Mar 27 08:10:57 localhost kernel:  [lock_sock_nested+187/198] ? lock_sock_nested+0xbb/0xc6
>  > Mar 27 08:10:57 localhost kernel:  [<f8dae18c>] rfcomm_sock_connect+0x8b/0xc2 [rfcomm]
>  > Mar 27 08:10:57 localhost kernel:  [sys_connect+96/125] sys_connect+0x60/0x7d
>  > Mar 27 08:10:57 localhost kernel:  [__lock_acquire+1370/3089] ? __lock_acquire+0x55a/0xc11
>  > Mar 27 08:10:57 localhost kernel:  [sys_socketcall+140/392] sys_socketcall+0x8c/0x188
>  > Mar 27 08:10:57 localhost kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
>
>  rfcomm connect locks the socket, then does rfcomm_dlc_open which in
>  turn can do a l2cap_sock_bind on a seperate second socket which in
>  turn locks that second socket.
>
>  Both of these sockets are AF_BLUETOOTH family, so lockdep thinks there
>  is a locking conflict, even though what is happening here is perfectly
>  fine since the two sockets are totally different AF_BLUETOOTH
>  sub-types.
>
>  Bluetooth will need to use sock_lock_init_class_and_name() and
>  lock sub-classes per AF_BLUETOOTH socket sub-type.
>
>  David, could you or someone else work on this?

Hi, I known this problem and did some work on this, but not finished
due to lacking time.

I will continue working on it when I'm free.

Regards
dave
>
>  Thanks!
>
>
