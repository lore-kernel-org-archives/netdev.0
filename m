From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 98421] New: my kernel crash when send a skb in segment
 function
Date: Fri, 15 May 2015 08:15:52 -0700
Message-ID: <20150515081552.34bbfa7c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36290 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934764AbbEOPPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 11:15:51 -0400
Received: by igbpi8 with SMTP id pi8so224495873igb.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 08:15:50 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id kr9sm2196339pab.30.2015.05.15.08.15.49
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 May 2015 08:15:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 15 May 2015 14:06:52 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 98421] New: my kernel crash when send a skb in segment function


https://bugzilla.kernel.org/show_bug.cgi?id=98421

            Bug ID: 98421
           Summary: my kernel crash when send a skb in segment function
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.0
          Hardware: Intel
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: cxasm@qq.com
        Regression: No

First, i gave the crash message on next:

KERNEL: /usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux
    DUMPFILE: vmcore  [PARTIAL DUMP]
        CPUS: 8
        DATE: Wed May  6 17:02:24 2015
      UPTIME: 05:51:08
LOAD AVERAGE: 3.68, 2.43, 2.54
       TASKS: 364
    NODENAME: host-217
     RELEASE: 3.10.0-123.el7.x86_64
     VERSION: #1 SMP Sat Apr 25 01:38:19 CST 2015
     MACHINE: x86_64  (2133 Mhz)
      MEMORY: 72 GB
       PANIC: "kernel BUG at net/core/skbuff.c:2966!"
         PID: 9127
     COMMAND: "qemu-kvm"
        TASK: ffff881249e9ad80  [THREAD_INFO: ffff88124aafe000]
         CPU: 0
       STATE: TASK_RUNNING (PANIC)

crash> bt
PID: 9127   TASK: ffff881249e9ad80  CPU: 0   COMMAND: "qemu-kvm"
 #0 [ffff88095bc033d0] machine_kexec at ffffffff81041501
 #1 [ffff88095bc03428] crash_kexec at ffffffff810d0be2
 #2 [ffff88095bc034f8] oops_end at ffffffff815f6ec8
 #3 [ffff88095bc03520] die at ffffffff8101635f
 #4 [ffff88095bc03550] do_trap at ffffffff815f65a0
 #5 [ffff88095bc035a0] do_invalid_op at ffffffff81013134
 #6 [ffff88095bc03650] invalid_op at ffffffff816002de
    [exception RIP: skb_segment+2382]
    RIP: ffffffff814cdaee  RSP: ffff88095bc03700  RFLAGS: 00010282
    RAX: 00000000fffffff2  RBX: ffff880943fa0f00  RCX: ffff8807b83cb2f0
    RDX: 0000000000000000  RSI: ffff8807b83cb200  RDI: 0000000000000002
    RBP: ffff88095bc037b8   R8: 0000000000000046   R9: 0000000000000000
    R10: ffff880943fa0000  R11: 00000000000005ee  R12: ffff8807b83cb4f0
    R13: 0000000000000000  R14: ffff880943fa0a00  R15: 0000000000000058
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #7 [ffff88095bc03708] enqueue_entity at ffffffff810a3227
 #8 [ffff88095bc037c0] tcp_gso_segment at ffffffff8153e61a
 #9 [ffff88095bc03818] inet_gso_segment at ffffffff8154e982
