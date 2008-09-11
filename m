From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11536] New: WARNING: at
 net/ipv4/tcp_input.c:2569 tcp_ack+0xcd9/0x1f90()
Date: Thu, 11 Sep 2008 01:17:47 -0700
Message-ID: <20080911011747.7866aa73.akpm@linux-foundation.org>
References: <bug-11536-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, lexpublic@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58881 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751893AbYIKIST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 04:18:19 -0400
In-Reply-To: <bug-11536-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 11 Sep 2008 01:12:54 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11536
> 
>            Summary: WARNING: at net/ipv4/tcp_input.c:2569
>                     tcp_ack+0xcd9/0x1f90()
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.26.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: lexpublic@gmail.com
> 
> 
> Latest working kernel version: unknown
> Earliest failing kernel version: unknown
> Distribution: gentoo x86-64
> Hardware Environment: 
> #1 2xQuadra opteron, mcp55 nvidia, forcedeth gigabit network
> #2 2xQuadra xeon, intel 5000 series, e1000e gigabit network
> 
> Software Environment:
> nginx+haproxy
> 
> Problem Description:
> after 5-10 hours network load I have this backtrace in dmesg:
> 
> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_input.c:2569 tcp_ack+0xcd9/0x1f90()
> Modules linked in:                                          
> Pid: 0, comm: swapper Tainted: G        W 2.6.26.5 #5       
> 
> Call Trace:
>  <IRQ>  [<ffffffff80234504>] warn_on_slowpath+0x64/0xc0
>  [<ffffffff8040f778>] dev_queue_xmit+0xc8/0x3b0
>  [<ffffffff8049a5d9>] _spin_lock_bh+0x9/0x20
>  [<ffffffff80426f09>] __nf_ct_refresh_acct+0x29/0xf0
>  [<ffffffff80286c3f>] add_partial+0x1f/0x80
>  [<ffffffff8023ec74>] lock_timer_base+0x34/0x70
>  [<ffffffff8044fa6e>] tcp_init_tso_segs+0x2e/0x50
>  [<ffffffff8044fab7>] tcp_snd_test+0x27/0x170
>  [<ffffffff8044fc53>] tcp_may_send_now+0x53/0x80
>  [<ffffffff8044a779>] tcp_ack+0xcd9/0x1f90
>  [<ffffffff8044eda7>] tcp_rcv_established+0x587/0xdd0
>  [<ffffffff80455fad>] tcp_v4_do_rcv+0xdd/0x240
>  [<ffffffff8045670e>] tcp_v4_rcv+0x5fe/0x810
>  [<ffffffff80437e20>] ip_rcv_finish+0x0/0x360
>  [<ffffffff80438506>] ip_local_deliver_finish+0xa6/0x1f0
>  [<ffffffff80437f9a>] ip_rcv_finish+0x17a/0x360
>  [<ffffffff804383c6>] ip_rcv+0x246/0x2e0
>  [<ffffffff803af093>] e1000_receive_skb+0x53/0x1f0
>  [<ffffffff803af334>] e1000_clean_rx_irq+0x104/0x360
>  [<ffffffff803ad661>] e1000_clean+0xe1/0x210
>  [<ffffffff8040d842>] net_rx_action+0xe2/0x220
>  [<ffffffff8023a3ca>] __do_softirq+0x7a/0xf0
>  [<ffffffff8020c89c>] call_softirq+0x1c/0x30
>  [<ffffffff8020e8e5>] do_softirq+0x35/0x70
>  [<ffffffff8020e9d1>] do_IRQ+0x81/0x100
>  [<ffffffff80212a80>] mwait_idle+0x0/0x50
>  [<ffffffff8020bc21>] ret_from_intr+0x0/0xa
>  <EOI>  [<ffffffff80209410>] default_idle+0x0/0x50
>  [<ffffffff80212abc>] mwait_idle+0x3c/0x50
>  [<ffffffff8020a720>] cpu_idle+0x60/0xa0
> 
> ---[ end trace 8bcf9abf1f67c29e ]---
> 
> Steps to reproduce:
> 
> sysctl.conf:
> net.ipv4.ip_forward = 0                         
> net.ipv4.conf.default.log_martians = 1          
> net.ipv4.conf.all.log_martians = 1              
> net.ipv4.conf.default.send_redirects = 0        
> net.ipv4.ip_dynaddr = 0                         
> net.ipv4.tcp_ecn = 0                            
> net.ipv4.conf.default.rp_filter = 1             
> net.ipv4.conf.all.rp_filter = 1                 
> net.ipv4.tcp_syncookies = 1                                                 
> net.ipv4.tcp_tw_recycle = 1                                                 
> net.ipv4.tcp_tw_reuse = 1                                                   
> net.ipv4.tcp_timestamps = 1
> net.ipv4.tcp_synack_retries = 5
> net.ipv4.conf.all.accept_source_route = 0
> net.ipv4.conf.default.accept_source_route = 0
> net.ipv4.conf.all.accept_redirects = 0
> net.ipv4.conf.default.accept_redirects = 0
> net.ipv4.conf.all.secure_redirects = 0
> net.ipv4.conf.default.secure_redirects = 0
> net.ipv4.icmp_echo_ignore_broadcasts = 1
> kernel.panic = 5
> net.ipv4.tcp_max_syn_backlog = 14096
> net.ipv4.tcp_synack_retries = 5
> net.ipv4.tcp_syn_retries = 5
> net.ipv4.tcp_fin_timeout = 5
> net.ipv4.tcp_keepalive_time = 7200
> net.core.optmem_max = 655360
> net.core.netdev_max_backlog = 40000
> net.core.somaxconn = 40000
> net.ipv4.tcp_max_tw_buckets = 580000
> net.core.rmem_default = 262141
> net.core.wmem_default = 262141
> net.core.rmem_max = 25165824
> net.core.wmem_max = 25165824
> net.ipv4.tcp_rmem =  4096 262141 25165824
> net.ipv4.tcp_wmem =  4096 262141 25165824
> net.ipv4.tcp_no_metrics_save = 1
> net.ipv4.tcp_mtu_probing = 1
> net.ipv4.tcp_sack = 1
> net.ipv4.tcp_dsack = 1
> 
> iptables rules-save:
> # Generated by iptables-save v1.4.1.1 on Wed Sep 10 22:43:18 2008
> *nat                                                             
> :PREROUTING ACCEPT [72621:4808515]                               
> :POSTROUTING ACCEPT [191712:11662324]                            
> :OUTPUT ACCEPT [191712:11662324]                                 
> COMMIT                                                           
> # Completed on Wed Sep 10 22:43:18 2008                          
> # Generated by iptables-save v1.4.1.1 on Wed Sep 10 22:43:18 2008
> *mangle
> :PREROUTING ACCEPT [16013862:7579402727]
> :INPUT ACCEPT [16013694:7579367635]
> :FORWARD ACCEPT [0:0]
> :OUTPUT ACCEPT [9821064:22219526681]
> :POSTROUTING ACCEPT [9821064:22219526681]
> COMMIT
> # Completed on Wed Sep 10 22:43:18 2008
> # Generated by iptables-save v1.4.1.1 on Wed Sep 10 22:43:18 2008
> *filter
> :INPUT DROP [0:0]
> :FORWARD ACCEPT [0:0]
> :OUTPUT ACCEPT [12899:31686989]
> :black - [0:0]
> :block - [0:0]
> :ddos - [0:0]
> :synflood - [0:0]
> :white - [0:0]
> [18730:7560663] -A INPUT -j white
> [0:0] -A INPUT -p icmp -j ACCEPT
> [66:3612] -A INPUT -j block
> [66:3612] -A INPUT -p tcp -m multiport --dports 80,22,443 -j ACCEPT
> [66:3612] -A block -j black
> [66:3612] -A block -j ddos
> [19:1128] -A block -p tcp -m state --state NEW -j synflood
> [0:0] -A synflood -p tcp -m multiport --dports ! 80,443 -m recent --set --name
> BRUTE --rsource
> [0:0] -A synflood -p tcp -m multiport --dports ! 80,443 -m recent --update
> --seconds 10 --hitcount 15 --name BRUTE --rsource -j DROP
> [2332:1074647] -A white -i lo -j ACCEPT
> [16285:6479584] -A white -m state --state RELATED,ESTABLISHED -j ACCEPT
> [47:2820] -A white -s 192.168.0.1/32 -j ACCEPT
> [0:0] -A white -s 192.168.0.2/32 -j ACCEPT
> COMMIT
> # Completed on Wed Sep 10 22:43:18 2008
> 

