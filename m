From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 6682] New: BUG: soft lockup detected on CPU#0! / ksoftirqd takse 100% CPU
Date: Mon, 19 Jun 2006 17:26:42 -0700
Message-ID: <20060620002642.GI11049@us.ibm.com>
References: <200606122311.k5CNBMEx007518@fire-2.osdl.org> <20060619152010.5c648b97.akpm@osdl.org>
Reply-To: paulmck@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dipankar Sarma <dipankar@in.ibm.com>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, alchemyx@uznam.net.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:49553 "EHLO
	e34.co.us.ibm.com") by vger.kernel.org with ESMTP id S965010AbWFTA0N
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 20:26:13 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5K0QDbE024266
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 20:26:13 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5K0PqAW254396
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 18:25:52 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5K0QCrc031754
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 18:26:12 -0600
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060619152010.5c648b97.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 19, 2006 at 03:20:10PM -0700, Andrew Morton wrote:
> bugme-daemon@bugzilla.kernel.org wrote:
> >
> > http://bugzilla.kernel.org/show_bug.cgi?id=6682
> > 
> >            Summary: BUG: soft lockup detected on CPU#0! / ksoftirqd takse
> >                     100% CPU
> >     Kernel Version: 2.6.15.6
> >             Status: NEW
> >           Severity: normal
> >              Owner: acme@conectiva.com.br
> >          Submitter: alchemyx@uznam.net.pl
> > 
> > 
> > Most recent kernel where this bug did not occur: (unknown)
> > Distribution: Gentoo
> > Hardware Environment: 2x Xeon 2.66, 1 GB RAM, NICS: 2 x e1000, and one double
> > port e100. Based on Intel E7501 architecture (2U rack Intel chassis).
> > Software Environment: quagga 0.98.6
> > Problem Description: ksoftirqd/0 takes 100% of CPU. further investigation shows
> > no sing of network flood or something (and also 2 of 3 NICs are e1000 with
> > NAPI). Ocassionaly there are "BUG: soft lockup detected on CPU#0!".
> > 
> > Steps to reproduce:
> > 
> > There is no simple way to reproduce. I think that everythint started when we
> > attached second provider with BGP support. We are using quagga which injects
> > about 186 000 routes into kernel. When running for a while (at least few hours,
> > sometimes a day) we get 100% usage on ksoftirqd/0 and following messages in logs:

Is it possible that there is a routing loop, either in the overall
configuration or in some intermediate point in the route injection?
Both CPUs seem to be receiving ethernet packets at the time of the oops.

						Thanx, Paul

