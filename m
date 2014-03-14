From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 72081] New: [PATCH] kernel oops on gretap teardown
Date: Fri, 14 Mar 2014 08:23:20 -0700
Message-ID: <20140314082320.10920819@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:59840 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301AbaCNPXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 11:23:25 -0400
Received: by mail-pa0-f42.google.com with SMTP id fb1so2777531pad.15
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 08:23:25 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id db3sm17620310pbb.10.2014.03.14.08.23.23
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 08:23:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 14 Mar 2014 07:50:49 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 72081] New: [PATCH] kernel oops on gretap teardown


https://bugzilla.kernel.org/show_bug.cgi?id=72081

            Bug ID: 72081
           Summary: [PATCH] kernel oops on gretap teardown
           Product: Networking
           Version: 2.5
    Kernel Version: Linux ubuntu 3.11.10.4
          Hardware: i386
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: alex.zeffertt@gmail.com
        Regression: No

Created attachment 129391
  --> https://bugzilla.kernel.org/attachment.cgi?id=129391&action=edit
Test t->dev != NULL before dereferencing

The following kernel oops occurs on teardown of gretap devices.  The devices
actually belong to LXC containers which are destroyed forcibly.

[  202.827256] BUG: unable to handle kernel NULL pointer dereference at
000000fc
[  202.828153] IP: [<f867c22a>] ip_tunnel_lookup+0x22a/0x2e0 [ip_tunnel]
[  202.828895] *pdpt = 000000002695c001 *pde = 0000000000000000 
[  202.829568] Oops: 0000 [#1] SMP 
[  202.829970] Modules linked in: ebt_mark_m ebtable_filter ip_gre ip_tunnel
gre dummy macvlan overlayfs xt_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle
xt_tcpudp ip6table_filter ip6_tables iptable_filter ebtable_nat ebtables
ipt_MASQUERADE iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat
nf_conntrack ip_tables x_tables bridge stp llc nfsd auth_rpcgss nfs_acl nfs
lockd sunrpc fscache ext2 dm_multipath scsi_dh microcode psmouse serio_raw
virtio_balloon lp parport floppy
[  202.831060] CPU: 1 PID: 17426 Comm: manager Tainted: GF           
3.11.0-18-generic #32-Ubuntu
[  202.831060] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  202.831060] task: e4956700 ti: f64f2000 task.ti: e491e000
[  202.831060] EIP: 0060:[<f867c22a>] EFLAGS: 00210246 CPU: 1
[  202.831060] EIP is at ip_tunnel_lookup+0x22a/0x2e0 [ip_tunnel]
[  202.831060] EAX: 00000000 EBX: 00000035 ECX: 00000000 EDX: deb13ffc
[  202.831060] ESI: 00000000 EDI: deb16000 EBP: f64f3e44 ESP: f64f3e18
[  202.831060]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  202.831060] CR0: 8005003b CR2: 000000fc CR3: 26b58000 CR4: 000006f0
[  202.831060] Stack:
[  202.831060]  f2b884e8 e02d0002 00000400 deb16000 deb16000 eb340400 00000035
04003e48
[  202.831060]  eb34b180 7afb10ac f64f3e78 f64f3e68 f8685d66 7afb10ac 76fb10ac
00000000
[  202.831060]  00000035 00000000 eb34b180 e3314080 f64f3e8c f86776a6 00000001
0088e800
[  202.831060] Call Trace:
[  202.831060]  [<f8685d66>] ipgre_rcv+0x86/0xe0 [ip_gre]
[  202.831060]  [<f86776a6>] gre_cisco_rcv+0x36/0x80 [gre]
[  202.831060]  [<f8677390>] gre_rcv+0x50/0x80 [gre]
[  202.831060]  [<c157d157>] ip_local_deliver_finish+0x97/0x220
[  202.831060]  [<c157d444>] ip_local_deliver+0x44/0x90


The attached patch fixes this and I can now destroy multiple LXC containers
(and their gretap interfaces) simultaneously without causing an oops.  I don't
know whether this is the right way to go about fixing the problem though....

Regards,

Alex

-- 
You are receiving this mail because:
You are the assignee for the bug.
