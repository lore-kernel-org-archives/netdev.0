From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14002] New: WARNING: at net/ipv4/af_inet.c:154
 inet_sock_destruct+0x164/0x1c0()
Date: Wed, 19 Aug 2009 14:21:45 -0700
Message-ID: <20090819142145.b3c9fdc1.akpm@linux-foundation.org>
References: <bug-14002-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, ralf.hildebrandt@charite.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45624 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752952AbZHSVWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 17:22:20 -0400
In-Reply-To: <bug-14002-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 18 Aug 2009 12:37:27 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14002
> 
>            Summary: WARNING: at net/ipv4/af_inet.c:154
>                     inet_sock_destruct+0x164/0x1c0()
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.31-rc4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: ralf.hildebrandt@charite.de
>         Regression: No

I suspect this _is_ a regression.  I'll mark it as such and will snitch
to Rafael.


> 
> from dmesg:
> 
> Aug 17 17:02:31 vpn-gw-int kernel: [507940.695531] ------------[ cut here
> ]------------
> Aug 17 17:02:31 vpn-gw-int kernel: [507940.695558] WARNING: at
> net/ipv4/af_inet.c:154 inet_sock_destruct+0x164/0x1c0()

In my 2.6.31-rc4 that is

	WARN_ON(sk->sk_forward_alloc);

> Aug 17 17:02:31 vpn-gw-int kernel: [507940.695589] Hardware name: ProLiant
> DL360 G4p
> Aug 17 17:02:31 vpn-gw-int kernel: [507940.695607] Modules linked in: ipt_LOG
> xt_multiport tun xt_tcpudp xt_state iptable_nat nf_nat iptable_filter ip_tables
> x_tables
> nf_conntrack_ipv4 nf_defrag_ipv4 ipv6 psmouse nf_conntrack_ftp nf_conntrack tg3
> libphy
> Aug 17 17:02:31 vpn-gw-int kernel: [507940.695697] Pid: 2314, comm: openvpn Not
> tainted 2.6.31-rc4 #1
> Aug 17 17:02:31 vpn-gw-int kernel: [507940.695715] Call Trace:
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695734]  [<c1269d64>] ?
> inet_sock_destruct+0x164/0x1c0
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695756]  [<c103252b>] ?
> warn_slowpath_common+0x6f/0xcd
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695777]  [<c1269d64>] ?
> inet_sock_destruct+0x164/0x1c0
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695796]  [<c10325a9>] ?
> warn_slowpath_null+0x20/0x3c
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695817]  [<c1269d64>] ?
> inet_sock_destruct+0x164/0x1c0
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695838]  [<c12889eb>] ?
> _spin_lock_bh+0x16/0x40
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695857]  [<c12889eb>] ?
> _spin_lock_bh+0x16/0x40
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695877]  [<c1219148>] ?
> __sk_free+0x21/0xd6
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695896]  [<c1219311>] ?
> sk_common_release+0x5b/0x97
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695917]  [<c1269815>] ?
> inet_release+0x39/0x66
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695936]  [<c121639a>] ?
> sock_release+0x22/0x8d
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695954]  [<c1216421>] ?
> sock_close+0x1c/0x42
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695975]  [<c10a097c>] ?
> __fput+0xd6/0x1e0
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.695993]  [<c109d454>] ?
> filp_close+0x41/0x72
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.696012]  [<c109d4fa>] ?
> sys_close+0x75/0xc0
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.696032]  [<c1002ecf>] ?
> sysenter_do_call+0x12/0x26
> Aug 17 17:02:32 vpn-gw-int kernel: [507940.696049] ---[ end trace
> a2930464345011de ]---
> Aug 17 17:03:01 vpn-gw-int kernel: [507970.165477] 172.28.33.133IN=tun0
> OUT=eth0 SRC=172.28.33.133 DST=141.80.40.193 LEN=67 TOS=0x00 PREC=0x00 TTL=127
> ID=23900 PROTO=UDP
> SPT=1026 DPT=53 LEN=47

Is it reproducible?  Still happening in current mainline?

Thanks.
