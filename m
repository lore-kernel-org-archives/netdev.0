From: "walter schloegl" <sctp@muskelshirt.de>
Subject: Re: sctp panic
Date: Fri, 18 Mar 2011 09:30:06 +0100
Message-ID: <20110318083006.161490@gmx.net>
References: <20110317074356.231320@gmx.net>
	<AANLkTim2cggAu6o7iU74S47xyFfOqrSiUPOfo+2XoidB@mail.gmail.com>
	<20110317104903.153050@gmx.net>
 <AANLkTi=yN2MtaOwUQsKmYaYxfkc0+mKtZiDeJ=r-KACK@mail.gmail.com>
 <4D82DA2D.1020503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>, richard.weinberger@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D82DA2D.1020503@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


-------- Original-Nachricht --------
> Datum: Fri, 18 Mar 2011 12:06:05 +0800
> Von: Wei Yongjun <yjwei@cn.fujitsu.com>
> An: richard -rw- weinberger <richard.weinberger@gmail.com>
> CC: walter schloegl <sctp@muskelshirt.de>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
> Betreff: Re: sctp panic

> 
> 
> > On Thu, Mar 17, 2011 at 11:49 AM, walter schloegl <sctp@muskelshirt.de>
> wrote:
> >> -------- Original-Nachricht --------
> >>> Datum: Thu, 17 Mar 2011 08:56:47 +0100
> >>> Von: richard -rw- weinberger <richard.weinberger@gmail.com>
> >>> An: sctp@muskelshirt.de
> >>> CC: linux-kernel@vger.kernel.org
> >>> Betreff: Re: sctp panic
> >>> On Thu, Mar 17, 2011 at 8:43 AM,  <sctp@muskelshirt.de> wrote:
> >>>> Hi
> >>>>
> >>>> when doing the actions below I get a panic.
> >>>>
> >>>> - echo 1 > /proc/sys/net/sctp/addip_enable
> >>>> - In a C-Programm
> >>>>    - socket(AF_INET,SOCK_STREAM,IPPROTO_SCTP);
> >>>>    - connect(....)     (with correct filled parameters)
> >>>>
> >>>> Its no process (waiting in accept) neccessary
> >>> Can you show us the panic message and your C prorgam?
> >>> This would help reproducing the panic...
> >> ...snip...
> >>
> >> The crash says:
> >>
> >> crash> bt
> >> PID: 14646  TASK: ffff8801f40c7560  CPU: 9   COMMAND: "x"
> >>  #0 [ffff8801f6f5f6f0] machine_kexec at ffffffff8103697b
> >>  #1 [ffff8801f6f5f750] crash_kexec at ffffffff810b9078
> >>  #2 [ffff8801f6f5f820] oops_end at ffffffff814cc900
> >>  #3 [ffff8801f6f5f850] die at ffffffff8101733b
> >>  #4 [ffff8801f6f5f880] do_trap at ffffffff814cc1d4
> >>  #5 [ffff8801f6f5f8e0] do_invalid_op at ffffffff81014ee5
> >>  #6 [ffff8801f6f5f980] invalid_op at ffffffff81013f5b
> >>    [exception RIP: skb_over_panic+93]
> >>    RIP: ffffffff81404bdd  RSP: ffff8801f6f5fa38  RFLAGS: 00010296
> >>    RAX: 0000000000000083  RBX: 0000000000000040  RCX: 00000000000013f6
> >>    RDX: 0000000000000000  RSI: 0000000000000046  RDI: 0000000000000246
> >>    RBP: ffff8801f6f5fa58   R8: ffffffff818a3da0   R9: 0000000000000000
> >>    R10: 0000000000000001  R11: 0000000000000000  R12: ffff8801f4e11000
> >>    R13: 0000000000000004  R14: 000000000000003e  R15: 0000000000000001
> >>    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
> >>  #7 [ffff8801f6f5fa60] skb_put at ffffffff81405c1c
> >>  #8 [ffff8801f6f5fa80] sctp_addto_chunk at ffffffffa0503c23
> >>  #9 [ffff8801f6f5fad0] sctp_make_init at ffffffffa0506705
> >> #10 [ffff8801f6f5fba0] sctp_sf_do_prm_asoc at ffffffffa04f81d4
> >> #11 [ffff8801f6f5fbd0] sctp_do_sm at ffffffffa04fd381
> >> #12 [ffff8801f6f5fd60] sctp_primitive_ASSOCIATE at ffffffffa0513daf
> >> #13 [ffff8801f6f5fd80] __sctp_connect at ffffffffa0510f09
> >> #14 [ffff8801f6f5fe50] sctp_connect at ffffffffa0511248
> >> #15 [ffff8801f6f5fe80] inet_dgram_connect at ffffffff81471b6c
> >> #16 [ffff8801f6f5feb0] sys_connect at ffffffff813ff747
> >> #17 [ffff8801f6f5ff80] system_call_fastpath at ffffffff81013172
> >>    RIP: 0000003015ee2150  RSP: 00007fffea7bdce8  RFLAGS: 00010206
> >>    RAX: 000000000000002a  RBX: ffffffff81013172  RCX: 0000000000000000
> >>    RDX: 0000000000000010  RSI: 00007fffea7bdd00  RDI: 0000000000000003
> >>    RBP: 00007fffea7bdd40   R8: 0000000000759020   R9: ff00000000000000
> >>    R10: 00007fffea7bda70  R11: 0000000000000246  R12: 0000000000000000
> >>    R13: 00007fffea7bde20  R14: 00000000004006e0  R15: 0000000000000000
> >>    ORIG_RAX: 000000000000002a  CS: 0033  SS: 002b
> >>
> >>
> >>
> 
> Are you using old kernel? If it is, the following patch may fixed this
> issue.
> 
> http://git.kernel.org/?p=linux/kernel/git/vxy/lksctp-dev.git;a=commitdiff;h=a8170c35e738d62e9919ce5b109cf4ed66e95bde;hp=81419d862db743fe4450a021893f24bab4698c1d
> 
I am using:
Red Hat Enterprise Linux Server release 6.0 (Santiago)
2.6.32-71.18.1.el6.x86_64 #1 SMP Wed Feb 2 17:49:59 EST 2011 x86_64 x86_64 x86_64 GNU/Linux

> >>>> br
> >>>> walter
> >>>> --
> >>>> GMX DSL Doppel-Flat ab 19,99 Euro/mtl.! Jetzt mit
> >>>> gratis Handy-Flat! http://portal.gmx.net/de/go/dsl
> >>>> --
> >>>> To unsubscribe from this list: send the line "unsubscribe
> linux-kernel"
> >>> in
> >>>> the body of a message to majordomo@vger.kernel.org
> >>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>> Please read the FAQ at  http://www.tux.org/lkml/
> >>>>
> >>> --
> >>> Thanks,
> >>> //richard
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe
> linux-kernel" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>> Please read the FAQ at  http://www.tux.org/lkml/
> >> --
> >> NEU: FreePhone - kostenlos mobil telefonieren und surfen!
> >> Jetzt informieren: http://www.gmx.net/de/go/freephone
> >>
> > CC'ing netdev
> >
> 

-- 
NEU: FreePhone - kostenlos mobil telefonieren und surfen!			
Jetzt informieren: http://www.gmx.net/de/go/freephone