> > BUG: soft lockup detected on CPU#0!
> > 
> > Pid: 6506, comm:                zebra
> > EIP: 0060:[<c027f6fd>] CPU: 0
> > EIP is at _spin_lock+0x7/0xf
> >  EFLAGS: 00000286    Not tainted  (2.6.15.6)
> > EAX: f6203180 EBX: e6fbf000 ECX: 00000000 EDX: f6bec000
> > ESI: f6203000 EDI: eddb4b80 EBP: fffffff4 DS: 007b ES: 007b
> > CR0: 8005003b CR2: aca6dff0 CR3: 361ad000 CR4: 000006d0
> >  [<c02396f9>] dev_queue_xmit+0xe0/0x203
> >  [<c0250de8>] ip_output+0x1e1/0x237
> >  [<c024f3f5>] ip_forward+0x181/0x1df
> >  [<c024e21a>] ip_rcv+0x40c/0x485
> >  [<c0239bd0>] netif_receive_skb+0x12f/0x165
> >  [<f885aa4c>] e1000_clean_rx_irq+0x389/0x410 [e1000]
> >  [<f885a1ca>] e1000_clean+0x94/0x12f [e1000]
> >  [<c0239d5a>] net_rx_action+0x69/0xf0
> >  [<c011a305>] __do_softirq+0x55/0xbd
> >  [<c011a39a>] do_softirq+0x2d/0x31
> >  [<c011a3f8>] local_bh_enable+0x5a/0x65
> >  [<c024a0a1>] rt_run_flush+0x5f/0x80
> >  [<c027623f>] fn_hash_insert+0x352/0x39f
> >  [<c027364c>] inet_rtm_newroute+0x57/0x62
> >  [<c02413ed>] rtnetlink_rcv_msg+0x1a8/0x1cb
> >  [<c0241245>] rtnetlink_rcv_msg+0x0/0x1cb
> >  [<c0247c1e>] netlink_rcv_skb+0x3a/0x8b
> >  [<c0247cb1>] netlink_run_queue+0x42/0xc3
> >  [<c0241245>] rtnetlink_rcv_msg+0x0/0x1cb
> >  [<c0241245>] rtnetlink_rcv_msg+0x0/0x1cb
> >  [<c0241227>] rtnetlink_rcv+0x22/0x40
> >  [<c0241245>] rtnetlink_rcv_msg+0x0/0x1cb
> >  [<c024764c>] netlink_data_ready+0x17/0x54
> >  [<c0246a99>] netlink_sendskb+0x1f/0x39
> >  [<c0247449>] netlink_sendmsg+0x27b/0x28c
> >  [<c0231467>] sock_sendmsg+0xce/0xe9
> >  [<c0112b36>] __wake_up+0x27/0x3b
> >  [<c01a6216>] copy_to_user+0x38/0x42
> >  [<c01a625a>] copy_from_user+0x3a/0x60
> >  [<c01a625a>] copy_from_user+0x3a/0x60
> >  [<c0126be2>] autoremove_wake_function+0x0/0x3a
> >  [<c0236bcd>] verify_iovec+0x49/0x7f
> >  [<c02327f2>] sys_sendmsg+0x152/0x1a8
> >  [<c0147a62>] do_sync_read+0xb8/0xeb
> >  [<c01a6216>] copy_to_user+0x38/0x42
> >  [<c0126be2>] autoremove_wake_function+0x0/0x3a
> >  [<c0122b7a>] getrusage+0x34/0x43
> >  [<c0168504>] inotify_dentry_parent_queue_event+0x29/0x7c
> >  [<c01a625a>] copy_from_user+0x3a/0x60
> >  [<c0232b6b>] sys_socketcall+0x167/0x180
> >  [<c0102433>] sysenter_past_esp+0x54/0x75
> > 
> > BUG: soft lockup detected on CPU#0!
> > 
> > Pid: 6506, comm:                zebra
> > EIP: 0060:[<f8952052>] CPU: 0
> > EIP is at u32_classify+0x52/0x170 [cls_u32]
> >  EFLAGS: 00000206    Not tainted  (2.6.15.6)
> > EAX: e2fbd020 EBX: f48649c0 ECX: 00000010 EDX: 29b09d5a
> > ESI: f48649ec EDI: 00000001 EBP: e2fbd020 DS: 007b ES: 007b
> > CR0: 8005003b CR2: 08154004 CR3: 361ad000 CR4: 000006d0
> >  [<f88462fa>] ipt_do_table+0x2de/0x2fd [ip_tables]
> >  [<f883b523>] ip_nat_fn+0x177/0x185 [iptable_nat]
> >  [<f88e159f>] ip_refrag+0x23/0x5f [ip_conntrack]
> >  [<c0244d82>] tc_classify+0x2c/0x3f
> >  [<f895514b>] htb_classify+0x14b/0x1dd [sch_htb]
> >  [<f8955638>] htb_enqueue+0x1d/0x13a [sch_htb]
> >  [<c02396fd>] dev_queue_xmit+0xe4/0x203
> >  [<c0250de8>] ip_output+0x1e1/0x237
> >  [<c024f3f5>] ip_forward+0x181/0x1df
> >  [<c024e21a>] ip_rcv+0x40c/0x485
> >  [<c0239bd0>] netif_receive_skb+0x12f/0x165
> >  [<f885aa4c>] e1000_clean_rx_irq+0x389/0x410 [e1000]
> >  [<f885a1ca>] e1000_clean+0x94/0x12f [e1000]
> >  [<c0239d5a>] net_rx_action+0x69/0xf0
> >  [<c011a305>] __do_softirq+0x55/0xbd
> >  [<c011a39a>] do_softirq+0x2d/0x31
> >  [<c011a3f8>] local_bh_enable+0x5a/0x65
> >  [<c024a0a1>] rt_run_flush+0x5f/0x80
> >  [<c027623f>] fn_hash_insert+0x352/0x39f
> >  [<c027364c>] inet_rtm_newroute+0x57/0x62
> >  [<c02413ed>] rtnetlink_rcv_msg+0x1a8/0x1cb
> >  [<c0241245>] rtnetlink_rcv_msg+0x0/0x1cb
> >  [<c0247c1e>] netlink_rcv_skb+0x3a/0x8b
> >  [<c0247cb1>] netlink_run_queue+0x42/0xc3
> >  [<c0241245>] rtnetlink_rcv_msg+0x0/0x1cb
> >  [<c0241245>] rtnetlink_rcv_msg+0x0/0x1cb
> >  [<c0241227>] rtnetlink_rcv+0x22/0x40
> >  [<c0241245>] rtnetlink_rcv_msg+0x0/0x1cb
> >  [<c024764c>] netlink_data_ready+0x17/0x54
> >  [<c0246a99>] netlink_sendskb+0x1f/0x39
> >  [<c0247449>] netlink_sendmsg+0x27b/0x28c
> >  [<c0231467>] sock_sendmsg+0xce/0xe9
> >  [<c0112b36>] __wake_up+0x27/0x3b
> >  [<c01a625a>] copy_from_user+0x3a/0x60
> >  [<c01a625a>] copy_from_user+0x3a/0x60
> >  [<c0126be2>] autoremove_wake_function+0x0/0x3a
> >  [<c0236bcd>] verify_iovec+0x49/0x7f
> >  [<c02327f2>] sys_sendmsg+0x152/0x1a8
> >  [<c0147a62>] do_sync_read+0xb8/0xeb
> >  [<c0122b7a>] getrusage+0x34/0x43
> >  [<c011d72f>] update_wall_time+0xa/0x32
> >  [<c011d9e5>] do_timer+0x33/0xa9
> >  [<c01a625a>] copy_from_user+0x3a/0x60
> >  [<c0232b6b>] sys_socketcall+0x167/0x180
> >  [<c0102433>] sysenter_past_esp+0x54/0x75
> > 
> > It happens on 2.6.15.6. Tonight I will try 2.6.16.16 with FIB_TRIE instead of
> > FIB_HASH. I am submitting that bug under network but I am not completly sure if
> > it belongs here.
> 
> This also happens on 2.6.16.6.
