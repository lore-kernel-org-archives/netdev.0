From: Grant Wilson <grant.wilson@zen.co.uk>
Subject: Re: 2.6.24-rc1-gb4f5550 oops
Date: Thu, 8 Nov 2007 17:22:13 +0000
Message-ID: <20071108172213.2b3b8ffd@worthy.swandive.local>
References: <20071105061158.3174d24d@worthy.swandive.local>
	<200711080106.21580.rjw@sisk.pl>
	<20071108062250.02479c0c@worthy.swandive.local>
	<200711081653.11226.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythagoras.zen.co.uk ([212.23.3.140]:55475 "EHLO
	pythagoras.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759924AbXKHRWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 12:22:21 -0500
In-Reply-To: <200711081653.11226.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Nov 2007 16:53:10 +0100
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> On Thursday, 8 of November 2007, Grant Wilson wrote:
> > On Thu, 8 Nov 2007 01:06:21 +0100
> > "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > 
> > > On Monday, 5 of November 2007, Grant Wilson wrote:
> > > > Hi,
> > > > I got this oops on 2.6.24-rc1-641-gb4f5550:
> > > 
> > > (1) Is this reproducible?
> > > (2) Did it happen previously on your system?
> > >
> > > [18073.371126] Unable to handle kernel NULL pointer dereference at 0000000000000120 RIP: 
> > > [18073.371134]  [<ffffffff8023572e>] check_preempt_wakeup+0x6e/0x110
> > 
> > This has now happened twice - the second time was last night when
> > running 2.6.24-rc2.
> > 
> > Here's that second occurrence:
> > 
[snip]
> 
> Hmm.
> 
> Please run "gdb vmlinux" and see what code corresponds to
> check_preempt_wakeup+0x6e in your kernel.

Dump of assembler code for function check_preempt_wakeup:
0xffffffff80232940 <check_preempt_wakeup+0>:    push   %rbp
0xffffffff80232941 <check_preempt_wakeup+1>:    mov    %rsp,%rbp
0xffffffff80232944 <check_preempt_wakeup+4>:    sub    $0x30,%rsp
0xffffffff80232948 <check_preempt_wakeup+8>:    mov    %r13,-0x18(%rbp)
0xffffffff8023294c <check_preempt_wakeup+12>:   mov    %rbx,-0x28(%rbp)
0xffffffff80232950 <check_preempt_wakeup+16>:   mov    %rsi,%r13
0xffffffff80232953 <check_preempt_wakeup+19>:   mov    %r12,-0x20(%rbp)
0xffffffff80232957 <check_preempt_wakeup+23>:   mov    %r14,-0x10(%rbp)
0xffffffff8023295b <check_preempt_wakeup+27>:   mov    %r15,-0x8(%rbp)
0xffffffff8023295f <check_preempt_wakeup+31>:   cmpl   $0x63,0x20(%rsi)
0xffffffff80232963 <check_preempt_wakeup+35>:   mov    0x750(%rdi),%r14
0xffffffff8023296a <check_preempt_wakeup+42>:   mov    0x168(%r14),%r12
0xffffffff80232971 <check_preempt_wakeup+49>:   jle    0xffffffff80232a1c <check_preempt_wakeup+220>
0xffffffff80232977 <check_preempt_wakeup+55>:   cmpl   $0x3,0x17c(%rsi)
0xffffffff8023297e <check_preempt_wakeup+62>:   je     0xffffffff802329f8 <check_preempt_wakeup+184>
0xffffffff80232980 <check_preempt_wakeup+64>:   testb  $0x10,0x593cb9(%rip)        # 0xffffffff807c6640 <sysctl_sched_features>
0xffffffff80232987 <check_preempt_wakeup+71>:   je     0xffffffff802329f8 <check_preempt_wakeup+184>
0xffffffff80232989 <check_preempt_wakeup+73>:   cmp    0x168(%rsi),%r12
0xffffffff80232990 <check_preempt_wakeup+80>:   lea    0x48(%r14),%rbx
0xffffffff80232994 <check_preempt_wakeup+84>:   lea    0x48(%rsi),%rax
0xffffffff80232998 <check_preempt_wakeup+88>:   je     0xffffffff802329be <check_preempt_wakeup+126>
0xffffffff8023299a <check_preempt_wakeup+90>:   nopw   0x0(%rax,%rax,1)
0xffffffff802329a0 <check_preempt_wakeup+96>:   mov    0x118(%rbx),%rbx
0xffffffff802329a7 <check_preempt_wakeup+103>:  mov    0x118(%rax),%rax
0xffffffff802329ae <check_preempt_wakeup+110>:  mov    0x120(%rax),%rdx
0xffffffff802329b5 <check_preempt_wakeup+117>:  cmp    %rdx,0x120(%rbx)
0xffffffff802329bc <check_preempt_wakeup+124>:  jne    0xffffffff802329a0 <check_preempt_wakeup+96>
0xffffffff802329be <check_preempt_wakeup+126>:  cmpq   $0x400,(%rbx)
0xffffffff802329c5 <check_preempt_wakeup+133>:  mov    0x40(%rbx),%r12
0xffffffff802329c9 <check_preempt_wakeup+137>:  mov    0x40(%rax),%r15
0xffffffff802329cd <check_preempt_wakeup+141>:  mov    0x593c81(%rip),%edi        # 0xffffffff807c6654 <sysctl_sched_wakeup_granularity>
0xffffffff802329d3 <check_preempt_wakeup+147>:  jne    0xffffffff80232a37 <check_preempt_wakeup+247>
0xffffffff802329d5 <check_preempt_wakeup+149>:  sub    %r15,%r12
0xffffffff802329d8 <check_preempt_wakeup+152>:  cmp    %r12,%rdi
0xffffffff802329db <check_preempt_wakeup+155>:  jge    0xffffffff802329f8 <check_preempt_wakeup+184>
0xffffffff802329dd <check_preempt_wakeup+157>:  testb  $0x20,0x593c5c(%rip)        # 0xffffffff807c6640 <sysctl_sched_features>

Cheers,
Grant
-- 
Running Linux 2.6.24-rc2 on x86_64
