From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: ping -I eth1 ....
Date: Fri, 5 Nov 2010 14:14:01 +0100
Message-ID: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:42766 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089Ab0KENYC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Nov 2010 09:24:02 -0400
Received: from sesr04.transmode.se (sesr04.transmode.se [192.168.201.15])
	by gw1.transmode.se (Postfix) with ESMTP id 91A772597D6
	for <netdev@vger.kernel.org>; Fri,  5 Nov 2010 14:14:03 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If I do busybox ping -I eth1 x.x.y.y i see
socket(PF_INET, SOCK_RAW, IPPROTO_ICMP) = 3
getuid()                                = 0
setuid(0)                               = 0
setsockopt(3, SOL_SOCKET, SO_BINDTODEVICE, "eth1\0\0\0\0\0\0\0\0\0\0\0\0\20\0[l\0\0\0\2\20\7\354(\0"..., 32) = 0
setsockopt(3, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [7280], 4) = 0

......
then this in a loop:
--- SIGALRM (Alarm clock) @ 0 (0) ---
clock_gettime(CLOCK_MONOTONIC, {1238, 116470107}) = 0
sendto(3, "\10\0\203\345\1\326\0\2I\314(v\0\0\0\0\0\0\0\0\0\0\0\0"..., 64, 0, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("1.1.1.1")}, 16) = 64
rt_sigaction(SIGALRM, {0x10017034, [ALRM], SA_RESTART}, {0x10017034, [ALRM], SA_RESTART}, 8) = 0
alarm(1)                                = 0
sigreturn()                             = ? (mask now [ILL ABRT FPE KILL ALRM STKFLT CONT STOP TTOU URG XCPU XFSZ VTALRM PROF WINCH IO PWR RTMIN])
recvfrom(3, 0xbfe6a620, 192, 0, 0xbfe6a6f0, 0xbfe6a70c) = ? ERESTARTSYS (To be restarted)

Then I do ifconfig eth1 down
and I still see the same. Should not
sendto and/or revcfrom return some error as
the interface is down?

kernel 2.6.35

    Jocke

