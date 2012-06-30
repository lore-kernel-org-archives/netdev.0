From: Andreas Henriksson <andreas@fatal.se>
Subject: problems with iproute2 m_xt again...
Date: Sat, 30 Jun 2012 14:09:39 +0200
Message-ID: <20120630120939.GA18134@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	YANG Zhe <yangzhe1990@gmail.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b22.telenor.se ([195.54.99.213]:49193 "EHLO
	smtprelay-b22.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754489Ab2F3MD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 08:03:56 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-b22.telenor.se (Postfix) with ESMTP id 6BA41EB4FF
	for <netdev@vger.kernel.org>; Sat, 30 Jun 2012 14:03:54 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Mailing you in hope that you could help out with the xt module of iproute2 tc
once more, as you've done in the past.... It seems to be broken again. sigh.

amd64:~# iptables -nL | grep test
Chain test (0 references)
amd64:~# tc filter add dev fon parent ffff: protocol ip prio 10 u32 action xt -j test
 failed to find target test

bad action parsing
parse_action: bad value (3:xt)!
Illegal "action"
amd64:~#


And maybe even more interesting is when I try to use a built-in chain like DROP:

amd64:~# tc filter add dev fon parent ffff: protocol ip prio 10 u32 action xt -j DROP
tablename: mangle hook: NF_IP_PRE_ROUTING
Segmentation fault
amd64:~# 




(gdb) set args filter add dev fon parent ffff: protocol ip prio 10 u32 action xt -j DROP
(gdb) run
Starting program: /home/gem/opt/pkg-iproute/iproute/tc/tc filter add dev fon parent ffff: protocol ip prio 10 u32 action xt -j DROP
tablename: mangle hook: NF_IP_PRE_ROUTING

Program received signal SIGSEGV, Segmentation fault.
0x0000000000000000 in ?? ()
(gdb) bt
Starting program: tc filter add dev fon parent ffff: protocol ip prio 10 u32 action xt -j DROP
tablename: mangle hook: NF_IP_PRE_ROUTING

Program received signal SIGSEGV, Segmentation fault.
0x0000000000000000 in ?? ()
(gdb) bt
#0  0x0000000000000000 in ?? ()
#1  0x00007ffff71b87a0 in parse_ipt (a=0x7ffff73b9500, argc_p=0x7fffffff9e94, 
    argv_p=0x7fffffff9e88, tca_id=2, n=0x7fffffffa840) at m_xt.c:230
#2  0x000000000040dc11 in parse_action (argc_p=0x7fffffff9eec, 
    argv_p=0x7fffffff9ee0, tca_id=7, n=0x7fffffffa840) at m_action.c:214
#3  0x000000000042177e in u32_parse_opt (qu=0x648c80, handle=0x0, argc=3, 
    argv=0x7fffffffea50, n=0x7fffffffa840) at f_u32.c:1126
#4  0x0000000000409bf8 in tc_filter_modify (cmd=44, flags=1536, argc=4, 
    argv=0x7fffffffea48) at tc_filter.c:142
#5  0x000000000040a620 in do_filter (argc=14, argv=0x7fffffffe9f8)
    at tc_filter.c:357
#6  0x0000000000406c74 in do_cmd (argc=15, argv=0x7fffffffe9f0) at tc.c:199
#7  0x00000000004071ae in main (argc=16, argv=0x7fffffffe9e8) at tc.c:316


This is with the iproute package version 20120521-3 on Debian unstable.
Did I screw anything up? Did I use the wrong commands? Or are things just
broken again?

Btw. I have iptables package version 1.4.14-2

-- 
Andreas Henriksson
