From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: [ROSE] [AX25] possible circular locking
Date: Mon, 17 Dec 2007 11:06:04 +0100
Message-ID: <47664A0C.4060903@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Jarek Poplawski <jarkao2@o2.pl>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix2-g20.free.fr ([212.27.60.43]:37842 "EHLO
	postfix2-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760758AbXLQKdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 05:33:13 -0500
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix2-g20.free.fr (Postfix) with ESMTP id C0F9221457B8
	for <netdev@vger.kernel.org>; Mon, 17 Dec 2007 09:32:24 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


When I killall kissattach I can see the following message.

This happens on kernel 2.6.24-rc5 already patched with the 6 previously
patches I sent recently.


=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.23.9 #1
-------------------------------------------------------
kissattach/2906 is trying to acquire lock:
  (linkfail_lock){-+..}, at: [<d8bd4603>] ax25_link_failed+0x11/0x39 [ax25]

but task is already holding lock:
  (ax25_list_lock){-+..}, at: [<d8bd7c7c>] ax25_device_event+0x38/0x84
[ax25]

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #3 (ax25_list_lock){-+..}:
        [<c0130897>] __lock_acquire+0x9e9/0xbe6
        [<d8bd845c>] ax25_find_cb+0x18/0xc6 [ax25]
        [<c0130b02>] lock_acquire+0x6e/0x87
        [<d8bd845c>] ax25_find_cb+0x18/0xc6 [ax25]
        [<c02a399b>] _spin_lock_bh+0x2e/0x39
        [<d8bd845c>] ax25_find_cb+0x18/0xc6 [ax25]
        [<d8bd845c>] ax25_find_cb+0x18/0xc6 [ax25]
        [<d8bd5d57>] ax25_send_frame+0x40/0x131 [ax25]
        [<d8bed51a>] rose_send_frame+0x4a/0x5b [rose]
        [<d8bed946>] rose_link_rx_restart+0x135/0x157 [rose]
        [<c02a399b>] _spin_lock_bh+0x2e/0x39
        [<d8bee56a>] rose_route_frame+0xad/0x4f3 [rose]
        [<c0105215>] dump_trace+0x81/0x8b
        [<c012dea3>] save_trace+0x37/0x8c
        [<c012f73c>] mark_lock+0x337/0x44b
        [<c0130a4c>] __lock_acquire+0xb9e/0xbe6
        [<d8bd471e>] ax25_protocol_function+0x30/0x34 [ax25]
        [<d8bd46fb>] ax25_protocol_function+0xd/0x34 [ax25]
        [<d8bd5271>] ax25_rx_iframe+0x2e3/0x332 [ax25]
        [<c011f839>] __mod_timer+0x89/0x93
        [<d8bd6b95>] ax25_std_frame_in+0x5b1/0x638 [ax25]
        [<d8bd4c49>] ax25_kiss_rcv+0x3cd/0x712 [ax25]
        [<c012f889>] mark_held_locks+0x39/0x53
        [<c02a3d2a>] _spin_unlock_irqrestore+0x34/0x39
        [<c024a79b>] sock_queue_rcv_skb+0xd6/0xf3
        [<c02a3879>] _read_unlock+0x14/0x1c
        [<c024a79b>] sock_queue_rcv_skb+0xd6/0xf3
        [<c025033c>] netif_receive_skb+0x22d/0x289
        [<c012fa60>] trace_hardirqs_on+0x109/0x148
        [<c02521ff>] process_backlog+0x7b/0xeb
        [<c02522c6>] net_rx_action+0x57/0xfd
        [<c011c52d>] __do_softirq+0x40/0x90
        [<c011c5a4>] do_softirq+0x27/0x3d
        [<c0106768>] do_IRQ+0x58/0x6c
        [<c0104cee>] common_interrupt+0x2e/0x40
        [<ffffffff>] 0xffffffff

-> #2 (rose_route_list_lock){-+..}:
        [<c0130897>] __lock_acquire+0x9e9/0xbe6
        [<d8bee50a>] rose_route_frame+0x4d/0x4f3 [rose]
        [<c0130b02>] lock_acquire+0x6e/0x87
        [<d8bee50a>] rose_route_frame+0x4d/0x4f3 [rose]
        [<c02a399b>] _spin_lock_bh+0x2e/0x39
        [<d8bee50a>] rose_route_frame+0x4d/0x4f3 [rose]
        [<d8bee50a>] rose_route_frame+0x4d/0x4f3 [rose]
        [<c0105215>] dump_trace+0x81/0x8b
        [<c012dea3>] save_trace+0x37/0x8c
        [<c012f73c>] mark_lock+0x337/0x44b
        [<c0130a4c>] __lock_acquire+0xb9e/0xbe6
        [<d8bd471e>] ax25_protocol_function+0x30/0x34 [ax25]
        [<d8bd46fb>] ax25_protocol_function+0xd/0x34 [ax25]
        [<d8bd5271>] ax25_rx_iframe+0x2e3/0x332 [ax25]
        [<c011f839>] __mod_timer+0x89/0x93
        [<d8bd6b95>] ax25_std_frame_in+0x5b1/0x638 [ax25]
        [<d8bd4c49>] ax25_kiss_rcv+0x3cd/0x712 [ax25]
        [<c012f889>] mark_held_locks+0x39/0x53
        [<c02a3d2a>] _spin_unlock_irqrestore+0x34/0x39
        [<c024a79b>] sock_queue_rcv_skb+0xd6/0xf3
        [<c02a3879>] _read_unlock+0x14/0x1c
        [<c024a79b>] sock_queue_rcv_skb+0xd6/0xf3
        [<c025033c>] netif_receive_skb+0x22d/0x289
        [<c012fa60>] trace_hardirqs_on+0x109/0x148
        [<c02521ff>] process_backlog+0x7b/0xeb
        [<c02522c6>] net_rx_action+0x57/0xfd
        [<c011c52d>] __do_softirq+0x40/0x90
        [<c011c5a4>] do_softirq+0x27/0x3d
        [<c0106768>] do_IRQ+0x58/0x6c
        [<c0104cee>] common_interrupt+0x2e/0x40
        [<ffffffff>] 0xffffffff

-> #1 (rose_neigh_list_lock){-+..}:
        [<c0130897>] __lock_acquire+0x9e9/0xbe6
        [<d8bee31e>] rose_link_failed+0xe/0x44 [rose]
        [<c0130b02>] lock_acquire+0x6e/0x87
        [<d8bee31e>] rose_link_failed+0xe/0x44 [rose]
        [<d8bd7783>] ax25_t1timer_expiry+0x0/0x20 [ax25]
        [<c02a399b>] _spin_lock_bh+0x2e/0x39
        [<d8bee31e>] rose_link_failed+0xe/0x44 [rose]
        [<d8bee31e>] rose_link_failed+0xe/0x44 [rose]
        [<d8bd461a>] ax25_link_failed+0x28/0x39 [ax25]
        [<d8bd7300>] ax25_disconnect+0x34/0xbe [ax25]
        [<c011f4f3>] run_timer_softirq+0xee/0x14a
        [<c011c51e>] __do_softirq+0x31/0x90
        [<c012fa60>] trace_hardirqs_on+0x109/0x148
        [<c011c52d>] __do_softirq+0x40/0x90
        [<c011c5a4>] do_softirq+0x27/0x3d
        [<c0106768>] do_IRQ+0x58/0x6c
        [<c0104cee>] common_interrupt+0x2e/0x40
        [<d8a9163f>] acpi_processor_idle+0x262/0x3cf [processor]
        [<c0102342>] cpu_idle+0x3c/0x51
        [<c0382a0c>] start_kernel+0x272/0x277
        [<c0382323>] unknown_bootoption+0x0/0x195
        [<ffffffff>] 0xffffffff

-> #0 (linkfail_lock){-+..}:
        [<c0130780>] __lock_acquire+0x8d2/0xbe6
        [<c0130b02>] lock_acquire+0x6e/0x87
        [<d8bd4603>] ax25_link_failed+0x11/0x39 [ax25]
        [<c02a399b>] _spin_lock_bh+0x2e/0x39
        [<d8bd4603>] ax25_link_failed+0x11/0x39 [ax25]
        [<d8bd4603>] ax25_link_failed+0x11/0x39 [ax25]
        [<d8bd7300>] ax25_disconnect+0x34/0xbe [ax25]
        [<d8bd7c97>] ax25_device_event+0x53/0x84 [ax25]
        [<c0122670>] notifier_call_chain+0x2a/0x47
        [<c01226d3>] raw_notifier_call_chain+0x17/0x1a
        [<c0250a47>] dev_close+0x62/0x66
        [<c0250af1>] unregister_netdevice+0xa6/0x21f
        [<c0250c79>] unregister_netdev+0xf/0x15
        [<d8b4a7ad>] mkiss_close+0x63/0x7c [mkiss]
        [<c01fdd85>] release_dev+0x4f1/0x5a6
        [<c0130a4c>] __lock_acquire+0xb9e/0xbe6
        [<c01b2226>] _atomic_dec_and_lock+0x22/0x2c
        [<c0130a4c>] __lock_acquire+0xb9e/0xbe6
        [<c01fde41>] tty_release+0x7/0xa
        [<c015c7f7>] __fput+0xbc/0x172
        [<c015a2c6>] filp_close+0x51/0x58
        [<c0119dc3>] put_files_struct+0x5e/0xa6
        [<c011ae6e>] do_exit+0x22e/0x6d9
        [<c02a3c0d>] _spin_unlock_irq+0x20/0x23
        [<c012fa76>] trace_hardirqs_on+0x11f/0x148
        [<c011b384>] sys_exit_group+0x0/0xd
        [<c0121c36>] get_signal_to_deliver+0x3c6/0x3ea
        [<c0103475>] do_notify_resume+0x81/0x5fe
        [<c02a3d2a>] _spin_unlock_irqrestore+0x34/0x39
        [<c012fa76>] trace_hardirqs_on+0x11f/0x148
        [<c012b196>] getnstimeofday+0x2b/0xac
        [<c01b6d55>] copy_to_user+0x2f/0x46
        [<c0129ed8>] hrtimer_nanosleep+0x92/0xe5
        [<c0129b75>] hrtimer_wakeup+0x0/0x18
        [<c0129f74>] sys_nanosleep+0x49/0x59
        [<c0103ded>] work_notifysig+0x13/0x26
        [<ffffffff>] 0xffffffff

other info that might help us debug this:

2 locks held by kissattach/2906:
  #0:  (rtnl_mutex){--..}, at: [<c0250c72>] unregister_netdev+0x8/0x15
  #1:  (ax25_list_lock){-+..}, at: [<d8bd7c7c>]
ax25_device_event+0x38/0x84 [ax25]

stack backtrace:
  [<c012efac>] print_circular_bug_tail+0x5e/0x66
  [<c0130780>] __lock_acquire+0x8d2/0xbe6
  [<c0130b02>] lock_acquire+0x6e/0x87
  [<d8bd4603>] ax25_link_failed+0x11/0x39 [ax25]
  [<c02a399b>] _spin_lock_bh+0x2e/0x39
  [<d8bd4603>] ax25_link_failed+0x11/0x39 [ax25]
  [<d8bd4603>] ax25_link_failed+0x11/0x39 [ax25]
  [<d8bd7300>] ax25_disconnect+0x34/0xbe [ax25]
  [<d8bd7c97>] ax25_device_event+0x53/0x84 [ax25]
  [<c0122670>] notifier_call_chain+0x2a/0x47
  [<c01226d3>] raw_notifier_call_chain+0x17/0x1a
  [<c0250a47>] dev_close+0x62/0x66
  [<c0250af1>] unregister_netdevice+0xa6/0x21f
  [<c0250c79>] unregister_netdev+0xf/0x15
  [<d8b4a7ad>] mkiss_close+0x63/0x7c [mkiss]
  [<c01fdd85>] release_dev+0x4f1/0x5a6
  [<c0130a4c>] __lock_acquire+0xb9e/0xbe6
  [<c01b2226>] _atomic_dec_and_lock+0x22/0x2c
  [<c0130a4c>] __lock_acquire+0xb9e/0xbe6
  [<c01fde41>] tty_release+0x7/0xa
  [<c015c7f7>] __fput+0xbc/0x172
  [<c015a2c6>] filp_close+0x51/0x58
  [<c0119dc3>] put_files_struct+0x5e/0xa6
  [<c011ae6e>] do_exit+0x22e/0x6d9
  [<c02a3c0d>] _spin_unlock_irq+0x20/0x23
  [<c012fa76>] trace_hardirqs_on+0x11f/0x148
  [<c011b384>] sys_exit_group+0x0/0xd
  [<c0121c36>] get_signal_to_deliver+0x3c6/0x3ea
  [<c0103475>] do_notify_resume+0x81/0x5fe
  [<c02a3d2a>] _spin_unlock_irqrestore+0x34/0x39
  [<c012fa76>] trace_hardirqs_on+0x11f/0x148
  [<c012b196>] getnstimeofday+0x2b/0xac
  [<c01b6d55>] copy_to_user+0x2f/0x46
  [<c0129ed8>] hrtimer_nanosleep+0x92/0xe5
  [<c0129b75>] hrtimer_wakeup+0x0/0x18
  [<c0129f74>] sys_nanosleep+0x49/0x59
  [<c0103ded>] work_notifysig+0x13/0x26
  =======================

Bernard Pidoux


