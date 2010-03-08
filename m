From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 08 Mar 2010 17:54:22 +0100
Message-ID: <4B952BBE.6070507@free.fr>
References: <4B88E431.6040609@parallels.com>	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>	<m1ocj6qljj.fsf@fess.ebiederm.org> <4B8E9370.3050300@parallels.com>	<m17hptjh3m.fsf@fess.ebiederm.org> <4B9158F5.5040205@parallels.com>	<m1vdda1pmx.fsf@fess.ebiederm.org> <4B926B1B.5070207@free.fr>	<m1aaulyy5c.fsf@fess.ebiederm.org> <4B92C886.9020507@free.fr> <m1fx4bxlfy.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m1fx4bxlfy.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> I have take an snapshot of my development tree and placed it at.
>
>
> git://git.kernel.org/pub/scm/linux/people/ebiederm/linux-2.6.33-nsfd-v5.git
>   

Hi Eric,

thanks for the pointer.

I tried to boot the kernel under qemu and I got this oops:

Loading /lib/kbd/keymaps/i386/azerty/fr.map
Creating block device nodes.
Creating character device nodes.
Making device-mapper control node
BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffff812df7e7>] netlink_broadcast+0x1bd/0x384
PGD 3cfd0067 PUD 3cfc1067 PMD 0
Oops: 0002 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/class/firmware/timeout
CPU 0
Pid: 841, comm: modprobe Not tainted 2.6.33 #1 /
RIP: 0010:[<ffffffff812df7e7>]  [<ffffffff812df7e7>] 
netlink_broadcast+0x1bd/0x384
RSP: 0018:ffff88003cfc3ca8  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff88003ce947f0 RCX: ffff88003cf877f0
RDX: ffff88003f939dd0 RSI: ffff88003f939ef0 RDI: ffff88003f939e00
RBP: ffff88003cfc3d18 R08: ffff88003f939d98 R09: ffff88003f939e88
R10: ffff88003cf87818 R11: 0000000000000286 R12: ffff88003f939d98
R13: ffff88003f939e88 R14: ffff88003ce94818 R15: ffff88003ce94800
FS:  00007f23a90a06f0(0000) GS:ffffffff8161b000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 000000003cfcd000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 841, threadinfo ffff88003cfc2000, task 
ffff88003d1db058)
Stack:
 0000000000000270 00000000000000d0 ffff88003f9377f0 ffffffff8203d630
<0> ffff88003f939f5c 0000000000000000 0000000000000001 0000000000000000
<0> ffff88003cf03000 0000000000000020 0000000000000004 ffff88003f939e88
Call Trace:
 [<ffffffff8121c1bd>] kobject_uevent_env+0x414/0x59b
 [<ffffffff81117432>] ? sysfs_create_file+0x25/0x27
 [<ffffffff8105eb13>] ? module_add_modinfo_attrs+0xd6/0xfc
 [<ffffffff8121c34f>] kobject_uevent+0xb/0xd
 [<ffffffff8105eba4>] mod_sysfs_setup+0x6b/0x99
 [<ffffffff810602aa>] load_module+0x12a2/0x16f1
 [<ffffffff81060b34>] sys_init_module+0x60/0x230
 [<ffffffff81002928>] system_call_fastpath+0x16/0x1b
Code: 00 ff c8 74 2a 8b 75 98 4c 89 ef e8 22 f8 fd ff 48 85 c0 49 89 c4 
74 3c 48 8d 50 38 48 8b 40 38 48 85 c0 74 0
2 ff 00 48 8b 42 08 <ff> 00 eb 4f 48 8b 55 b0 ff 02 49 83 7d 10 00 74 08 
4c 89 ef e8
RIP  [<ffffffff812df7e7>] netlink_broadcast+0x1bd/0x384
 RSP <ffff88003cfc3ca8>
CR2: 0000000000000000
---[ end trace 979d62b87f68fab3 ]---
netlink_recvmsg: missing NETLINK_CB proto: 15 pid: 0 dsg_group: 1
destructor = (null)
nlmsghdr: len=1080321121 type=27951 flags=646f seq=795176053 pid=1769169779

I will try to investigate further later - kid duty :)

  -- Daniel