#10 [ffff88095bc03880] skb_mac_gso_segment at ffffffff814dc89c
#11 [ffff88095bc038b8] __skb_gso_segment at ffffffff814dc9ed
#12 [ffff88095bc038d8] dev_hard_start_xmit at ffffffff814dcd0a
#13 [ffff88095bc03930] sch_direct_xmit at ffffffff814fc20e
#14 [ffff88095bc03970] dev_queue_xmit at ffffffff814dd308
#15 [ffff88095bc039c0] netdev_send at ffffffffa04d85cb [openvswitch]
#16 [ffff88095bc039f0] ovs_vport_send at ffffffffa04d789b [openvswitch]
#17 [ffff88095bc03a18] do_output at ffffffffa04cc17e [openvswitch]
#18 [ffff88095bc03a30] do_execute_actions at ffffffffa04cc653 [openvswitch]
#19 [ffff88095bc03ad0] ovs_execute_actions at ffffffffa04ccf0b [openvswitch]
#20 [ffff88095bc03ae0] ovs_dp_process_received_packet at ffffffffa04d0d9f
[openvswitch]
#21 [ffff88095bc03bc8] ovs_vport_receive at ffffffffa04d778a [openvswitch]
#22 [ffff88095bc03bf0] netdev_frame_hook at ffffffffa04d8731 [openvswitch]
#23 [ffff88095bc03c18] __netif_receive_skb_core at ffffffff814dab82
#24 [ffff88095bc03c78] __netif_receive_skb at ffffffff814db208
#25 [ffff88095bc03c98] netif_receive_skb at ffffffff814db290
#26 [ffff88095bc03cc8] napi_gro_complete at ffffffff814db39d
#27 [ffff88095bc03cf8] dev_gro_receive at ffffffff814dba3e
#28 [ffff88095bc03d48] napi_gro_receive at ffffffff814dbcc2
#29 [ffff88095bc03d60] bnx2_poll_work at ffffffffa004599f [bnx2]
#30 [ffff88095bc03e20] bnx2_poll at ffffffffa0046627 [bnx2]
#31 [ffff88095bc03e60] net_rx_action at ffffffff814db65a
#32 [ffff88095bc03eb8] __do_softirq at ffffffff81067497
#33 [ffff88095bc03f28] call_softirq at ffffffff816004dc
#34 [ffff88095bc03f40] do_softirq at ffffffff81014d35
#35 [ffff88095bc03f58] irq_exit at ffffffff81067abd
#36 [ffff88095bc03f78] do_IRQ at ffffffff81600dd8
--- <IRQ stack> ---
#37 [ffff88124aaffcd8] ret_from_intr at ffffffff815f5e2d
    [exception RIP: _raw_spin_unlock_irqrestore+27]
    RIP: ffffffff815f58cb  RSP: ffff88124aaffd80  RFLAGS: 00000246
    RAX: 00000000000c775e  RBX: ffff88095bc345c0  RCX: 00000000000f4240
    RDX: 00001329841e429e  RSI: 0000000000000246  RDI: 0000000000000246
    RBP: ffff88124aaffd88   R8: 0000000000000000   R9: 0000000000000000
    R10: 0000000000000000  R11: 000000000000022e  R12: 000000008109b475
    R13: ffffffff810a222d  R14: ffff88124aaffd28  R15: 0000000000000000
    ORIG_RAX: ffffffffffffffb9  CS: 0010  SS: 0018
#38 [ffff88124aaffd90] try_to_wake_up at ffffffff81098a56
#39 [ffff88124aaffdd8] wake_up_state at ffffffff81098b80
#40 [ffff88124aaffde8] wake_futex at ffffffff810c1886
#41 [ffff88124aaffe08] futex_wake at ffffffff810c19d5
#42 [ffff88124aaffe70] do_futex at ffffffff810c4412
#43 [ffff88124aafff08] sys_futex at ffffffff810c4960
#44 [ffff88124aafff80] system_call_fastpath at ffffffff815feb99
    RIP: 00007f6c01b1d01a  RSP: 00007f6baa7fbaa8  RFLAGS: 00000206
    RAX: 00000000000000ca  RBX: ffffffff815feb99  RCX: ffffffffffffffff
    RDX: 0000000000000001  RSI: 0000000000000081  RDI: 00007f6c038ad900
    RBP: 00007f6baa7fbba0   R8: 0000000000000000   R9: 0000000000000000
    R10: 0000000000000000  R11: 0000000000000206  R12: 0000000000000000
    R13: 00007f6baa7fc700  R14: 00007f6baa7fc9c0  R15: 0000000000000000
    ORIG_RAX: 00000000000000ca  CS: 0033  SS: 002b


We are at a virtual envirment with kvm . The virtual switch is openvswitch .
In these days, some computer was crashed !!! 

crash message is this: 
"kernel BUG at net/core/skbuff.c:2966!"

