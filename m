From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 91471] New: add and removing macvlan link caused this dump
 trace
Date: Mon, 26 Jan 2015 13:32:22 +0000
Message-ID: <20150126133222.54cfea5e@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33681 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbAZNcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 08:32:31 -0500
Received: by mail-pa0-f44.google.com with SMTP id rd3so11752322pab.3
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 05:32:31 -0800 (PST)
Received: from uryu.home.lan ([144.49.132.22])
        by mx.google.com with ESMTPSA id nr15sm9766083pdb.73.2015.01.26.05.32.29
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 05:32:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 16 Jan 2015 19:16:28 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 91471] New: add and removing macvlan link caused this dump trace


https://bugzilla.kernel.org/show_bug.cgi?id=91471

            Bug ID: 91471
           Summary: add and removing macvlan link caused this dump trace
           Product: Networking
           Version: 2.5
    Kernel Version: 3.13.0-32-generic
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: ray.qiu@gmail.com
        Regression: No

It can be consistently reproduced.

 - Bring up a docker container
 - Create an ip link with type macvlan 
 - Move it to another netns for a container
 - Bring it up and assign ip address
 - Then, remove the link from the container and terminate the container.

 - Repeat the process again will cause this crash dump.

 ------------[ cut here ]------------
[ 2307.593973] kernel BUG at /build/buildd/linux-3.13.0/net/core/dev.c:6437!
[ 2307.594461] invalid opcode: 0000 [#1] SMP 
[ 2307.594883] Modules linked in: veth macvlan openvswitch gre vxlan ip_tunnel
libcrc32c xt_addrtype xt_conntrack ipt_MASQUERADE iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack bridge stp llc aufs
iptable_filter ip_tables x_tables hid_generic ppdev coretemp kvm_intel kvm
crct10dif_pclmul crc32_pclmul btusb ghash_clmulni_intel bluetooth vmw_balloon
aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd snd_ens1371
serio_raw snd_ac97_codec ac97_bus gameport snd_rawmidi snd_seq_device snd_pcm
usbhid hid snd_page_alloc snd_timer snd soundcore vmwgfx ttm shpchp drm
i2c_piix4 vmw_vmci parport_pc mac_hid lp parport psmouse ahci libahci e1000
mptspi mptscsih floppy mptbase vmw_pvscsi vmxnet3
[ 2307.598952] CPU: 0 PID: 6778 Comm: ip Tainted: G        W   
3.13.0-32-generic #57-Ubuntu
[ 2307.599433] Hardware name: VMware, Inc. VMware Virtual Platform/440BX
Desktop Reference Platform, BIOS 6.00 07/31/2013
[ 2307.600419] task: ffff8801353d5fc0 ti: ffff8801352f2000 task.ti:
ffff8801352f2000
[ 2307.600955] RIP: 0010:[<ffffffff8162447f>]  [<ffffffff8162447f>]
free_netdev+0xff/0x110
[ 2307.601475] RSP: 0018:ffff8801352f38d8  EFLAGS: 00010293
[ 2307.602000] RAX: 0000000000000001 RBX: ffff8800b6bdb018 RCX:
0000000000000254
[ 2307.602498] RDX: 0000000000000001 RSI: 0000000000000282 RDI:
0000000000000282
[ 2307.602988] RBP: ffff8801352f38f0 R08: 00018608fffffee0 R09:
ffffff90ffffffb0
[ 2307.603477] R10: ffffff90ffffffb0 R11: 00001398ffffffd0 R12:
ffff8800b6bdb060
[ 2307.603967] R13: ffff8800b6bdb000 R14: ffff8801352f3900 R15:
ffffffffa0485000
[ 2307.604455] FS:  00007f0e72cff740(0000) GS:ffff880138400000(0000)
knlGS:0000000000000000
[ 2307.604947] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2307.605433] CR2: 00007fff9b91fe60 CR3: 0000000134b11000 CR4:
00000000001407f0
[ 2307.606043] Stack:
[ 2307.606578]  00000000ffffffef ffffffff81cda240 ffff8801352f3920
ffff8801352f3ae8
[ 2307.607259]  ffffffff81632848 0000000000000000 ffff8800ba35c648
0000000000000000
[ 2307.607815]  ffffffff8163240e ffffffff81cda240 ffff8800ba35c610
ffff8800b6bdb000
[ 2307.608444] Call Trace:
[ 2307.608982]  [<ffffffff81632848>] rtnl_newlink+0x578/0x5d0
[ 2307.609809]  [<ffffffff8163240e>] ? rtnl_newlink+0x13e/0x5d0
[ 2307.610858]  [<ffffffff8162f0b9>] rtnetlink_rcv_msg+0x99/0x260
[ 2307.611868]  [<ffffffff81610e7e>] ? __alloc_skb+0x7e/0x2b0
[ 2307.612922]  [<ffffffff8162f020>] ? rtnetlink_rcv+0x30/0x30
[ 2307.613920]  [<ffffffff8164d659>] netlink_rcv_skb+0xa9/0xc0
[ 2307.614987]  [<ffffffff8162f018>] rtnetlink_rcv+0x28/0x30
[ 2307.615974]  [<ffffffff8164cc85>] netlink_unicast+0xd5/0x1b0
[ 2307.616948]  [<ffffffff8164d05f>] netlink_sendmsg+0x2ff/0x740
[ 2307.617957]  [<ffffffff816079eb>] sock_sendmsg+0x8b/0xc0
[ 2307.619037]  [<ffffffff811b1356>] ? __mem_cgroup_commit_charge+0x156/0x3d0
[ 2307.620042]  [<ffffffff816076de>] ? move_addr_to_kernel.part.16+0x1e/0x60
[ 2307.620963]  [<ffffffff816082a1>] ? move_addr_to_kernel+0x21/0x30
[ 2307.621874]  [<ffffffff81608273>] ___sys_sendmsg+0x3c3/0x3d0
[ 2307.622691]  [<ffffffff81727c64>] ? __do_page_fault+0x204/0x560
[ 2307.623572]  [<ffffffff8111155c>] ? acct_account_cputime+0x1c/0x20
[ 2307.624061]  [<ffffffff8109d7db>] ? account_user_time+0x8b/0xa0
[ 2307.624472]  [<ffffffff81608972>] __sys_sendmsg+0x42/0x80
[ 2307.624864]  [<ffffffff816089c2>] SyS_sendmsg+0x12/0x20
[ 2307.625265]  [<ffffffff8172c87f>] tracesys+0xe1/0xe6
[ 2307.625628] Code: a7 e6 ff 5b 41 5c 41 5d 5d c3 66 90 e8 2b 3a b6 ff e9 53
ff ff ff 66 0f 1f 44 00 00 4c 89 ef e8 b8 fe ff ff 5b 41 5c 41 5d 5d c3 <0f> 0b
66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 
[ 2307.626779] RIP  [<ffffffff8162447f>] free_netdev+0xff/0x110
[ 2307.627392]  RSP <ffff8801352f38d8>
[ 2307.629586] ---[ end trace 9c2a19ae6ba1d1f6 ]---

-- 
You are receiving this mail because:
You are the assignee for the bug.
