From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [Bluetooth] recursive locking in
	l2cap_sock_accept/bt_accept_dequeue
Date: Sun, 17 Sep 2006 14:18:26 +0200
Message-ID: <1158495506.6665.0.camel@localhost>
References: <20060917113646.GA27178@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:17062 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S932253AbWIQMSM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Sep 2006 08:18:12 -0400
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20060917113646.GA27178@ee.oulu.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pekka,

> Got this from a 2.6.18rc7-based fedora-devel kernel:
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 2.6.17-1.2647.fc6 #1
> ---------------------------------------------
> sdpd/4955 is trying to acquire lock:
>  (sk_lock-AF_BLUETOOTH){--..}, at: [<f0cea241>] bt_accept_dequeue+0x26/0xc6 [bluetooth]
> 
> but task is already holding lock:
>  (sk_lock-AF_BLUETOOTH){--..}, at: [<f0b90088>] l2cap_sock_accept+0x41/0x11e [l2cap]
> 
> other info that might help us debug this:
> 1 lock held by sdpd/4955:
>  #0:  (sk_lock-AF_BLUETOOTH){--..}, at: [<f0b90088>] l2cap_sock_accept+0x41/0x11e [l2cap]
> 
> stack backtrace:
>  [<c04051ee>] show_trace_log_lvl+0x58/0x171
>  [<c0405802>] show_trace+0xd/0x10
>  [<c040591b>] dump_stack+0x19/0x1b
>  [<c043b9e1>] __lock_acquire+0x778/0x99c
>  [<c043c176>] lock_acquire+0x4b/0x6d
>  [<c05b27e3>] lock_sock+0xac/0xbc
>  [<f0cea241>] bt_accept_dequeue+0x26/0xc6 [bluetooth]
>  [<f0b90129>] l2cap_sock_accept+0xe2/0x11e [l2cap]
>  [<c05b1bd7>] sys_accept+0xd8/0x179
>  [<c05b1d1f>] sys_socketcall+0xa7/0x186
>  [<c0403faf>] syscall_call+0x7/0xb
> DWARF2 unwinder stuck at syscall_call+0x7/0xb
> Leftover inexact backtrace:
>  [<c0405802>] show_trace+0xd/0x10
>  [<c040591b>] dump_stack+0x19/0x1b
>  [<c043b9e1>] __lock_acquire+0x778/0x99c
>  [<c043c176>] lock_acquire+0x4b/0x6d
>  [<c05b27e3>] lock_sock+0xac/0xbc
>  [<f0cea241>] bt_accept_dequeue+0x26/0xc6 [bluetooth]
>  [<f0b90129>] l2cap_sock_accept+0xe2/0x11e [l2cap]
>  [<c05b1bd7>] sys_accept+0xd8/0x179
>  [<c05b1d1f>] sys_socketcall+0xa7/0x186
>  [<c0403faf>] syscall_call+0x7/0xb

what where you doing when this happened?

Regards

Marcel


