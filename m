From: Sami Farin <hvtaifwkbgefbaei@gmail.com>
Subject: (ipt_log_packet, sb_add) 3.6.0-rc2 kernel panic - not syncing; Fatal
 exception in interrupt
Date: Tue, 21 Aug 2012 16:49:21 +0300
Message-ID: <20120821134921.behn76vzvhczf3gc@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sami Farin <hvtaifwkbgefbaei@gmail.com>, netdev@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kponet.fi ([213.145.209.38]:36841 "EHLO smtp.kponet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813Ab2HUOVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 10:21:03 -0400
Received: from safari.iki.fi (unknown [77.223.43.54])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.kponet.fi (Postfix) with ESMTP id 44937DACAC
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 16:49:22 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this with 3.6.0-rc2-g6dab7ede+ , x86_64 SMP, e1000e
gcc version 4.7.1 20120813 (Red Hat 4.7.1-7) (GCC) 
motherboard Asus P8Z68-V pro gen3

https://docs.google.com/open?id=0B_EMXtsx7o56UnJqNUNmMjNaSkE
(screencapture, 2.2 MB)

RIP [<ffffffff8109078c>] __lock_acquire.isra.25+0x15f/0xb20

Call Trace:
sb_add
lock_acquire
dump_ipv4_packet
_raw_read_lock_bh
dump_ipv4_packet
dump_ipv4_packet
sb_add
ipt_log_packet
log_tg
ipt_do_table
iptable_filter_hook
nf_iterate
ip_rcv_finish
nf_hook_slow
...

from vmlinux:
   0xffffffff8109075a <+301>:   cmpl   $0x0,0x1691a9f(%rip)        # 0xffffffff82722200 <debug_locks_silent>
   0xffffffff81090761 <+308>:   jne    0xffffffff8109073f <__lock_acquire+274>
   0xffffffff81090763 <+310>:   mov    $0xbd5,%esi
   0xffffffff81090768 <+315>:   mov    $0xffffffff81a4e0c9,%rdi
   0xffffffff8109076f <+322>:   callq  0xffffffff8104761f <warn_slowpath_null>
   0xffffffff81090774 <+327>:   xor    %eax,%eax
   0xffffffff81090776 <+329>:   jmpq   0xffffffff8109093a <__lock_acquire+781>
   0xffffffff8109077b <+334>:   mov    %r12d,%eax
   0xffffffff8109077e <+337>:   mov    0x8(%r14,%rax,8),%rbx
   0xffffffff81090783 <+342>:   test   %rbx,%rbx
   0xffffffff81090786 <+345>:   je     0xffffffff81090682 <__lock_acquire+85>
!! 0xffffffff8109078c <+351>:   lock incl 0x198(%rbx)
   0xffffffff81090793 <+358>:   mov    0x660(%r13),%r15d
   0xffffffff8109079a <+365>:   mov    0xedfa0f(%rip),%r10d        # 0xffffffff81f701b0 <oops_in_progress>
   0xffffffff810907a1 <+372>:   test   %r10d,%r10d
   0xffffffff810907a4 <+375>:   jne    0xffffffff810907b0 <__lock_acquire+387>
   0xffffffff810907a6 <+377>:   cmp    $0x2f,%r15d
   0xffffffff810907aa <+381>:   ja     0xffffffff810909fb <__lock_acquire+974>
   0xffffffff810907b0 <+387>:   sub    $0xffffffff81fb66e0,%rbx
   0xffffffff810907b7 <+394>:   sar    $0x4,%rbx
   0xffffffff810907bb <+398>:   movabs $0xef7bdef7bdef7bdf,%rax
   0xffffffff810907c5 <+408>:   imul   %rax,%rbx
   0xffffffff810907c9 <+412>:   mov    %ebx,%r11d
   0xffffffff810907cc <+415>:   lea    0x1(%rbx),%eax
   0xffffffff810907cf <+418>:   test   %r15d,%r15d
   0xffffffff810907d2 <+421>:   je     0xffffffff81090902 <__lock_acquire+725>
   0xffffffff810907d8 <+427>:   mov    %r15d,%edi

kernel 3.5.0-rc6-g4523e145+ worked ok for over a month..

# ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Full 
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Full 
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 2
        Transceiver: internal
        Auto-negotiation: on
        MDI-X: on
        Supports Wake-on: pumbg
        Wake-on: g
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: yes

# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: off
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on

-- 
Do what you love because life is too short for anything else.
