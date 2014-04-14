From: James Chapman <jchapman@katalix.com>
Subject: Re: [BUG] A panic caused by null pointer dereference aftering updating
 to
Date: Mon, 14 Apr 2014 16:19:05 +0100
Message-ID: <534BFC69.6080209@katalix.com>
References: <CAHz2CGWs-JH0v3dWAMBDrKqkP6ygb48YZ-qkc=KsFqz5yO7f+Q@mail.gmail.com> <CAHz2CGU5aPA5QJ9ED9g5kahD_jJaeLF+VOotUSBFXDkY+EH8ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Zhan Jianyu <nasa4836@gmail.com>, davem@davemloft.net,
	edumazet@google.com, joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHz2CGU5aPA5QJ9ED9g5kahD_jJaeLF+VOotUSBFXDkY+EH8ow@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please send the complete oops message.

Is this a regression? If so, do you know what the last kernel version
was that worked?

Thanks
James

On 14/04/14 14:33, Zhan Jianyu wrote:
> When I tried to connect my VPN, I got a panic, saying
> a NULL poiter dereference at 0x00000000000002c0
> 
> I came across this bug twice today, after updateing to
> Linux-3.15-rc1.
> 
> Below are some panic message(hand copy,not complete)
> =====
> 
> Kernel panic - not syncing: Fatal exception in interupt
> 
> RIP ip_queue_xmit+0x20/0x3e0
> Call Trace:
> l2tp_xmit_skb+0x335/0x6c0 [l2tp_core]
> ? skb_free_head+0x1e/0x80
> pppol2tp_xmit+0x141/0x210 [l2tp_ppp]
> ppp_channel_push+0x50/0xd0 [ppp_generic]
> ppp_write+0xa3/0xec [ppp_generic]
> vfs_write
> Sys_wirte
> ? __audit_syscall_exit
> system_call_fastpath
> 
> =====
> 
> I've tried to figure it out.
> I disassembled ip_queue_xmit, found that the null
> dereference is caused by the first argument of
> ip_queue_xmit(), which is sk_buff pointer became
> NULL.
> 
> This seems some async skb freeing is in progress?
> 
> Regards,
> Jianyu Zhan
> 
