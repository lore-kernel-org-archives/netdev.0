From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 45681] New: no network to ip phones
Date: Sat, 11 Aug 2012 11:06:23 -0700
Message-ID: <20120811110623.1d23c93e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59485 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258Ab2HKSGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Aug 2012 14:06:34 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 16402141056E
	for <netdev@vger.kernel.org>; Sat, 11 Aug 2012 11:06:31 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1fUP5-vV-reY for <netdev@vger.kernel.org>;
	Sat, 11 Aug 2012 11:06:28 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id AEEB51410136
	for <netdev@vger.kernel.org>; Sat, 11 Aug 2012 11:06:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue,  7 Aug 2012 05:02:58 +0000 (UTC)
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 45681] New: no network to ip phones


https://bugzilla.kernel.org/show_bug.cgi?id=45681

           Summary: no network to ip phones
           Product: Networking
           Version: 2.5
    Kernel Version: 3.0.39
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: slesru@gmail.com
        Regression: No


Hello!

I run asterisk on x86 server , with kernel 2.6.39 all is OK, but with 3.0.38
and 3.0.39 after some time server lost connections to sip phones:

[Aug 2 15:02:51] WARNING[5790]: chan_sip.c:3392 __sip_xmit: sip_xmit of
0x9bd88f8 (len 548) to 192.168.26.116:5060 returned -2: Network is down

ping says the same, but other hosts work OK (from any other networks), only sip
phones are affected.

interfaces:

[root@asterisk ~]# ifconfig
eth0 Link encap:Ethernet HWaddr 00:30:48:85:5B:0A
          inet addr:192.168.22.19 Bcast:192.168.22.255 Mask:255.255.255.0
          inet6 addr: fe80::230:48ff:fe85:5b0a/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
          RX packets:61867 errors:0 dropped:666 overruns:0 frame:0
          TX packets:25992 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:7013187 (6.6 MiB) TX bytes:3754003 (3.5 MiB)

eth0.9 Link encap:Ethernet HWaddr 00:30:48:85:5B:0A
          inet addr:192.168.42.132 Bcast:192.168.42.255 Mask:255.255.255.128
          inet6 addr: fe80::230:48ff:fe85:5b0a/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
          RX packets:11634 errors:0 dropped:0 overruns:0 frame:0
          TX packets:10753 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2407018 (2.2 MiB) TX bytes:2439435 (2.3 MiB)


default gateway is on eth0, i.e. not tagged.

hardware:
[root@asterisk ~]# /sbin/lspci -nn | grep -i net
01:01.0 Ethernet controller [0200]: Intel Corporation 82547GI Gigabit Ethernet
Controller [8086:1075]
02:01.0 Ethernet controller [0200]: Digium, Inc. Wildcard TE122 single-span
T1/E1/J1 card [d161:8001] (rev 11)
03:0a.0 Ethernet controller [0200]: Intel Corporation 82541GI Gigabit Ethernet
Controller [8086:1076]

I use elrepo kernel build, here is there bug report:

http://elrepo.org/bugs/view.php?id=294

I have no idea what can cause this problem :-(

Thank you!

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
