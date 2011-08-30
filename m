From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 42012] New: regression on 2.6.39.3 with socket/bind; still
 there in 3.0.4
Date: Tue, 30 Aug 2011 08:47:42 -0700
Message-ID: <20110830084742.26c72c20@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47869 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755210Ab1H3PsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 11:48:19 -0400
Received: from nehalam.ftrdhcpuser.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p7UFlT5b016539
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 08:47:31 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interesting? Does the kernel ABI include supporting buggy old proprietary
programs?

Begin forwarded message:

Date: Tue, 30 Aug 2011 02:59:32 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 42012] New: regression on 2.6.39.3 with socket/bind; still there in 3.0.4


https://bugzilla.kernel.org/show_bug.cgi?id=42012

           Summary: regression on 2.6.39.3 with socket/bind; still there
                    in 3.0.4
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.39.3 - 3.0.4
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: r_meier@freenet.de
        Regression: Yes


Hi,

the regression has been introduced in 2.6.39.3 with commit
d0733d2e29b652b2e7b1438ececa732e4eed98eb. I experience this with a proprietary
binary program. So I cant give you the source code which fails. This program
used to work before but fails after applying this patch. As far as I understand
the programm is using this code for ipc communication. I have recorded the
strace output of the relevant part of the program.
strace without d0733d2e29b652b2e7b1438ececa732e4eed98eb on kernel 2.6.39.2
---------------
2056  socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 4
2056  bind(4, {sa_family=AF_UNSPEC, sa_data="\0\0\0\0\0\0\0\0\0\0\0\0\0\0"},
16) = 0
2056  getsockname(4, {sa_family=AF_INET, sin_port=htons(33537),
sin_addr=inet_addr("0.0.0.0")}, [16]) = 0
2056  listen(4, 5)                      = 0
2056  setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) = 0
---------------

strace with d0733d2e29b652b2e7b1438ececa732e4eed98eb on kernel 2.6.39.2
---------------
6190  socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 4
6190  bind(4, {sa_family=AF_UNSPEC, sa_data="\0\0\0\0\0\0\0\0\0\0\0\0\0\0"},
16) = -1 EINVAL (Invalid argument)
6190  dup(2)                            = 11
6190  fcntl64(11, F_GETFL)              = 0x8002 (flags O_RDWR|O_LARGEFILE)
6190  fstat64(11, {st_mode=S_IFCHR|0600, st_rdev=makedev(136, 3), ...}) = 0
6190  mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0)
= 0x576ac000
6190  _llseek(11, 0, 0xffa03de4, SEEK_CUR) = -1 ESPIPE (Illegal seek)
6190  write(11, "ERROR: Failed to bind to interne"..., 66) = 66
6190  close(11)                         = 0
---------------

Btw, i have not enough knowledge on this topic to decide whether its the
programs fault or the kernels fault. The binary program is sybyl8.1 from
tripos.

Best regards, Rene

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
