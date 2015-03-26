From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 95171] New: "hw csum failure" message flood for ppp tunnel
 since upgrade to 3.16
Date: Wed, 25 Mar 2015 17:38:26 -0700
Message-ID: <20150325173826.0a31f8d3@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35413 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbbCZAia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 20:38:30 -0400
Received: by pagj7 with SMTP id j7so45748264pag.2
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 17:38:29 -0700 (PDT)
Received: from uryu.home.lan ([144.49.132.3])
        by mx.google.com with ESMTPSA id ow8sm3595423pbb.57.2015.03.25.17.38.28
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 17:38:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 20 Mar 2015 22:30:53 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 95171] New: "hw csum failure" message flood for ppp tunnel since upgrade to 3.16


https://bugzilla.kernel.org/show_bug.cgi?id=95171

            Bug ID: 95171
           Summary: "hw csum failure" message flood for ppp tunnel since
                    upgrade to 3.16
           Product: Networking
           Version: 2.5
    Kernel Version: 3.16
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: dkocher@gmail.com
        Regression: Yes

Since upgrade from 3.15 to 3.16 the following error is flooding my message
file:

Oct  1 10:49:23 afftar kernel: [    9.558032] ppp0: hw csum failure
Oct  1 10:49:23 afftar kernel: [    9.558041] CPU: 1 PID: 1000 Comm: java Not
tainted 3.16.3-200.fc20.x86_64 #1
Oct  1 10:49:23 afftar kernel: [    9.558044] Hardware name: System
manufacturer System Product Name/M3N-H/HDMI, BIOS ASUS M3N-H/HDMI ACPI BIOS
Revision 2701 09/27/2010
Oct  1 10:49:23 afftar kernel: [    9.558046]  0000000000000000
000000007cd0c47e ffff880127c43b60 ffffffff81707091
Oct  1 10:49:23 afftar kernel: [    9.558050]  ffff8800bb1a2000
ffff880127c43b78 ffffffff815f54ea ffff8800cafdbb00
Oct  1 10:49:23 afftar kernel: [    9.558053]  ffff880127c43ba8
ffffffff815ecd2a 1763efe1cafdbb00 ffff8800cafdbb00
Oct  1 10:49:23 afftar kernel: [    9.558056] Call Trace:
Oct  1 10:49:23 afftar kernel: [    9.558058]  <IRQ>  [<ffffffff81707091>]
dump_stack+0x45/0x56
Oct  1 10:49:23 afftar kernel: [    9.558070]  [<ffffffff815f54ea>]
netdev_rx_csum_fault+0x3a/0x40
Oct  1 10:49:23 afftar kernel: [    9.558075]  [<ffffffff815ecd2a>]
__skb_checksum_complete+0xaa/0xb0
Oct  1 10:49:23 afftar kernel: [    9.558079]  [<ffffffff816874fc>]
nf_ip_checksum+0xcc/0x100
Oct  1 10:49:23 afftar kernel: [    9.558095]  [<ffffffffa03fb573>]
udp_error+0x103/0x200 [nf_conntrack]
Oct  1 10:49:23 afftar kernel: [    9.558100]  [<ffffffffa0507e30>] ?
pppol2tp_seq_show+0x2d0/0x2d0 [l2tp_ppp]
Oct  1 10:49:23 afftar kernel: [    9.558106]  [<ffffffffa03f4873>]
nf_conntrack_in+0xf3/0xab0 [nf_conntrack]
Oct  1 10:49:23 afftar kernel: [    9.558111]  [<ffffffff816357b0>] ?
ip_rcv_finish+0x350/0x350
Oct  1 10:49:23 afftar kernel: [    9.558114]  [<ffffffff81635460>] ?
inet_del_offload+0x40/0x40
Oct  1 10:49:23 afftar kernel: [    9.558119]  [<ffffffffa04312f2>]
ipv4_conntrack_in+0x22/0x30 [nf_conntrack_ipv4]
Oct  1 10:49:23 afftar kernel: [    9.558122]  [<ffffffff8162c45a>]
nf_iterate+0xaa/0xc0
Oct  1 10:49:23 afftar kernel: [    9.558125]  [<ffffffff81635460>] ?
inet_del_offload+0x40/0x40
Oct  1 10:49:23 afftar kernel: [    9.558127]  [<ffffffff8162c4f4>]
nf_hook_slow+0x84/0x140
Oct  1 10:49:23 afftar kernel: [    9.558130]  [<ffffffff81635460>] ?
inet_del_offload+0x40/0x40
Oct  1 10:49:23 afftar kernel: [    9.558133]  [<ffffffff81635e88>]
ip_rcv+0x2f8/0x3d0
Oct  1 10:49:23 afftar kernel: [    9.558136]  [<ffffffff815f82a2>]
__netif_receive_skb_core+0x562/0x790
Oct  1 10:49:23 afftar kernel: [    9.558139]  [<ffffffff815f84e8>]
__netif_receive_skb+0x18/0x60
Oct  1 10:49:23 afftar kernel: [    9.558142]  [<ffffffff815f91ce>]
process_backlog+0x9e/0x150
Oct  1 10:49:23 afftar kernel: [    9.558145]  [<ffffffff815f8989>]
net_rx_action+0x149/0x240
Oct  1 10:49:23 afftar kernel: [    9.558149]  [<ffffffff810924d5>]
__do_softirq+0xf5/0x2a0
Oct  1 10:49:23 afftar kernel: [    9.558152]  [<ffffffff810928ed>]
irq_exit+0xbd/0xd0
Oct  1 10:49:23 afftar kernel: [    9.558156]  [<ffffffff81711408>]
do_IRQ+0x58/0xf0
Oct  1 10:49:23 afftar kernel: [    9.558159]  [<ffffffff8170f1ed>]
common_interrupt+0x6d/0x6d

It did not happen with 3.15.10, and started to happen with 3.16 and all never
versions (last one checked - 3.18.9).

I was able to determine the commit which introduced it for me:

=====
commit    5d0c2b95bc57cf8fdc0e7b3e9d7e751eb65ad052

net: Preserve CHECKSUM_COMPLETE at validation

Currently when the first checksum in a packet is validated using
CHECKSUM_COMPLETE, ip_summed is overwritten to be CHECKSUM_UNNECESSARY so that
any subsequent checksums in the packet are not correctly validated. 

This patch adds csum_valid flag in sk_buff and uses that to indicate validated
checksum instead of setting CHECKSUM_UNNECESSARY. The bit is set accordingly in
the skb_checksum_validate_* functions. The flag is checked in
skb_checksum_complete, so that validation is communicated between checksum_init
and checksum_complete sequence in TCP and UDP. 

Signed-off-by: Tom Herbert <therbert@google.com> 
Signed-off-by: David S. Miller <davem@davemloft.net> 
=====

Later there were more fixes related to checksum computation, but neither of
those fixes mine (related to ppp/l2tp tunnel). All work seems to had been done
by Tom Herbert so please assign this report to him as possible.

There are several reports for this issue, it's not only me:

https://bugzilla.redhat.com/show_bug.cgi?id=1148612
https://bugzilla.redhat.com/show_bug.cgi?id=1200635
https://lkml.org/lkml/2015/2/16/472

It is easily reproducible here, feel free to contact me for more information.

-- 
You are receiving this mail because:
You are the assignee for the bug.
