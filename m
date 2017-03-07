From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Tue, 7 Mar 2017 18:45:19 +0100
Message-ID: <CACT4Y+YxfXXbxx43DthTonirdA81ZxG50ASfFQ35_m3UYrW1fg@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
 <1488658514.9415.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <4e4d7d51-82de-b21e-cb5d-d804f7b88999@cumulusnetworks.com>
 <CACT4Y+Z1MvKbb35-jhaY=jEoR+t2u2TiUpkCR_oG3=VNmKjqvQ@mail.gmail.com>
 <14c01aea-6c2f-6ba5-6aee-52c55f410da7@cumulusnetworks.com>
 <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com> <12e91abf-dbe5-4d29-2940-b004768d642a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:33930 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755737AbdCGRpn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 12:45:43 -0500
Received: by mail-ua0-f172.google.com with SMTP id f54so12521121uaa.1
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 09:45:41 -0800 (PST)
In-Reply-To: <12e91abf-dbe5-4d29-2940-b004768d642a@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 7, 2017 at 6:17 PM, 'David Ahern' via syzkaller
<syzkaller@googlegroups.com> wrote:
> On 3/7/17 1:43 AM, Dmitry Vyukov wrote:
>> This is on c1ae3cfa0e89fa1a7ecc4c99031f5e9ae99d9201. No other kernel
>> output from your patch (pr_err).
>
> Is the below supposed to be from the same qemu instance at the time of
> the crash? cpu1 and cpu2 are both supposedly doing a route insert?


No, it's all from different instances.

