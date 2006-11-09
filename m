From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/9] lockdep: annotate sk_lock nesting in AF_BLUETOOTH
Date: Wed, 08 Nov 2006 22:44:51 -0800 (PST)
Message-ID: <20061108.224451.110015912.davem@davemloft.net>
References: <200611090351.kA93p5R3003687@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a.p.zijlstra@chello.nl, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8848
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1754754AbWKIGop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 01:44:45 -0500
To: akpm@osdl.org
In-Reply-To: <200611090351.kA93p5R3003687@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Wed, 08 Nov 2006 19:51:05 -0800

> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 2.6.18-1.2726.fc6 #1
> ---------------------------------------------
> hidd/2271 is trying to acquire lock:
>  (sk_lock-AF_BLUETOOTH){--..}, at: [<f8d16241>] bt_accept_dequeue+0x26/0xc6
> [bluetooth]
> 
> but task is already holding lock:
>  (sk_lock-AF_BLUETOOTH){--..}, at: [<f8bce088>] l2cap_sock_accept+0x41/0x11e [l2cap]
> 
> other info that might help us debug this:
> 1 lock held by hidd/2271:
>  #0:  (sk_lock-AF_BLUETOOTH){--..}, at: [<f8bce088>]
> l2cap_sock_accept+0x41/0x11e [l2cap]
> 
> stack backtrace:
>  [<c04051ed>] show_trace_log_lvl+0x58/0x16a
>  [<c04057fa>] show_trace+0xd/0x10
>  [<c0405913>] dump_stack+0x19/0x1b
>  [<c043b7dc>] __lock_acquire+0x6ea/0x90d
>  [<c043bf70>] lock_acquire+0x4b/0x6b
>  [<c05b203b>] lock_sock+0xac/0xbc
>  [<f8d16241>] bt_accept_dequeue+0x26/0xc6 [bluetooth]
>  [<f8bce129>] l2cap_sock_accept+0xe2/0x11e [l2cap]
>  [<c05b142e>] sys_accept+0xd8/0x179
>  [<c05b1576>] sys_socketcall+0xa7/0x186
>  [<c0403fb7>] syscall_call+0x7/0xb
> 
> classical case of nesting; bt_accept_dequeue() locks the children of the object
> locked by l2cap_sock_accept().
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks.