skb_shinfo(nskb)->tx_flags = skb_shinfo(head_skb)->tx_flags &
            SKBTX_SHARED_FRAG;

        while (pos < offset + len) {
            if (i >= nfrags) {
                BUG_ON(skb_headlen(list_skb));  ---- here is the panic 2966 

                i = 0;
                nfrags = skb_shinfo(list_skb)->nr_frags;
                frag = skb_shinfo(list_skb)->frags;
                frag_skb = list_skb;

                BUG_ON(!nfrags);

                list_skb = list_skb->next;
            }


I searched all message with yahoo (we can't use google , big china fuck network
!) . I also searched all the bug with function skb_segment , but can not see
the same probleam .

a skb with it's frag->list has a value . the first frag is also a skb ,but
skb_shinfo(list_skb) is not zero ,so skb_segmnet function throw a oops.

I debuged the vmcore files with crash tool. 


first skb infomation:
struct sk_buff {
  next = 0x0, 
  prev = 0x0, 
  tstamp = {
    tv64 = 1430902944571018150
  }, 
  sk = 0x0, 
  dev = 0xffff881217960000, 
  cb =
"N\000\000\000\024\000\000\000\020;\300[\t\210\377\377\000\000\000\000\000\000\000\000\000\210\237J\022\210\377\377\000\000\000\000\000\000\000\000\000\a\372C\t\210\377\377", 
  _skb_refdst = 0, 
  sp = 0x0, 
  len = 1902, 
  data_len = 1814, 
  mac_len = 18, 
  hdr_len = 0, 
  {
    csum = 1048692, 
    {
      csum_start = 116, 
      csum_offset = 16
    }
  }, 
  priority = 0, 
  local_df = 0 '\000', 
  cloned = 0 '\000', 
  ip_summed = 3 '\003', 
  nohdr = 0 '\000', 
  nfctinfo = 0 '\000', 
  pkt_type = 3 '\003', 
  fclone = 0 '\000', 
  ipvs_property = 0 '\000', 
  peeked = 0 '\000', 
  nf_trace = 0 '\000', 
  protocol = 129, 
  destructor = 0x0, 
  nfct = 0x0, 
  nf_bridge = 0x0, 
  skb_iif = 5, 
  rxhash = 1373124890, 
  vlan_proto = 129, 
  vlan_tci = 0, 
  tc_index = 0, 
  tc_verd = 8192, 
  queue_mapping = 0, 
  ndisc_nodetype = 0 '\000', 
  pfmemalloc = 0 '\000', 
  ooo_okay = 0 '\000', 
  l4_rxhash = 0 '\000', 
  wifi_acked_valid = 0 '\000', 
  wifi_acked = 0 '\000', 
  no_fcs = 0 '\000', 
  head_frag = 0 '\000', 
  encapsulation = 0 '\000', 
  {
    napi_id = 0, 
    dma_cookie = 0
  }, 
  secmark = 0, 
  {
    mark = 0, 
    dropcount = 0, 
    reserved_tailroom = 0
  }, 
  inner_protocol = 0, 
  inner_transport_header = 0, 
  inner_network_header = 0, 
  inner_mac_header = 0, 
  transport_header = 116, 
  network_header = 96, 
  mac_header = 78, 
  rh_reserved1 = 0, 
  rh_reserved2 = 0, 
  rh_reserved3 = 0, 
  rh_reserved4 = 0, 
  tail = 166, 
  end = 192, 
  head = 0xffff8807b83cb400 "", 
  data = 0xffff8807b83cb44e "\034oe\f0\327\034oe\fZ*\201", 
  truesize = 5376, 
  users = {
    counter = 1
  }
}

the first frag in frag-list is:

struct sk_buff {
  next = 0xffff880943fa0700, 
  prev = 0x0, 
  tstamp = {
    tv64 = 0
  }, 
  sk = 0x0, 
  dev = 0xffff880949410000, 
  cb =
"\000\000\000\000\000\000\000\000\000\000\000\000\064\000\000\000\000\000\000\000\001\000\001\000\037\346<\001\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000", 
  _skb_refdst = 0, 
  sp = 0x0, 
  len = 1430, 
  data_len = 0, 
  mac_len = 14, 
  hdr_len = 148, 
  {
    csum = 0, 
    {
      csum_start = 0, 
      csum_offset = 0
    }
  }, 
  priority = 0, 
  local_df = 0 '\000', 
  cloned = 1 '\001', 
  ip_summed = 1 '\001', 
  nohdr = 0 '\000', 
  nfctinfo = 0 '\000', 
  pkt_type = 3 '\003', 
  fclone = 0 '\000', 
  ipvs_property = 0 '\000', 
  peeked = 0 '\000', 
  nf_trace = 0 '\000', 
  protocol = 8, 
  destructor = 0x0, 
  nfct = 0x0, 
  nf_bridge = 0x0, 
  skb_iif = 0, 
  rxhash = 1373124890, 
  vlan_proto = 129, 
  vlan_tci = 4097, 
  tc_index = 0, 
  tc_verd = 0, 
  queue_mapping = 1, 
  ndisc_nodetype = 0 '\000', 
  pfmemalloc = 0 '\000', 
  ooo_okay = 0 '\000', 
  l4_rxhash = 0 '\000', 
  wifi_acked_valid = 0 '\000', 
  wifi_acked = 0 '\000', 
  no_fcs = 0 '\000', 
  head_frag = 0 '\000', 
  encapsulation = 0 '\000', 
  {
    napi_id = 0, 
    dma_cookie = 0
  }, 
  secmark = 0, 
  {
    mark = 0, 
    dropcount = 0, 
    reserved_tailroom = 0
  }, 
  inner_protocol = 0, 
  inner_transport_header = 0, 
  inner_network_header = 0, 
  inner_mac_header = 0, 
  transport_header = 116, 
  network_header = 96, 
  mac_header = 82, 
  rh_reserved1 = 1140461760, 
  rh_reserved2 = 4294936585, 
  rh_reserved3 = 1250139880, 
  rh_reserved4 = 4294936585, 
  tail = 1596, 
  end = 1728, 
  head = 0xffff8810daff9000 "", 
  data = 0xffff8810daff90a6 "\203\257\021\"", 
  truesize = 2304, 
  users = {
    counter = 1
  }
}

because len = 1430, data_len = 0, so BUG_ON(skb_headlen(list_skb)) occur !!

maybe this problem is cause by dev_gro_receive  or skb_gro_receive , i have no
ides .

For a week I have been tortured by the question. Help me , big cows !!

-- 
You are receiving this mail because:
You are the assignee for the bug.
