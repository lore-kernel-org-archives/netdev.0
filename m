From: Dave Young <hidave.darkstar@gmail.com>
Subject: BUG: sleeping function called from invalid context at
	kernel/mutex.c:280
Date: Fri, 19 Jun 2009 10:36:13 +0800
Message-ID: <a8e1da0906181936k66b8bb2cv63f0007f5fe067f3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:20151 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbZFSCgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 22:36:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

with kernel 2.6.30-06692-g3fe0344, pppoe link, start firefox, then got
the messages from syslog:

Jun 19 10:14:07 darkstar kernel: [  189.313972] BUG: sleeping function
called from invalid context at kernel/mutex.c:280
Jun 19 10:14:07 darkstar kernel: [  189.313976] in_atomic(): 1,
irqs_disabled(): 0, pid: 2100, name: firefox-bin
Jun 19 10:14:07 darkstar kernel: [  189.313980] 6 locks held by
firefox-bin/2100:
Jun 19 10:14:07 darkstar kernel: [  189.313981]  #0:
(sk_lock-AF_INET){+.+.+.}, at: [<c12ed864>] lock_sock+0xa/0xc
Jun 19 10:14:07 darkstar kernel: [  189.313991]  #1:
(rcu_read_lock){.+.+..}, at: [<c12c002e>] dev_queue_xmit+0xd8/0x29c
Jun 19 10:14:07 darkstar kernel: [  189.314000]  #2:
(_xmit_PPP#2){+.-...}, at: [<c12cbee2>] __netif_tx_lock+0x11/0x18
Jun 19 10:14:07 darkstar kernel: [  189.314008]  #3:
(&ppp->wlock){+.-...}, at: [<c12224a8>] ppp_xmit_process+0x19/0x449
Jun 19 10:14:07 darkstar kernel: [  189.314015]  #4:
(&pch->downl){+.-...}, at: [<c1221cf2>] ppp_push+0x63/0x4d2
Jun 19 10:14:07 darkstar kernel: [  189.314021]  #5:
(&ap->xmit_lock){+.-...}, at: [<c1224ef0>] ppp_async_push+0x2f/0x3d0
Jun 19 10:14:07 darkstar kernel: [  189.314029] Pid: 2100, comm:
firefox-bin Not tainted 2.6.30-06692-g3fe0344-dirty #77
Jun 19 10:14:07 darkstar kernel: [  189.314031] Call Trace:
Jun 19 10:14:07 darkstar kernel: [  189.314036]  [<c102315e>]
__might_sleep+0xe1/0xe6
Jun 19 10:14:07 darkstar kernel: [  189.314041]  [<c1335dfd>]
mutex_lock_nested+0x18/0x36
Jun 19 10:14:07 darkstar kernel: [  189.314046]  [<c118d82f>]
tty_throttle+0x10/0x38
Jun 19 10:14:07 darkstar kernel: [  189.314050]  [<c118cc1c>]
n_tty_receive_buf+0xf6e/0xf76
Jun 19 10:14:07 darkstar kernel: [  189.314055]  [<c1049e7e>] ?
__lock_acquire+0xa8d/0xaa9
Jun 19 10:14:07 darkstar kernel: [  189.314059]  [<c1048415>] ?
mark_lock+0x1e/0x1c7
Jun 19 10:14:07 darkstar kernel: [  189.314063]  [<c1048601>] ?
mark_held_locks+0x43/0x5b
Jun 19 10:14:07 darkstar kernel: [  189.314067]  [<c1336b39>] ?
_spin_unlock_irqrestore+0x3c/0x48
Jun 19 10:14:07 darkstar kernel: [  189.314071]  [<c104870a>] ?
trace_hardirqs_on_caller+0xf1/0x146
Jun 19 10:14:07 darkstar kernel: [  189.314075]  [<c104876a>] ?
trace_hardirqs_on+0xb/0xd
Jun 19 10:14:07 darkstar kernel: [  189.314078]  [<c118e2f7>] ?
tty_ldisc_try+0x32/0x38
Jun 19 10:14:07 darkstar kernel: [  189.314082]  [<c118fb43>]
pty_write+0x51/0x67
Jun 19 10:14:07 darkstar kernel: [  189.314086]  [<c1224f7f>]
ppp_async_push+0xbe/0x3d0
Jun 19 10:14:07 darkstar kernel: [  189.314089]  [<c12252c3>]
ppp_async_send+0x32/0x3d
Jun 19 10:14:07 darkstar kernel: [  189.314093]  [<c1221d04>]
ppp_push+0x75/0x4d2
Jun 19 10:14:07 darkstar kernel: [  189.314097]  [<c1336b39>] ?
_spin_unlock_irqrestore+0x3c/0x48
Jun 19 10:14:07 darkstar kernel: [  189.314101]  [<c104870a>] ?
trace_hardirqs_on_caller+0xf1/0x146
Jun 19 10:14:07 darkstar kernel: [  189.314104]  [<c104876a>] ?
trace_hardirqs_on+0xb/0xd
Jun 19 10:14:07 darkstar kernel: [  189.314109]  [<c12b778b>] ?
skb_dequeue+0x39/0x41
Jun 19 10:14:07 darkstar kernel: [  189.314112]  [<c122286e>]
ppp_xmit_process+0x3df/0x449
Jun 19 10:14:07 darkstar kernel: [  189.314116]  [<c12b76d2>] ?
skb_queue_tail+0x31/0x3a
Jun 19 10:14:07 darkstar kernel: [  189.314120]  [<c12229e7>]
ppp_start_xmit+0x10f/0x14b
Jun 19 10:14:07 darkstar kernel: [  189.314124]  [<c12be77e>]
dev_hard_start_xmit+0x1be/0x249
Jun 19 10:14:07 darkstar kernel: [  189.314128]  [<c12cc4d7>]
__qdisc_run+0xe3/0x1b6
Jun 19 10:14:07 darkstar kernel: [  189.314131]  [<c12bc94a>]
qdisc_run+0x18/0x1a
Jun 19 10:14:07 darkstar kernel: [  189.314135]  [<c12c00db>]
dev_queue_xmit+0x185/0x29c
Jun 19 10:14:07 darkstar kernel: [  189.314140]  [<c12e89fa>]
ip_finish_output2+0x199/0x1c3
Jun 19 10:14:07 darkstar kernel: [  189.314143]  [<c12e8563>] ?
nf_hook_thresh+0x39/0x4a
Jun 19 10:14:07 darkstar kernel: [  189.314147]  [<c12e8a24>] ?
ip_finish_output+0x0/0x39
Jun 19 10:14:07 darkstar kernel: [  189.314151]  [<c12e8a59>]
ip_finish_output+0x35/0x39
Jun 19 10:14:07 darkstar kernel: [  189.314155]  [<c12e9110>]
ip_output+0x82/0x87
Jun 19 10:14:07 darkstar kernel: [  189.314178]  [<c12e73ad>] dst_output+0x9/0xb
Jun 19 10:14:07 darkstar kernel: [  189.314182]  [<c12e860e>]
ip_local_out+0x17/0x1a
Jun 19 10:14:08 darkstar kernel: [  189.314186]  [<c12e9604>]
ip_queue_xmit+0x2bf/0x303
Jun 19 10:14:08 darkstar kernel: [  189.314190]  [<c104eca6>] ?
is_module_text_address+0x8/0x12
Jun 19 10:14:08 darkstar kernel: [  189.314194]  [<c1005bea>] ?
print_context_stack+0x2f/0x8c
Jun 19 10:14:08 darkstar kernel: [  189.314198]  [<c1048415>] ?
mark_lock+0x1e/0x1c7
Jun 19 10:14:08 darkstar kernel: [  189.314202]  [<c1048601>] ?
mark_held_locks+0x43/0x5b
Jun 19 10:14:08 darkstar kernel: [  189.314206]  [<c12fb556>] ?
tcp_v4_send_check+0x81/0x90
Jun 19 10:14:08 darkstar kernel: [  189.314210]  [<c12f741a>]
tcp_transmit_skb+0x574/0x5ae
Jun 19 10:14:08 darkstar kernel: [  189.314215]  [<c12f85d9>]
tcp_write_xmit+0x620/0x70d
Jun 19 10:14:08 darkstar kernel: [  189.314218]  [<c12ede2b>] ?
csum_and_copy_from_user+0x4e/0x6c
Jun 19 10:14:08 darkstar kernel: [  189.314223]  [<c12f86ee>]
tcp_push_one+0x28/0x2c
Jun 19 10:14:08 darkstar kernel: [  189.314226]  [<c12efd01>]
tcp_sendmsg+0x4ca/0x5b6
Jun 19 10:14:08 darkstar kernel: [  189.314230]  [<c12b2183>]
__sock_sendmsg+0x45/0x4e
Jun 19 10:14:08 darkstar kernel: [  189.314234]  [<c12b28da>]
sock_sendmsg+0xb8/0xce
Jun 19 10:14:08 darkstar kernel: [  189.314238]  [<c1049e7e>] ?
__lock_acquire+0xa8d/0xaa9
Jun 19 10:14:08 darkstar kernel: [  189.314242]  [<c103ae4d>] ?
autoremove_wake_function+0x0/0x30
Jun 19 10:14:08 darkstar kernel: [  189.314246]  [<c1336b39>] ?
_spin_unlock_irqrestore+0x3c/0x48
Jun 19 10:14:08 darkstar kernel: [  189.314251]  [<c1099c6d>] ?
fget_light+0x76/0x94
Jun 19 10:14:08 darkstar kernel: [  189.314255]  [<c1099c81>] ?
fget_light+0x8a/0x94
Jun 19 10:14:08 darkstar kernel: [  189.314258]  [<c12b237a>] ?
sockfd_lookup_light+0x16/0x48
Jun 19 10:14:08 darkstar kernel: [  189.314262]  [<c12b32af>]
sys_sendto+0xa4/0xc0
Jun 19 10:14:08 darkstar kernel: [  189.314266]  [<c1049e7e>] ?
__lock_acquire+0xa8d/0xaa9
Jun 19 10:14:08 darkstar kernel: [     [<c1049d0f>] __lock_acquire+0x91e/0xaa9
Jun 19 10:14:08 darkstar kernel: [  189.328319]    [<c1049f35>]
lock_acquire+0x9b/0xbe
Jun 19 10:14:08 darkstar kernel: [  189.328319]    [<c103e099>]
down_write_nested+0x32/0x50
Jun 19 10:14:08 darkstar kernel: [  189.328319]    [<c1028475>]
dup_mm+0xa6/0x302
Jun 19 10:14:08 darkstar kernel: [  189.328319]    [<c102911e>]
copy_process+0xa25/0x10b2
Jun 19 10:14:08 darkstar kernel: [  189.328319]    [<c10299ed>]
do_fork+0x12b/0x2a6
Jun 19 10:14:08 darkstar kernel: [  189.328319]    [<c1001f49>]
sys_clone+0x24/0x2b
Jun 19 10:14:08 darkstar kernel: [  189.328319]    [<c100331d>]
syscall_call+0x7/0xb
Jun 19 10:14:08 darkstar kernel: [  189.328319]    [<ffffffff>] 0xffffffff
Jun 19 10:14:08 darkstar kernel: [  189.328319]

[snip ...]

-- 
Regards
dave
