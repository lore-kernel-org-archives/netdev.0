From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 73011] New: Kernel Panic
Date: Thu, 27 Mar 2014 09:01:44 -0700
Message-ID: <20140327090144.32409a75@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:41805 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086AbaC0QBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:01:48 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so3559707pdj.20
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 09:01:47 -0700 (PDT)
Received: from samsung-9 ([12.232.193.53])
        by mx.google.com with ESMTPSA id id10sm10706256pbc.35.2014.03.27.09.01.46
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Mar 2014 09:01:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 27 Mar 2014 03:15:20 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 73011] New: Kernel Panic


https://bugzilla.kernel.org/show_bug.cgi?id=73011

            Bug ID: 73011
           Summary: Kernel Panic
           Product: Networking
           Version: 2.5
    Kernel Version: 3.4
          Hardware: ARM
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: vijayborqs1982@gmail.com
        Regression: No

Unable to handle kernel NULL pointer dereference at virtual address 000000c8
pgd = ec990000
[000000c8] *pgd=00000000
Internal error: Oops: 5 [#1] PREEMPT SMP ARM
CPU: 1    Tainted: G        W     (3.4.0-liberty)
PC is at __ip_route_output_key+0x49c/0x798
LR is at inet_select_addr+0xf8/0x104
pc : <c0709654>    lr : <c0735fc4>    psr: 20030013
sp : eca97c28  ip : 00000001  fp : 012ba8c0
r10: 00000000  r9 : 00000000  r8 : c11dcd00
r7 : 00000000  r6 : 00000000  r5 : 00000000  r4 : eca97cd4
r3 : ebe22100  r2 : ec0c0000  r1 : c11dccd8  r0 : 00000000
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 10c5787d  Table: ad39006a  DAC: 00000015
..
Faulting Process ping (pid: 6719, stack limit = 0xeca962f0)
...
Call Stack
Kernel Panic in this func   __ip_route_output_key()  
                ====>ip_route_output_flow()
                  ===>ping_v4_sendmsg()
                    ===>inet_sendmsg()
                       ===>sock_sendmsg()
                              ===>__sys_sendmsg()
                         ===>sys_sendmsg()
kernel/net/ipv4/route.c
***********************
    dev_out = FIB_RES_DEV(res);
    fl4->flowi4_oif = dev_out->ifindex;
***********************
dev_out looks like  NULL. When dev_out is accessed it is resulting in NULL Ptr
Def and finally Kernel Panic.


Any experts who can fix this issue. It is very rarely reproduced on ARM 32-bit
ARCH.

-- 
You are receiving this mail because:
You are the assignee for the bug.
