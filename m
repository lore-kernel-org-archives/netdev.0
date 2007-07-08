From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8724] New: Unaligned acess in udp_recvmsg() on
 EV56
Date: Sun, 8 Jul 2007 15:29:35 -0700
Message-ID: <20070708152935.b34d6e66.akpm@linux-foundation.org>
References: <bug-8724-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jailbird@alcatraz.fdf.net,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Richard Henderson <rth@twiddle.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56905 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755160AbXGHW3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 18:29:55 -0400
In-Reply-To: <bug-8724-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun,  8 Jul 2007 14:30:17 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8724
> 
>            Summary: Unaligned acess in udp_recvmsg() on EV56
>            Product: Platform Specific/Hardware
>            Version: 2.5
>      KernelVersion: 2.6.22-rc7-git7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Alpha
>         AssignedTo: rth@twiddle.net
>         ReportedBy: jailbird@alcatraz.fdf.net
> 
> 
> Most recent kernel where this bug did not occur: Occurs in all 2.6.2[12] at
> least
> Distribution: Debian testing/lenny
> Hardware Environment: Digital PWS 433au (EV56)
> Software Environment:
> Linux utopia 2.6.22-rc7-git7 #1 Thu Jul 8 10:34:17 CDT 2027 alpha GNU/Linux
> 
> Gnu C                  4.2.1
> Gnu make               3.81
> binutils               (GNU Binutils for Debian) 2.17.50.20070426
> util-linux             2.12r
> mount                  2.12r
> module-init-tools      3.3-pre11
> e2fsprogs              1.40-WIP
> xfsprogs               2.8.18
> Linux C Library        > libc.2.5
> Dynamic linker (ldd)   2.5
> Procps                 3.2.7
> Net-tools              1.60
> Kbd                    85:
> Sh-utils               5.97
> udev                   105
> Modules Loaded         ipt_TOS xt_multiport xt_tcpudp xt_state ip6table_mangle
> ip6table_filter ip6_tables ipv6 iptable_nat nf_nat nf_conntrack_ipv4
> nf_conntrack iptable_mangle iptable_filter ip_tables x_tables dm_mod serio_raw
> mxser_new ide_generic via_rhine mii generic ide_core tulip bitrev crc32 sg
> sr_mod cdrom raid1 md_mod loop
> 
> Problem Description:
> kernel unaligned acc    : 2248 (pc=fffffc0000583de4,va=fffffc00071c382a)
> 
> fffffc0000583bc0 T udp_recvmsg
> fffffc0000583ed0 T udp_destroy_sock
> 
> kernel unaligned acc    : 1231 (pc=fffffc0000585190,va=fffffc000795e02e)
> 
> fffffc0000585120 T __udp4_lib_rcv
> fffffc0000585bf0 T udp_rcv
> 
> This problem does NOT seem to affect my Tsunami/Shark (EV68AL) box running the
> same kernel version on the same LAN.  Not sure if it's CPU generation related
> (EV5 vs EV6), or if it's the NIC (via_rhine on the EV5 vs e100 on the EV6).
> 
> Steps to reproduce:
> According to tshark, the only UDP packets are DHCP packets:
> 
> 1815064200.131003   10.5.128.1 -> 255.255.255.255 DHCP DHCP Offer    -
> Transaction ID 0x27c6
> 
> 

That output isn't terribly illuminating.  We'd need to work out
which code corresponds with pc=fffffc0000583de4 and
pc=fffffc0000585190.

I don't think there's necessarily a bug here: that's just the kernel
telling us that there are unaligned accesses which got successfully
fixed up, so we're being perhaps a bit inefficient.  Yes?
