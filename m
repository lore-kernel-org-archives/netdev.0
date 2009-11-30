From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [-next Nov 25] eHEA driver failure during boot(bisected)
Date: Mon, 30 Nov 2009 17:11:16 +0100
Message-ID: <4B13EEA4.5060702@de.ibm.com>
References: <20091125235333.37c425ec.sfr@canb.auug.org.au> <4B0E3E18.7020308@in.ibm.com> <4B136911.9010905@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, Jan-Bernd Themann <THEMANN@de.ibm.com>,
	HERING2@de.ibm.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4B136911.9010905@in.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sachin,

thanks for the information. I tried to reproduce it on our machine, but 
when I "insmod" the module, I don't hit this problem with the code from 
latest -next git head.
What compiler and which .config did you use? Any special options enabled?

Thanks,
Jan-Bernd

Sachin Sant schrieb:
> eHEA driver fails to initialize on a power6 box while booting
> latest next. Following are the messages which gets
> logged during failure (this is with 20091125 next(f3645ca..))
> 
> Unable to handle kernel paging request for data at address 
> 0x409d0148e8e40018
> Faulting instruction address: 0xc00000000003c0cc
> Oops: Kernel access of bad area, sig: 11 [#1]
> SMP NR_CPUS=1024 NUMA pSeries
> Modules linked in: fuse loop dm_mod sr_mod cdrom ehea sg sd_mod 
> crc_t10dif ibmvscsic scsi_transport_srp scsi_tgt scsi_mod
> NIP: c00000000003c0cc LR: c00000000003ce50 CTR: 0000000000091b94
> REGS: c00000000cade820 TRAP: 0300   Not tainted  
> (2.6.32-rc8-autotest-next-20091125)
> MSR: 8000000000001032 <ME,IR,DR>  CR: 28020424  XER: 00000020
> DAR: 409d0148e8e40018, DSISR: 0000000040000000
> TASK = c00000000c818d60[1683] 'ip' THREAD: c00000000cadc000 CPU: 1
> GPR00: 0000000000000010 c00000000cadeaa0 c000000000b28340 409d0148e8e40008
> GPR04: d00008008000f040 c00000000cadeb20 0000000000001000 0000000000000000
> GPR08: 000000000000001c c0000000018c0398 0000000000000000 c000000000bc0000
> GPR12: 8000000000009032 c000000000bc2880 00000000ffffffff ffffffffffffffff
> GPR16: 00000000203c8fc0 c00000000cadf4a8 c00000000cadf450 c00000000e4c0000
> GPR20: 0000000000000300 0000000000000201 c000000000c68590 c000000000bc0000
> GPR24: 0000000000000000 0000000000e5f87e 0000000000000001 c000000009920000
> GPR28: 0000000000000000 d00008008000f040 0000000000000000 c000000000a63328
> NIP [c00000000003c0cc] .subpage_protection+0x48/0x8c
> LR [c00000000003ce50] .hash_page+0x3e0/0x45c
> Call Trace:
> [c00000000cadeaa0] [00000000ffffffff] 0xffffffff (unreliable)
> [c00000000cadeb90] [c0000000000055d0] .do_hash_page+0x50/0x6c
> --- Exception: 301 at .ehea_create_cq+0x234/0x2bc [ehea]
>   LR = .ehea_create_cq+0x1c0/0x2bc [ehea]
> [c00000000cadef40] [d0000000015e46fc] .ehea_init_port_res+0xb4/0x47c [ehea]
> [c00000000cadf000] [d0000000015e4bd8] .ehea_up+0x114/0x6bc [ehea]
> [c00000000cadf110] [d0000000015e51e0] .ehea_open+0x60/0x114 [ehea]
> [c00000000cadf1b0] [c000000000542e7c] .dev_open+0x11c/0x19c
> [c00000000cadf240] [c000000000541e7c] .dev_change_flags+0x10c/0x214
> [c00000000cadf2e0] [c00000000054e0f8] .do_setlink+0x304/0x41c
> [c00000000cadf3c0] [c00000000054f324] .rtnl_newlink+0x388/0x600
> [c00000000cadf5d0] [c00000000054ef50] .rtnetlink_rcv_msg+0x260/0x2ac
> [c00000000cadf680] [c000000000568104] .netlink_rcv_skb+0x74/0x108
> [c00000000cadf710] [c00000000054eccc] .rtnetlink_rcv+0x34/0x58
> [c00000000cadf7a0] [c000000000567bfc] .netlink_unicast+0x32c/0x408
> [c00000000cadf870] [c0000000005688d8] .netlink_sendmsg+0x2d0/0x310
> [c00000000cadf950] [c000000000529c9c] .sock_sendmsg+0xe0/0x11c
> [c00000000cadfb50] [c000000000529fc8] .SyS_sendmsg+0x1f4/0x288
> [c00000000cadfd70] [c000000000527f88] .SyS_socketcall+0x214/0x280
> [c00000000cadfe30] [c0000000000085b4] syscall_exit+0x0/0x40
> Instruction dump:
> 78000020 7fa40040 409d0020 7889aae0 39290072 79291f24 7d2b4a14 e8690010
> 2fa30000 419e0048 788014e2 78001f24 <7c63002a> 2fa30000 419e0034 788084a2
> ---[ end trace cacb4bbddb53f7bd ]---
> 
> This problem was introduced between next-20091119 and next-20091120.
> Bisection leads to the following patch :
> 
> commit 2939e275994977b6c9eb7fd082b7b0caa35b96b0
> netsched: Allow var_sk_bound_if meta to work on all namespaces
> 
> If i revert this patch the eHEA interface is initialized properly.
> 
> Thanks
> -Sachin
> 
> 
