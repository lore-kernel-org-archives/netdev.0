From: Ben Greear <greearb@candelatech.com>
Subject: Cannot connect to netlink socket??
Date: Fri, 17 Jul 2015 14:29:19 -0700
Message-ID: <55A973AF.8090400@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:39137 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbbGQV3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 17:29:20 -0400
Received: from [192.168.100.236] (firewall.candelatech.com [50.251.239.81])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id 442FF40A5C4
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 14:29:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any idea what can cause this?  The system was working fine earlier,
so it is compiled with netlink support, etc.

Last thing someone did was to add 258 mac-vlans on top of
an ethernet port.  Removing macvlan module did not improve
things.

'ifconfig -a' works fine.

This is on a 4.0.4 (+ local hacks) kernel, nothing overly weird in dmesg, and no
new dmesg info when this fails to work:

strace ip addr show

...

socket(PF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, NETLINK_ROUTE) = 3
setsockopt(3, SOL_SOCKET, SO_SNDBUF, [32768], 4) = 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [1048576], 4) = 0
bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
getsockname(3, {sa_family=AF_NETLINK, pid=16631, groups=00000000}, [12]) = 0
sendto(3, "(\0\0\0\22\0\1\3%m\251U\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 40, 0, NULL, 0) = -1 ECONNREFUSED (Connection refused)
dup(2)                                  = 4
fcntl(4, F_GETFL)                       = 0x8002 (flags O_RDWR|O_LARGEFILE)
brk(0)                                  = 0x1679000
brk(0x169a000)                          = 0x169a000
brk(0)                                  = 0x169a000
fstat(4, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 3), ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb40d3c9000
write(4, "Cannot send dump request: Connec"..., 45Cannot send dump request: Connection refused
) = 45
close(4)                                = 0
munmap(0x7fb40d3c9000, 4096)            = 0
exit_group(1)                           = ?
+++ exited with 1 +++



A reboot 'fixed' things, and we have not been able to reproduce the
problem.


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
