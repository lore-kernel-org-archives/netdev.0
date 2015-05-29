From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 99161] New: 2.6.32.66 PPC Oops in tcp_send_fin
Date: Fri, 29 May 2015 08:52:11 -0700
Message-ID: <1432914731.7456.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150529081200.7cf08fd6@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	varenet@parisc-linux.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:34670 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753479AbbE2PwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 11:52:14 -0400
Received: by ieczm2 with SMTP id zm2so66078729iec.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 08:52:13 -0700 (PDT)
In-Reply-To: <20150529081200.7cf08fd6@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-29 at 08:12 -0700, Stephen Hemminger wrote:
> I think 2.6.32 is so old no one will care.
> 
> Begin forwarded message:
> 
> Date: Fri, 29 May 2015 09:12:45 +0000
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
> Subject: [Bug 99161] New: 2.6.32.66 PPC Oops in tcp_send_fin
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=99161
> 
>             Bug ID: 99161
>            Summary: 2.6.32.66 PPC Oops in tcp_send_fin
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32.66
>           Hardware: PPC-32
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>           Assignee: shemminger@linux-foundation.org
>           Reporter: varenet@parisc-linux.org
>         Regression: No
> 
> I just updated my trusty old PPC box to longterm 2.6.32.66 (was running .65
> before that with zero issue) and it started spewing oopses at me like hell
> broke loose. This machine is primarily used as a DNS and MX (albeit under low
> pressure).
> 
> 
> Unable to handle kernel paging request for data at address 0x0000003c
> Faulting instruction address: 0xc0344ffc
> Oops: Kernel access of bad area, sig: 11 [#1]
> PowerMac
> Modules linked in: sch_sfq cls_u32 sch_cbq xt_recent xt_length iptable_mangle
> NIP: c0344ffc LR: c0335b00 CTR: c03357b0
> REGS: cb441dd0 TRAP: 0300   Not tainted  (2.6.32.66)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 44244488  XER: 00000000
> DAR: 0000003c, DSISR: 40000000
> TASK = e39f0900[14281] 'smtpd' THREAD: cb440000
> GPR00: dbc00000 cb441e80 e39f0900 e397cc60 00000004 e3948100 00000003 00000000 
> GPR08: 00000000 00000020 01afffff ffffffe4 24244482 207bb198 201322b4 2065d898 
> GPR16: 2065d878 2065d7e0 2065d858 2065d7e0 2065d7e0 206733b0 20673060 bfcc7f50 
> GPR24: bfcc7f40 20b7eeb0 bfcc7f40 00000000 00000000 e397ccc4 dbc00020 e397cc60 
> NIP [c0344ffc] tcp_send_fin+0x48/0x21c
> LR [c0335b00] tcp_close+0x350/0x3fc
> Call Trace:
> [cb441e80] [cb441e84] 0xcb441e84 (unreliable)
> [cb441ea0] [c0335b00] tcp_close+0x350/0x3fc
> [cb441ec0] [c035733c] inet_release+0x58/0x88
> [cb441ed0] [c02e1fe8] sock_release+0x34/0xa8
> [cb441ee0] [c02e2078] sock_close+0x1c/0x40
> [cb441ef0] [c009cddc] __fput+0xf4/0x22c
> [cb441f10] [c0098ea4] filp_close+0x64/0xa0
> [cb441f30] [c0098f7c] sys_close+0x9c/0xc0
> [cb441f40] [c0012988] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0x20368780
>     LR = 0x2064bc48
> Instruction dump:
> 90010024 93c10018 83dd0004 7f9df000 419e0080 2f9e0000 419e007c 80030104 
> 2f800000 419e0180 39200020 3bde0020 <8809001c> 60000001 9809001c 813e0014 
> ---[ end trace 13772745934a0d1f ]---
> Unable to handle kernel paging request for data at address 0x0000003c
> Faulting instruction address: 0xc0344ffc
> Oops: Kernel access of bad area, sig: 11 [#2]
> PowerMac
> Modules linked in: sch_sfq cls_u32 sch_cbq xt_recent xt_length iptable_mangle
> NIP: c0344ffc LR: c0335b00 CTR: c03357b0
> REGS: dbc09d60 TRAP: 0300   Tainted: G      D     (2.6.32.66)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 42004288  XER: 20000000
> DAR: 0000003c, DSISR: 40000000
> TASK = e394f180[14867] 'imapd' THREAD: dbc08000
> GPR00: dbc00d80 dbc09e10 e394f180 e397c420 00000009 ef10eb80 00000003 00000000 
> GPR08: 00000000 00000020 00000000 e397c498 22004282 1002bad4 1023e7b0 10020000 
> GPR16: 10020000 10020000 10020000 10020000 10007678 1000766c 00000008 1023d168 
> GPR24: 10020000 10018c28 00000000 00000000 00000000 e397c484 ef327c20 e397c420 
> NIP [c0344ffc] tcp_send_fin+0x48/0x21c
> LR [c0335b00] tcp_close+0x350/0x3fc
> Call Trace:
> [dbc09e10] [1000766c] 0x1000766c (unreliable)
> [dbc09e30] [c0335b00] tcp_close+0x350/0x3fc
> [dbc09e50] [c035733c] inet_release+0x58/0x88
> [dbc09e60] [c02e1fe8] sock_release+0x34/0xa8
> [dbc09e70] [c02e2078] sock_close+0x1c/0x40
> [dbc09e80] [c009cddc] __fput+0xf4/0x22c
> [dbc09ea0] [c0098ea4] filp_close+0x64/0xa0
> [dbc09ec0] [c00318e0] put_files_struct+0x108/0x124
> [dbc09ee0] [c0033824] do_exit+0x4fc/0x630
> [dbc09f20] [c003399c] do_group_exit+0x44/0xa4
> [dbc09f30] [c0033a10] sys_exit_group+0x14/0x28
> [dbc09f40] [c0012988] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0xfd96f38
>     LR = 0xfd96f04
> Instruction dump:
> 90010024 93c10018 83dd0004 7f9df000 419e0080 2f9e0000 419e007c 80030104 
> 2f800000 419e0180 39200020 3bde0020 <8809001c> 60000001 9809001c 813e0014 
> ---[ end trace 13772745934a0d20 ]---
> Fixing recursive fault but reboot is needed!
> Unable to handle kernel paging request for data at address 0x0000003c
> Faulting instruction address: 0xc0344ffc
> Oops: Kernel access of bad area, sig: 11 [#3]
> PowerMac
> Modules linked in: sch_sfq cls_u32 sch_cbq xt_recent xt_length iptable_mangle
> NIP: c0344ffc LR: c0335b00 CTR: c03357b0
> REGS: cb463dd0 TRAP: 0300   Tainted: G      D     (2.6.32.66)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 44244488  XER: 00000000
> DAR: 0000003c, DSISR: 40000000
> TASK = e39f1f80[15093] 'smtpd' THREAD: cb462000
> GPR00: dbc00480 cb463e80 e39f1f80 e397d4a0 00000004 e3878f80 00000003 00000000 
> GPR08: 00000000 00000020 01afffff ffffffd6 24244482 206eb198 200622b4 2058d898 
> GPR16: 2058d878 2058d7e0 2058d858 2058d7e0 2058d7e0 205a33b0 205a3060 bf900600 
> GPR24: bf9005f0 20b22eb0 bf9005f0 00000000 00000000 e397d504 dbc004a0 e397d4a0 
> NIP [c0344ffc] tcp_send_fin+0x48/0x21c
> LR [c0335b00] tcp_close+0x350/0x3fc
> Call Trace:
> [cb463e80] [cb463e84] 0xcb463e84 (unreliable)
> [cb463ea0] [c0335b00] tcp_close+0x350/0x3fc
> [cb463ec0] [c035733c] inet_release+0x58/0x88
> [cb463ed0] [c02e1fe8] sock_release+0x34/0xa8
> [cb463ee0] [c02e2078] sock_close+0x1c/0x40
> [cb463ef0] [c009cddc] __fput+0xf4/0x22c
> [cb463f10] [c0098ea4] filp_close+0x64/0xa0
> [cb463f30] [c0098f7c] sys_close+0x9c/0xc0
> [cb463f40] [c0012988] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0x20298780
>     LR = 0x2057bc48
> Instruction dump:
> 90010024 93c10018 83dd0004 7f9df000 419e0080 2f9e0000 419e007c 80030104 
> 2f800000 419e0180 39200020 3bde0020 <8809001c> 60000001 9809001c 813e0014 
> ---[ end trace 13772745934a0d21 ]---
> Unable to handle kernel paging request for data at address 0x0000003c
> Faulting instruction address: 0xc0344ffc
> Oops: Kernel access of bad area, sig: 11 [#4]
> PowerMac
> Modules linked in: sch_sfq cls_u32 sch_cbq xt_recent xt_length iptable_mangle
> NIP: c0344ffc LR: c0335b00 CTR: c03357b0
> REGS: cc6a3dd0 TRAP: 0300   Tainted: G      D     (2.6.32.66)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 44244488  XER: 00000000
> DAR: 0000003c, DSISR: 40000000
> TASK = ef3c6400[16550] 'smtpd' THREAD: cc6a2000
> GPR00: e38ce900 cc6a3e80 ef3c6400 ef33f180 00000004 e3881b00 00000003 00000000 
> GPR08: 00000000 00000020 002fffff ffffffcf 24244482 2036b198 1fce22b4 2020d898 
> GPR16: 2020d878 2020d7e0 2020d858 2020d7e0 2020d7e0 202233b0 20223060 bfde05a0 
> GPR24: bfde0590 20965eb0 bfde0590 00000000 00000000 ef33f1e4 e38ce920 ef33f180 
> NIP [c0344ffc] tcp_send_fin+0x48/0x21c
> LR [c0335b00] tcp_close+0x350/0x3fc
> Call Trace:
> [cc6a3e80] [cc6a3e84] 0xcc6a3e84 (unreliable)
> [cc6a3ea0] [c0335b00] tcp_close+0x350/0x3fc
> [cc6a3ec0] [c035733c] inet_release+0x58/0x88
> [cc6a3ed0] [c02e1fe8] sock_release+0x34/0xa8
> [cc6a3ee0] [c02e2078] sock_close+0x1c/0x40
> [cc6a3ef0] [c009cddc] __fput+0xf4/0x22c
> [cc6a3f10] [c0098ea4] filp_close+0x64/0xa0
> [cc6a3f30] [c0098f7c] sys_close+0x9c/0xc0
> [cc6a3f40] [c0012988] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0x1ff18780
>     LR = 0x201fbc48
> Instruction dump:
> 90010024 93c10018 83dd0004 7f9df000 419e0080 2f9e0000 419e007c 80030104 
> 2f800000 419e0180 39200020 3bde0020 <8809001c> 60000001 9809001c 813e0014 
> ---[ end trace 13772745934a0d22 ]---
> Unable to handle kernel paging request for data at address 0x0000003c
> Faulting instruction address: 0xc0344ffc
> Oops: Kernel access of bad area, sig: 11 [#5]
> PowerMac
> Modules linked in: sch_sfq cls_u32 sch_cbq xt_recent xt_length iptable_mangle
> NIP: c0344ffc LR: c0335b00 CTR: c03357b0
> REGS: cb453dd0 TRAP: 0300   Tainted: G      D     (2.6.32.66)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 44244488  XER: 20000000
> DAR: 0000003c, DSISR: 40000000
> TASK = ef3c6400[21740] 'smtpd' THREAD: cb452000
> GPR00: cb614600 cb453e80 ef3c6400 e397e100 00000009 e3a24d00 00000003 00000000 
> GPR08: 00000000 00000020 01afffff e397e178 24244482 2066c198 1ffe32b4 2050e898 
> GPR16: 2050e878 2050e7e0 2050e858 2050e7e0 2050e7e0 205243b0 20524060 bfa601a0 
> GPR24: bfa60190 2089feb0 bfa60190 00000000 00000000 e397e164 cb614620 e397e100 
> NIP [c0344ffc] tcp_send_fin+0x48/0x21c
> LR [c0335b00] tcp_close+0x350/0x3fc
> Call Trace:
> [cb453e80] [00000004] 0x4 (unreliable)
> [cb453ea0] [c0335b00] tcp_close+0x350/0x3fc
> [cb453ec0] [c035733c] inet_release+0x58/0x88
> [cb453ed0] [c02e1fe8] sock_release+0x34/0xa8
> [cb453ee0] [c02e2078] sock_close+0x1c/0x40
> [cb453ef0] [c009cddc] __fput+0xf4/0x22c
> [cb453f10] [c0098ea4] filp_close+0x64/0xa0
> [cb453f30] [c0098f7c] sys_close+0x9c/0xc0
> [cb453f40] [c0012988] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0x20219780
>     LR = 0x204fcc48
> Instruction dump:
> 90010024 93c10018 83dd0004 7f9df000 419e0080 2f9e0000 419e007c 80030104 
> 2f800000 419e0180 39200020 3bde0020 <8809001c> 60000001 9809001c 813e0014 
> ---[ end trace 13772745934a0d23 ]---
> Unable to handle kernel paging request for data at address 0x0000003c
> Faulting instruction address: 0xc0344ffc
> Oops: Kernel access of bad area, sig: 11 [#6]
> PowerMac
> Modules linked in: sch_sfq cls_u32 sch_cbq xt_recent xt_length iptable_mangle
> NIP: c0344ffc LR: c0335b00 CTR: c02e2bfc
> REGS: cb6b3dd0 TRAP: 0300   Tainted: G      D     (2.6.32.66)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 44244488  XER: 20000000
> DAR: 0000003c, DSISR: 40000000
> TASK = ef3c6d00[23828] 'smtpd' THREAD: cb6b2000
> GPR00: cb661300 cb6b3e80 ef3c6d00 cb698c60 00000009 e380b180 c02e9058 00000000 
> GPR08: cb698cb8 00000020 00000000 cb698cd8 24244482 2026d198 1fbe42b4 2010f898 
> GPR16: 2010f878 2010f7e0 2010f858 2010f7e0 2010f7e0 201253b0 20125060 bf879000 
> GPR24: bf878ff0 20625eb0 bf878ff0 00000000 00000000 cb698cc4 cb661320 cb698c60 
> NIP [c0344ffc] tcp_send_fin+0x48/0x21c
> LR [c0335b00] tcp_close+0x350/0x3fc
> Call Trace:
> [cb6b3e80] [c0097398] kmem_cache_free+0x90/0x9c (unreliable)
> [cb6b3ea0] [c0335b00] tcp_close+0x350/0x3fc
> [cb6b3ec0] [c035733c] inet_release+0x58/0x88
> [cb6b3ed0] [c02e1fe8] sock_release+0x34/0xa8
> [cb6b3ee0] [c02e2078] sock_close+0x1c/0x40
> [cb6b3ef0] [c009cddc] __fput+0xf4/0x22c
> [cb6b3f10] [c0098ea4] filp_close+0x64/0xa0
> [cb6b3f30] [c0098f7c] sys_close+0x9c/0xc0
> [cb6b3f40] [c0012988] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0x1fe1a780
>     LR = 0x200fdc48
> Instruction dump:
> 90010024 93c10018 83dd0004 7f9df000 419e0080 2f9e0000 419e007c 80030104 
> 2f800000 419e0180 39200020 3bde0020 <8809001c> 60000001 9809001c 813e0014 
> ---[ end trace 13772745934a0d24 ]---
> Unable to handle kernel paging request for data at address 0x0000003c
> Faulting instruction address: 0xc0344ffc
> Oops: Kernel access of bad area, sig: 11 [#7]
> PowerMac
> Modules linked in: sch_sfq cls_u32 sch_cbq xt_recent xt_length iptable_mangle
> NIP: c0344ffc LR: c0335b00 CTR: c03357b0
> REGS: cb617d60 TRAP: 0300   Tainted: G      D     (2.6.32.66)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 42004288  XER: 20000000
> DAR: 0000003c, DSISR: 40000000
> TASK = ef3c4000[1947] 'ipop3d' THREAD: cb616000
> GPR00: cb696600 cb617e10 ef3c4000 cb698000 00000009 ef29f800 00000003 00000000 
> GPR08: 00000000 00000020 00000000 cb698078 22004282 1001de08 10015e48 10015e54 
> GPR16: 10015e48 55665804 100054bc 10015e1c 10015e0c 10005330 10015e10 00000003 
> GPR24: 10015e18 10005310 00000000 00000000 00000000 cb698064 cb696620 cb698000 
> NIP [c0344ffc] tcp_send_fin+0x48/0x21c
> LR [c0335b00] tcp_close+0x350/0x3fc
> Call Trace:
> [cb617e10] [10005330] 0x10005330 (unreliable)
> [cb617e30] [c0335b00] tcp_close+0x350/0x3fc
> [cb617e50] [c035733c] inet_release+0x58/0x88
> [cb617e60] [c02e1fe8] sock_release+0x34/0xa8
> [cb617e70] [c02e2078] sock_close+0x1c/0x40
> [cb617e80] [c009cddc] __fput+0xf4/0x22c
> [cb617ea0] [c0098ea4] filp_close+0x64/0xa0
> [cb617ec0] [c00318e0] put_files_struct+0x108/0x124
> [cb617ee0] [c0033824] do_exit+0x4fc/0x630
> [cb617f20] [c003399c] do_group_exit+0x44/0xa4
> [cb617f30] [c0033a10] sys_exit_group+0x14/0x28
> [cb617f40] [c0012988] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0xfd96f38
>     LR = 0xfd96f04
> Instruction dump:
> 90010024 93c10018 83dd0004 7f9df000 419e0080 2f9e0000 419e007c 80030104 
> 2f800000 419e0180 39200020 3bde0020 <8809001c> 60000001 9809001c 813e0014 
> ---[ end trace 13772745934a0d25 ]---
> Fixing recursive fault but reboot is needed!
> Unable to handle kernel paging request for data at address 0x0000003c
> Faulting instruction address: 0xc0344ffc
> Oops: Kernel access of bad area, sig: 11 [#8]
> PowerMac
> Modules linked in: sch_sfq cls_u32 sch_cbq xt_recent xt_length iptable_mangle
> NIP: c0344ffc LR: c0335b00 CTR: c03357b0
> REGS: cb471d60 TRAP: 0300   Tainted: G      D     (2.6.32.66)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 42004288  XER: 20000000
> DAR: 0000003c, DSISR: 40000000
> TASK = ef3c7a80[1949] 'ipop3d' THREAD: cb470000
> GPR00: cb696900 cb471e10 ef3c7a80 cb69a100 00000009 e391c080 00000003 00000000 
> GPR08: 00000000 00000020 00000000 cb69a178 22004282 1001de08 10015e48 10015e54 
> GPR16: 10015e48 55665805 100054bc 10015e1c 10015e0c 10005330 10015e10 00000003 
> GPR24: 10015e18 10005310 00000000 00000000 00000000 cb69a164 cb696920 cb69a100 
> NIP [c0344ffc] tcp_send_fin+0x48/0x21c
> LR [c0335b00] tcp_close+0x350/0x3fc
> Call Trace:
> [cb471e10] [10005330] 0x10005330 (unreliable)
> [cb471e30] [c0335b00] tcp_close+0x350/0x3fc
> [cb471e50] [c035733c] inet_release+0x58/0x88
> [cb471e60] [c02e1fe8] sock_release+0x34/0xa8
> [cb471e70] [c02e2078] sock_close+0x1c/0x40
> [cb471e80] [c009cddc] __fput+0xf4/0x22c
> [cb471ea0] [c0098ea4] filp_close+0x64/0xa0
> [cb471ec0] [c00318e0] put_files_struct+0x108/0x124
> [cb471ee0] [c0033824] do_exit+0x4fc/0x630
> [cb471f20] [c003399c] do_group_exit+0x44/0xa4
> [cb471f30] [c0033a10] sys_exit_group+0x14/0x28
> [cb471f40] [c0012988] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0xfd96f38
>     LR = 0xfd96f04
> Instruction dump:
> 90010024 93c10018 83dd0004 7f9df000 419e0080 2f9e0000 419e007c 80030104 
> 2f800000 419e0180 39200020 3bde0020 <8809001c> 60000001 9809001c 813e0014 
> ---[ end trace 13772745934a0d26 ]---
> Fixing recursive fault but reboot is needed!
> Unable to handle kernel paging request for data at address 0x0000003c
> Faulting instruction address: 0xc0344ffc
> Oops: Kernel access of bad area, sig: 11 [#9]
> PowerMac
> Modules linked in: sch_sfq cls_u32 sch_cbq xt_recent xt_length iptable_mangle
> NIP: c0344ffc LR: c0335b00 CTR: c03357b0
> REGS: cb497d60 TRAP: 0300   Tainted: G      D     (2.6.32.66)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 42004288  XER: 20000000
> DAR: 0000003c, DSISR: 40000000
> TASK = ef3c4d80[1951] 'ipop3d' THREAD: cb496000
> GPR00: cb661c00 cb497e10 ef3c4d80 cb69a940 00000009 e3904880 00000003 00000000 
> GPR08: 00000000 00000020 00000000 cb69a9b8 22004282 1001de08 10015e48 10015e54 
> GPR16: 10015e48 55665807 100054bc 10015e1c 10015e0c 10005330 10015e10 00000003 
> GPR24: 10015e18 10005310 00000000 00000000 00000000 cb69a9a4 cb661c20 cb69a940 
> NIP [c0344ffc] tcp_send_fin+0x48/0x21c
> LR [c0335b00] tcp_close+0x350/0x3fc
> Call Trace:
> [cb497e10] [10005330] 0x10005330 (unreliable)
> [cb497e30] [c0335b00] tcp_close+0x350/0x3fc
> [cb497e50] [c035733c] inet_release+0x58/0x88
> [cb497e60] [c02e1fe8] sock_release+0x34/0xa8
> [cb497e70] [c02e2078] sock_close+0x1c/0x40
> [cb497e80] [c009cddc] __fput+0xf4/0x22c
> [cb497ea0] [c0098ea4] filp_close+0x64/0xa0
> [cb497ec0] [c00318e0] put_files_struct+0x108/0x124
> [cb497ee0] [c0033824] do_exit+0x4fc/0x630
> [cb497f20] [c003399c] do_group_exit+0x44/0xa4
> [cb497f30] [c0033a10] sys_exit_group+0x14/0x28
> [cb497f40] [c0012988] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0xfd96f38
>     LR = 0xfd96f04
> Instruction dump:
> 90010024 93c10018 83dd0004 7f9df000 419e0080 2f9e0000 419e007c 80030104 
> 2f800000 419e0180 39200020 3bde0020 <8809001c> 60000001 9809001c 813e0014 
> ---[ end trace 13772745934a0d27 ]---
> Fixing recursive fault but reboot is needed!
> Unable to handle kernel paging request for data at address 0x0000003c
> Faulting instruction address: 0xc0344ffc
> Oops: Kernel access of bad area, sig: 11 [#10]
> PowerMac
> Modules linked in: sch_sfq cls_u32 sch_cbq xt_recent xt_length iptable_mangle
> NIP: c0344ffc LR: c0335b00 CTR: c03357b0
> REGS: e3b1fd60 TRAP: 0300   Tainted: G      D     (2.6.32.66)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 42004288  XER: 20000000
> DAR: 0000003c, DSISR: 40000000
> TASK = ef3c4900[1952] 'ipop3d' THREAD: e3b1e000
> GPR00: cb661900 e3b1fe10 ef3c4900 cb69b5a0 00000009 e38f6280 00000003 00000000 
> GPR08: 00000000 00000020 00000000 cb69b618 22004282 1001de08 10015e48 10015e54 
> GPR16: 10015e48 55665808 100054bc 10015e1c 10015e0c 10005330 10015e10 00000003 
> GPR24: 10015e18 10005310 00000000 00000000 00000000 cb69b604 cb661920 cb69b5a0 
> NIP [c0344ffc] tcp_send_fin+0x48/0x21c
> LR [c0335b00] tcp_close+0x350/0x3fc
> Call Trace:
> [e3b1fe10] [10005330] 0x10005330 (unreliable)
> [e3b1fe30] [c0335b00] tcp_close+0x350/0x3fc
> [e3b1fe50] [c035733c] inet_release+0x58/0x88
> [e3b1fe60] [c02e1fe8] sock_release+0x34/0xa8
> [e3b1fe70] [c02e2078] sock_close+0x1c/0x40
> [e3b1fe80] [c009cddc] __fput+0xf4/0x22c
> [e3b1fea0] [c0098ea4] filp_close+0x64/0xa0
> [e3b1fec0] [c00318e0] put_files_struct+0x108/0x124
> [e3b1fee0] [c0033824] do_exit+0x4fc/0x630
> [e3b1ff20] [c003399c] do_group_exit+0x44/0xa4
> [e3b1ff30] [c0033a10] sys_exit_group+0x14/0x28
> [e3b1ff40] [c0012988] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0xfd96f38
>     LR = 0xfd96f04
> Instruction dump:
> 90010024 93c10018 83dd0004 7f9df000 419e0080 2f9e0000 419e007c 80030104 
> 2f800000 419e0180 39200020 3bde0020 <8809001c> 60000001 9809001c 813e0014 
> ---[ end trace 13772745934a0d28 ]---
> Fixing recursive fault but reboot is needed!
> Unable to handle kernel paging request for data at address 0x0000003c
> Faulting instruction address: 0xc0344ffc
> Oops: Kernel access of bad area, sig: 11 [#11]
> PowerMac
> Modules linked in: sch_sfq cls_u32 sch_cbq xt_recent xt_length iptable_mangle
> NIP: c0344ffc LR: c0335b00 CTR: c02e2bfc
> REGS: e3a47dd0 TRAP: 0300   Tainted: G      D     (2.6.32.66)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 44244488  XER: 20000000
> DAR: 0000003c, DSISR: 40000000
> TASK = e39f3a80[2290] 'smtpd' THREAD: e3a46000
> GPR00: cb482600 e3a47e80 e39f3a80 cb69a520 00000009 ef242f00 c02e9058 00000000 
> GPR08: cb69a578 00000020 0000001b cb69a598 24244482 201cd198 1fb442b4 2006f898 
> GPR16: 2006f878 2006f7e0 2006f858 2006f7e0 2006f7e0 200853b0 20085060 bff82240 
> GPR24: bff82230 205bceb0 bff82230 00000000 00000000 cb69a584 cb482620 cb69a520 
> NIP [c0344ffc] tcp_send_fin+0x48/0x21c
> LR [c0335b00] tcp_close+0x350/0x3fc
> Call Trace:
> [e3a47e80] [c0097398] kmem_cache_free+0x90/0x9c (unreliable)
> [e3a47ea0] [c0335b00] tcp_close+0x350/0x3fc
> [e3a47ec0] [c035733c] inet_release+0x58/0x88
> [e3a47ed0] [c02e1fe8] sock_release+0x34/0xa8
> [e3a47ee0] [c02e2078] sock_close+0x1c/0x40
> [e3a47ef0] [c009cddc] __fput+0xf4/0x22c
> [e3a47f10] [c0098ea4] filp_close+0x64/0xa0
> [e3a47f30] [c0098f7c] sys_close+0x9c/0xc0
> [e3a47f40] [c0012988] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0x1fd7a780
>     LR = 0x2005dc48
> Instruction dump:
> 90010024 93c10018 83dd0004 7f9df000 419e0080 2f9e0000 419e007c 80030104 
> 2f800000 419e0180 39200020 3bde0020 <8809001c> 60000001 9809001c 813e0014 
> ---[ end trace 13772745934a0d29 ]---
> 
> 
> Here's the disassembly of the beginning of tcp_send_fin, with the offending
> instruction:
> 
> (gdb) disassemble tcp_send_fin
> Dump of assembler code for function tcp_send_fin:
> 0xc0344fb4 <tcp_send_fin+0>:    stwu    r1,-32(r1)
> 0xc0344fb8 <tcp_send_fin+4>:    mflr    r0
> 0xc0344fbc <tcp_send_fin+8>:    stw     r29,20(r1)
> 0xc0344fc0 <tcp_send_fin+12>:    addi    r29,r3,100
> 0xc0344fc4 <tcp_send_fin+16>:    stw     r31,28(r1)
> 0xc0344fc8 <tcp_send_fin+20>:    mr      r31,r3
> 0xc0344fcc <tcp_send_fin+24>:    stw     r0,36(r1)
> 0xc0344fd0 <tcp_send_fin+28>:    stw     r30,24(r1)
> 0xc0344fd4 <tcp_send_fin+32>:    lwz     r30,4(r29)
> 0xc0344fd8 <tcp_send_fin+36>:    cmpw    cr7,r29,r30
> 0xc0344fdc <tcp_send_fin+40>:    beq     cr7,0xc034505c <tcp_send_fin+168>
> 0xc0344fe0 <tcp_send_fin+44>:    cmpwi   cr7,r30,0
> 0xc0344fe4 <tcp_send_fin+48>:    beq     cr7,0xc0345060 <tcp_send_fin+172>
> 0xc0344fe8 <tcp_send_fin+52>:    lwz     r0,260(r3)
> 0xc0344fec <tcp_send_fin+56>:    cmpwi   cr7,r0,0
> 0xc0344ff0 <tcp_send_fin+60>:    beq     cr7,0xc0345170 <tcp_send_fin+444>
> 0xc0344ff4 <tcp_send_fin+64>:    li      r9,32
> 0xc0344ff8 <tcp_send_fin+68>:    addi    r30,r30,32
> 0xc0344ffc <tcp_send_fin+72>:    lbz     r0,28(r9)
> 0xc0345000 <tcp_send_fin+76>:    ori     r0,r0,1
> 0xc0345004 <tcp_send_fin+80>:    stb     r0,28(r9)
> 0xc0345008 <tcp_send_fin+84>:    lwz     r9,20(r30)
> 0xc034500c <tcp_send_fin+88>:    addi    r0,r9,1
> 0xc0345010 <tcp_send_fin+92>:    stw     r0,20(r30)
> 
> HTH
> 


I guess a backport went wrong.

Willy, please add following to your tree :

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5339f066234b..d1e2895bb63c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2136,7 +2136,7 @@ void tcp_send_fin(struct sock *sk)
 	 */
 	if (tskb && (tcp_send_head(sk) || tcp_memory_pressure)) {
 coalesce:
-		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_FIN;
+		TCP_SKB_CB(tskb)->flags |= TCPCB_FLAG_FIN;
 		TCP_SKB_CB(tskb)->end_seq++;
 		tp->write_seq++;
 	if (!tcp_send_head(sk)) {