>> ------------[ cut here ]------------
>> WARNING: CPU: 1 PID: 30179 at net/ipv6/ip6_fib.c:158
>> rt6_rcu_free+0x61/0x70 net/ipv6/ip6_fib.c:158
>> Kernel panic - not syncing: panic_on_warn set ...
>>
>> CPU: 1 PID: 30179 Comm: syz-executor3 Not tainted 4.11.0-rc1+ #310
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:16 [inline]
>>  dump_stack+0x2fb/0x3fd lib/dump_stack.c:52
>>  panic+0x20f/0x426 kernel/panic.c:180
>>  __warn+0x1c4/0x1e0 kernel/panic.c:541
>>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:584
>>  rt6_rcu_free+0x61/0x70 net/ipv6/ip6_fib.c:158
>>  rt6_release+0x1ee/0x290 net/ipv6/ip6_fib.c:189
>>  fib6_add_rt2node net/ipv6/ip6_fib.c:922 [inline]
>>  fib6_add+0x1d51/0x3290 net/ipv6/ip6_fib.c:1081
>>  __ip6_ins_rt+0x60/0x80 net/ipv6/route.c:948
>>  ip6_route_add+0x1a7/0x310 net/ipv6/route.c:2130
>>  inet6_rtm_newroute+0x191/0x1b0 net/ipv6/route.c:3294
>>  rtnetlink_rcv_msg+0x609/0x860 net/core/rtnetlink.c:4104
>>  netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
>>  rtnetlink_rcv+0x2a/0x40 net/core/rtnetlink.c:4110
>>  netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
>>  netlink_unicast+0x525/0x730 net/netlink/af_netlink.c:1257
>>  netlink_sendmsg+0xab3/0xe70 net/netlink/af_netlink.c:1803
>>  sock_sendmsg_nosec net/socket.c:633 [inline]
>>  sock_sendmsg+0xca/0x110 net/socket.c:643
>>  sock_write_iter+0x326/0x600 net/socket.c:846
>>  call_write_iter include/linux/fs.h:1733 [inline]
>>  do_iter_readv_writev fs/read_write.c:696 [inline]
>>  __do_readv_writev+0xbbc/0x10a0 fs/read_write.c:862
>>  do_readv_writev+0x13f/0x200 fs/read_write.c:894
>>  vfs_writev+0x87/0xc0 fs/read_write.c:921
>>  do_writev+0x110/0x2c0 fs/read_write.c:954
>>  SYSC_writev fs/read_write.c:1027 [inline]
>>  SyS_writev+0x27/0x30 fs/read_write.c:1024
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>> RIP: 0033:0x4458d9
>> RSP: 002b:00007f31fcf33b58 EFLAGS: 00000292 ORIG_RAX: 0000000000000014
>> RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004458d9
>> RDX: 0000000000000001 RSI: 00000000207cd000 RDI: 0000000000000005
>> RBP: 00000000006e30c0 R08: 0000000000000000 R09: 0000000000000000
>> R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000708000
>> R13: 0000000020fad000 R14: 0000000000001000 R15: 0000000000000003
>>
>>
>>
>> ------------[ cut here ]------------
>> WARNING: CPU: 2 PID: 31175 at net/ipv6/ip6_fib.c:158
>> rt6_rcu_free+0x61/0x70 net/ipv6/ip6_fib.c:158
>> Kernel panic - not syncing: panic_on_warn set ...
>>
>> CPU: 2 PID: 31175 Comm: syz-executor1 Not tainted 4.11.0-rc1+ #310
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:16 [inline]
>>  dump_stack+0x2fb/0x3fd lib/dump_stack.c:52
>>  panic+0x20f/0x426 kernel/panic.c:180
>>  __warn+0x1c4/0x1e0 kernel/panic.c:541
>>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:584
>>  rt6_rcu_free+0x61/0x70 net/ipv6/ip6_fib.c:158
>>  rt6_release+0x1ee/0x290 net/ipv6/ip6_fib.c:189
>>  fib6_add_rt2node net/ipv6/ip6_fib.c:922 [inline]
>>  fib6_add+0x1d51/0x3290 net/ipv6/ip6_fib.c:1081
>> kvm_vm_ioctl_deassign_device: device hasn't been assigned before, so
>> cannot be deassigned
>>  __ip6_ins_rt+0x60/0x80 net/ipv6/route.c:948
>>  ip6_route_add+0x1a7/0x310 net/ipv6/route.c:2130
>>  inet6_rtm_newroute+0x191/0x1b0 net/ipv6/route.c:3294
>>  rtnetlink_rcv_msg+0x609/0x860 net/core/rtnetlink.c:4104
>>  netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
>>  rtnetlink_rcv+0x2a/0x40 net/core/rtnetlink.c:4110
>>  netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
>>  netlink_unicast+0x525/0x730 net/netlink/af_netlink.c:1257
>>  netlink_sendmsg+0xab3/0xe70 net/netlink/af_netlink.c:1803
>>  sock_sendmsg_nosec net/socket.c:633 [inline]
>>  sock_sendmsg+0xca/0x110 net/socket.c:643
>>  sock_write_iter+0x326/0x600 net/socket.c:846
>>  call_write_iter include/linux/fs.h:1733 [inline]
>>  do_iter_readv_writev fs/read_write.c:696 [inline]
>>  __do_readv_writev+0xbbc/0x10a0 fs/read_write.c:862
>>  do_readv_writev+0x13f/0x200 fs/read_write.c:894
>>  vfs_writev+0x87/0xc0 fs/read_write.c:921
>>  do_writev+0x110/0x2c0 fs/read_write.c:954
>>  SYSC_writev fs/read_write.c:1027 [inline]
>>  SyS_writev+0x27/0x30 fs/read_write.c:1024
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>> RIP: 0033:0x4458d9
>> RSP: 002b:00007f1639006b58 EFLAGS: 00000292 ORIG_RAX: 0000000000000014
>> RAX: ffffffffffffffda RBX: 0000000000000019 RCX: 00000000004458d9
>> RDX: 0000000000000001 RSI: 00000000207cd000 RDI: 0000000000000019
>> RBP: 00000000006e30c0 R08: 0000000000000000 R09: 0000000000000000
>> R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000708000
>> R13: 0000000000000010 R14: 0000000000000003 R15: 0000000000000000
>>
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
