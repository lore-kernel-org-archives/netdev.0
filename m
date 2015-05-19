From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: stack smashing in iproute/ip
Date: Tue, 19 May 2015 06:25:39 -0700
Message-ID: <1432041939.621.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <555AF73C.7050405@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jetchko Jekov <jetchko.jekov@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37336 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078AbbESNZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 09:25:42 -0400
Received: by igbsb11 with SMTP id sb11so13725638igb.0
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 06:25:41 -0700 (PDT)
In-Reply-To: <555AF73C.7050405@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-19 at 10:41 +0200, Jetchko Jekov wrote:
> Hello,
> 
> I hope this is the right way to report a bug regarding iproute.
> 
> While playing with gre[tap] tunnels I run in the following:
> 
> # modprobe ip-gre
> # ip l add gre1 type gre remote 1.1.1.1
> # ip l change gre1 type gre remote 1.1.1.2
> addattr_l ERROR: message exceeded bound of 1024
> addattr_l ERROR: message exceeded bound of 1024
> addattr_l ERROR: message exceeded bound of 1024
> addattr_l ERROR: message exceeded bound of 1024
> addattr_l ERROR: message exceeded bound of 1024
> addattr_l ERROR: message exceeded bound of 1024
> addattr_l ERROR: message exceeded bound of 1024
> addattr_l ERROR: message exceeded bound of 1024
> *** stack smashing detected ***: ip terminated
> ======= Backtrace: =========
> /lib64/libc.so.6[0x3754a77d9e]
> /lib64/libc.so.6(__fortify_fail+0x37)[0x3754b11db7]
> /lib64/libc.so.6(__fortify_fail+0x0)[0x3754b11d80]
> ip[0x429511]
> ======= Memory map: ========
> 00400000-0044b000 r-xp 00000000 fd:00 660285                             
> /usr/sbin/ip
> 0064a000-0064b000 r--p 0004a000 fd:00 660285                             
> /usr/sbin/ip
> 0064b000-0064f000 rw-p 0004b000 fd:00 660285                             
> /usr/sbin/ip
> 0064f000-00655000 rw-p 00000000 00:00 0
> 0084e000-00850000 rw-p 0004e000 fd:00 660285                             
> /usr/sbin/ip
> 013c4000-013e5000 rw-p 00000000 00:00 0                                  
> [heap]
> 3754600000-3754621000 r-xp 00000000 fd:00 664653                         
> /usr/lib64/ld-2.20.so
> 3754821000-3754822000 r--p 00021000 fd:00 664653                         
> /usr/lib64/ld-2.20.so
> 3754822000-3754823000 rw-p 00022000 fd:00 664653                         
> /usr/lib64/ld-2.20.so
> 3754823000-3754824000 rw-p 00000000 00:00 0
> 3754a00000-3754bb3000 r-xp 00000000 fd:00 672328                         
> /usr/lib64/libc-2.20.so
> 3754bb3000-3754db3000 ---p 001b3000 fd:00 672328                         
> /usr/lib64/libc-2.20.so
> 3754db3000-3754db7000 r--p 001b3000 fd:00 672328                         
> /usr/lib64/libc-2.20.so
> 3754db7000-3754db9000 rw-p 001b7000 fd:00 672328                         
> /usr/lib64/libc-2.20.so
> 3754db9000-3754dbd000 rw-p 00000000 00:00 0
> 3754e00000-3754e03000 r-xp 00000000 fd:00 672374                         
> /usr/lib64/libdl-2.20.so
> 3754e03000-3755002000 ---p 00003000 fd:00 672374                         
> /usr/lib64/libdl-2.20.so
> 3755002000-3755003000 r--p 00002000 fd:00 672374                         
> /usr/lib64/libdl-2.20.so
> 3755003000-3755004000 rw-p 00003000 fd:00 672374                         
> /usr/lib64/libdl-2.20.so
> 3757200000-3757216000 r-xp 00000000 fd:00 672379 
> /usr/lib64/libgcc_s-4.9.2-20150212.so.1
> 3757216000-3757415000 ---p 00016000 fd:00 672379 
> /usr/lib64/libgcc_s-4.9.2-20150212.so.1
> 3757415000-3757416000 r--p 00015000 fd:00 672379 
> /usr/lib64/libgcc_s-4.9.2-20150212.so.1
> 3757416000-3757417000 rw-p 00016000 fd:00 672379 
> /usr/lib64/libgcc_s-4.9.2-20150212.so.1
> 7f7724882000-7f7724885000 rw-p 00000000 00:00 0
> 7f77248b4000-7f77248b6000 rw-p 00000000 00:00 0
> 7ffeccd59000-7ffeccd7a000 rw-p 00000000 00:00 0                          
> [stack]
> 7ffeccd99000-7ffeccd9b000 r--p 00000000 00:00 0                          
> [vvar]
> 7ffeccd9b000-7ffeccd9d000 r-xp 00000000 00:00 0                          
> [vdso]
> ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  
> [vsyscall]
> Aborted (core dumped)
> 
> OS: Fedora 213.19.7-200.fc21.x86_64
> Kernel: 3.19.7-200.fc21.x86_64
> iproute-3.16.0-3.fc21.x86_64
> # ip -V
> ip utility, iproute2-ss140804
> 
> I reproduced the same behavior with the latest git kernel available in 
> Gentoo ( 4.1.0-rc3 ) and iproute2 compiled from git
> # ip -V
> ip utility, iproute2-ss150413
> 
> This time rung from gdb with debug info:
> 
> Program received signal SIGABRT, Aborted.
> 0x00007ffff7874e77 in __GI_raise (sig=sig@entry=6) at 
> ../sysdeps/unix/sysv/linux/raise.c:55
> 55      ../sysdeps/unix/sysv/linux/raise.c: No such file or directory.
> (gdb) bt
> #0  0x00007ffff7874e77 in __GI_raise (sig=sig@entry=6) at 
> ../sysdeps/unix/sysv/linux/raise.c:55
> #1  0x00007ffff787627a in __GI_abort () at abort.c:89
> #2  0x00007ffff78b2d24 in __libc_message (do_abort=do_abort@entry=2, 
> fmt=fmt@entry=0x7ffff79a1320 "*** %s ***: %s terminated\n")
>      at ../sysdeps/posix/libc_fatal.c:175
> #3  0x00007ffff7937a67 in __GI___fortify_fail 
> (msg=msg@entry=0x7ffff79a1308 "stack smashing detected") at 
> fortify_fail.c:31
> #4  0x00007ffff7937a30 in __stack_chk_fail () at stack_chk_fail.c:28
> #5  0x000000000042c487 in gre_parse_opt (lu=<optimized out>, argc=0, 
> argv=0x7fffffffe388, n=0x7fffffffdc80) at link_gre.c:330
> #6  0x0000000000000000 in ?? ()
> 
> I tried to investigate further:
> stack corruption happens on call to rtnl_talk on line 87 in ip/link_gre.c
>      87:   if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0)
> 
> looking at  rtnl_talk in lib/libnetlink.c, I found that actual 
> corruption happens on  memcpy  call (line 401) which copies message with 
> length of 1288 in that specific example into a buffer on the stack with 
> not enough space (the struct at *answer  which is defined at 
> ip/link_gre.c as struct req  is just 1024+10+16, I believe)
> I see that in lib/libnetlink.c netlink msg buffer is 16k but in 
> gre_parse_opt it is defined as just 1k. Raising it to 16k fixes that 
> particular stack smash, but I am not familiar with the internals there 
> and I dont know is that correct fix.
> Actually I am not sure is that valid command at all, the corresponding 
> man pages are slightly(?) outdated.
> 
> Best regards
> Jeka
> 
> P.S. I am not subscribed to this mailing list so please CC me on replies.

Yes, this is a long standing problem in rtnl_talk() api has no max
length given for the answer.

:(
