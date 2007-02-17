From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: 2.6.20-git14 rtl8139 possible circular locking dependency detected
Date: Sat, 17 Feb 2007 20:25:19 +0100
Message-ID: <45D7569F.9030502@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:23920 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932799AbXBQTZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Feb 2007 14:25:28 -0500
Received: by nz-out-0506.google.com with SMTP id s1so1235393nze
        for <netdev@vger.kernel.org>; Sat, 17 Feb 2007 11:25:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Feb 17 20:07:09 bitis-gabonica kernel: =======================================================
Feb 17 20:07:09 bitis-gabonica kernel: [ INFO: possible circular locking dependency detected ]
Feb 17 20:07:09 bitis-gabonica kernel: 2.6.20 #54
Feb 17 20:07:09 bitis-gabonica kernel: -------------------------------------------------------
Feb 17 20:07:09 bitis-gabonica kernel: swapper/0 is trying to acquire lock:
Feb 17 20:07:09 bitis-gabonica kernel:  (&mc->mca_lock){-+..}, at: [<fd989a99>] ipv6_chk_mcast_addr+0xbd/0x154 [ipv6]
Feb 17 20:07:09 bitis-gabonica kernel:
Feb 17 20:07:09 bitis-gabonica kernel: but task is already holding lock:
Feb 17 20:07:09 bitis-gabonica kernel:  (&tp->rx_lock){-+..}, at: [<c025ce98>] rtl8139_poll+0x42/0x40d
Feb 17 20:07:09 bitis-gabonica kernel:
Feb 17 20:07:09 bitis-gabonica kernel: which lock already depends on the new lock.
Feb 17 20:07:10 bitis-gabonica kernel:
Feb 17 20:07:10 bitis-gabonica kernel:
Feb 17 20:07:10 bitis-gabonica kernel: the existing dependency chain (in reverse order) is:
Feb 17 20:07:10 bitis-gabonica kernel:
Feb 17 20:07:10 bitis-gabonica kernel: -> #2 (&tp->rx_lock){-+..}:
Feb 17 20:07:10 bitis-gabonica kernel:        [<c013d5cc>] __lock_acquire+0xa12/0xb94
Feb 17 20:07:10 bitis-gabonica kernel:        [<c013d7b6>] lock_acquire+0x68/0x82
Feb 17 20:07:10 bitis-gabonica kernel:        [<c0311277>] _spin_lock+0x35/0x42
Feb 17 20:07:10 bitis-gabonica kernel:        [<c025ce98>] rtl8139_poll+0x42/0x40d
Feb 17 20:07:10 bitis-gabonica kernel:        [<c02d2b53>] netpoll_poll+0x83/0x329
Feb 17 20:07:10 bitis-gabonica kernel:        [<c02d2ebe>] netpoll_send_skb+0xc5/0x12c
Feb 17 20:07:10 bitis-gabonica kernel:        [<c02d3cbc>] netpoll_send_udp+0x244/0x24c
Feb 17 20:07:10 bitis-gabonica kernel:        [<c025dbd5>] write_msg+0x40/0x67
Feb 17 20:07:10 bitis-gabonica kernel:        [<c0121c9e>] __call_console_drivers+0x4e/0x5a
Feb 17 20:07:10 bitis-gabonica kernel:        [<c0121d01>] _call_console_drivers+0x57/0x5b
Feb 17 20:07:10 bitis-gabonica kernel:        [<c0121e5b>] release_console_sem+0x11e/0x1bb
Feb 17 20:07:10 bitis-gabonica kernel:        [<c0122190>] register_console+0x190/0x197
Feb 17 20:07:10 bitis-gabonica kernel:        [<c025db6a>] init_netconsole+0x57/0x69
Feb 17 20:07:10 bitis-gabonica kernel:        [<c0421514>] init+0x11e/0x203
Feb 17 20:07:10 bitis-gabonica kernel:        [<c0104dd3>] kernel_thread_helper+0x7/0x10
Feb 17 20:07:10 bitis-gabonica kernel:        [<ffffffff>] 0xffffffff
Feb 17 20:07:10 bitis-gabonica kernel:
Feb 17 20:07:10 bitis-gabonica kernel: -> #1 (&dev->_xmit_lock){-+..}:
Feb 17 20:07:10 bitis-gabonica kernel:        [<c013d5cc>] __lock_acquire+0xa12/0xb94
Feb 17 20:07:10 bitis-gabonica kernel:        [<c013d7b6>] lock_acquire+0x68/0x82
Feb 17 20:07:10 bitis-gabonica kernel:        [<c03112be>] _spin_lock_bh+0x3a/0x47
Feb 17 20:07:10 bitis-gabonica kernel:        [<c02caba0>] dev_mc_add+0x33/0x142
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd987d88>] igmp6_group_added+0x58/0x120 [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd9884f8>] ipv6_dev_mc_inc+0x2b4/0x2ff [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd9772e1>] ipv6_add_dev+0x222/0x230 [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd97733b>] ipv6_find_idev+0x4c/0x68 [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd977397>] addrconf_add_dev+0x40/0x5d [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd977d09>] addrconf_notify+0x59e/0x786 [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:        [<c02c80ea>] register_netdevice_notifier+0x43/0x56
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd93c358>] __param_forward+0x2b8/0xffffffca [ip6table_filter]
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd93c1d5>] __param_forward+0x135/0xffffffca [ip6table_filter]
Feb 17 20:07:10 bitis-gabonica kernel:        [<c0144a14>] sys_init_module+0x94/0x13f
Feb 17 20:07:10 bitis-gabonica kernel:        [<c01040da>] sysenter_past_esp+0x5f/0x99
Feb 17 20:07:10 bitis-gabonica kernel:        [<ffffffff>] 0xffffffff
Feb 17 20:07:10 bitis-gabonica kernel:
Feb 17 20:07:10 bitis-gabonica kernel: -> #0 (&mc->mca_lock){-+..}:
Feb 17 20:07:10 bitis-gabonica kernel:        [<c013d4b0>] __lock_acquire+0x8f6/0xb94
Feb 17 20:07:10 bitis-gabonica kernel:        [<c013d7b6>] lock_acquire+0x68/0x82
Feb 17 20:07:10 bitis-gabonica kernel:        [<c03112be>] _spin_lock_bh+0x3a/0x47
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd989a99>] ipv6_chk_mcast_addr+0xbd/0x154 [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd97336a>] ip6_input+0x192/0x362 [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd973599>] ip6_mc_input+0x5f/0x6d [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:        [<fd973baa>] ipv6_rcv+0x2cd/0x36f [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:        [<c02c7b43>] netif_receive_skb+0x1a0/0x230
Feb 17 20:07:10 bitis-gabonica kernel:        [<c025d108>] rtl8139_poll+0x2b2/0x40d
Feb 17 20:07:10 bitis-gabonica kernel:        [<c02c97d0>] net_rx_action+0x9f/0x192
Feb 17 20:07:10 bitis-gabonica kernel:        [<c0126568>] __do_softirq+0x6d/0xea
Feb 17 20:07:10 bitis-gabonica kernel:        [<c0106ab9>] do_softirq+0x64/0xd1
Feb 17 20:07:10 bitis-gabonica kernel:        [<ffffffff>] 0xffffffff
Feb 17 20:07:10 bitis-gabonica kernel:
Feb 17 20:07:10 bitis-gabonica kernel: other info that might help us debug this:
Feb 17 20:07:10 bitis-gabonica kernel:
Feb 17 20:07:10 bitis-gabonica kernel: 3 locks held by swapper/0:
Feb 17 20:07:10 bitis-gabonica kernel:  #0:  (&npinfo->poll_lock){-+..}, at: [<c02c97a8>] net_rx_action+0x77/0x192
Feb 17 20:07:10 bitis-gabonica kernel:  #1:  (&tp->rx_lock){-+..}, at: [<c025ce98>] rtl8139_poll+0x42/0x40d
Feb 17 20:07:10 bitis-gabonica kernel:  #2:  (&ndev->lock){-.-+}, at: [<fd989a3b>] ipv6_chk_mcast_addr+0x5f/0x154 [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:
Feb 17 20:07:10 bitis-gabonica kernel: stack backtrace:
Feb 17 20:07:10 bitis-gabonica kernel:  [<c010513d>] show_trace_log_lvl+0x1a/0x2f
Feb 17 20:07:10 bitis-gabonica kernel:  [<c0105824>] show_trace+0x12/0x14
Feb 17 20:07:10 bitis-gabonica kernel:  [<c01058d6>] dump_stack+0x16/0x18
Feb 17 20:07:10 bitis-gabonica kernel:  [<c013bcc5>] print_circular_bug_tail+0x5f/0x68
Feb 17 20:07:10 bitis-gabonica kernel:  [<c013d4b0>] __lock_acquire+0x8f6/0xb94
Feb 17 20:07:10 bitis-gabonica kernel:  [<c013d7b6>] lock_acquire+0x68/0x82
Feb 17 20:07:10 bitis-gabonica kernel:  [<c03112be>] _spin_lock_bh+0x3a/0x47
Feb 17 20:07:10 bitis-gabonica kernel:  [<fd989a99>] ipv6_chk_mcast_addr+0xbd/0x154 [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:  [<fd97336a>] ip6_input+0x192/0x362 [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:  [<fd973599>] ip6_mc_input+0x5f/0x6d [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:  [<fd973baa>] ipv6_rcv+0x2cd/0x36f [ipv6]
Feb 17 20:07:10 bitis-gabonica kernel:  [<c02c7b43>] netif_receive_skb+0x1a0/0x230
Feb 17 20:07:10 bitis-gabonica kernel:  [<c025d108>] rtl8139_poll+0x2b2/0x40d
Feb 17 20:07:10 bitis-gabonica kernel:  [<c02c97d0>] net_rx_action+0x9f/0x192
Feb 17 20:07:10 bitis-gabonica kernel:  [<c0126568>] __do_softirq+0x6d/0xea
Feb 17 20:07:10 bitis-gabonica kernel:  [<c0106ab9>] do_softirq+0x64/0xd1
Feb 17 20:07:10 bitis-gabonica kernel:  =======================

0xc02c97a8 is in net_rx_action (/mnt/md0/devel/linux-git/include/linux/netpoll.h:72).
67      static inline void *netpoll_poll_lock(struct net_device *dev)
68      {
69              rcu_read_lock(); /* deal with race on ->npinfo */
70              if (dev->npinfo) {
71                      spin_lock(&dev->npinfo->poll_lock);
72                      dev->npinfo->poll_owner = smp_processor_id();
73                      return dev->npinfo;
74              }
75              return NULL;
76      }

0xc025ce98 is in rtl8139_poll (/mnt/md0/devel/linux-git/drivers/net/8139too.c:2122).
2117            void __iomem *ioaddr = tp->mmio_addr;
2118            int orig_budget = min(*budget, dev->quota);
2119            int done = 1;
2120
2121            spin_lock(&tp->rx_lock);
2122            if (likely(RTL_R16(IntrStatus) & RxAckBits)) {
2123                    int work_done;
2124
2125                    work_done = rtl8139_rx(dev, tp, orig_budget);
2126                    if (likely(work_done > 0)) {

http://www.stardust.webpages.pl/files/tbf/euridica/2.6.20-git13/git-config

Regards,
Michal

--
Michal K. K. Piotrowski
LTG - Linux Testers Group (PL)
(http://www.stardust.webpages.pl/ltg/)
LTG - Linux Testers Group (EN)
(http://www.stardust.webpages.pl/linux_testers_group_en/)
