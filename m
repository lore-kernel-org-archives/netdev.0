From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 80201] New: general protection fault: 0000 [#1] SMP (while
 using HTB)
Date: Mon, 14 Jul 2014 08:47:33 -0700
Message-ID: <20140714084733.0b4aeeef@haswell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:43129 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755828AbaGNPrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 11:47:31 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so4243668pab.20
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 08:47:31 -0700 (PDT)
Received: from haswell (static-50-53-66-61.bvtn.or.frontiernet.net. [50.53.66.61])
        by mx.google.com with ESMTPSA id q7sm14989816pdm.17.2014.07.14.08.47.30
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 08:47:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 14 Jul 2014 04:12:45 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 80201] New: general protection fault: 0000 [#1] SMP (while using HTB)


https://bugzilla.kernel.org/show_bug.cgi?id=80201

            Bug ID: 80201
           Summary: general protection fault: 0000 [#1] SMP (while using
                    HTB)
           Product: Networking
           Version: 2.5
    Kernel Version: Linux 3.10.41-1.el6.elrepo.x86_64
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: cenek.zach@gmail.com
        Regression: No

Created attachment 142971
  --> https://bugzilla.kernel.org/attachment.cgi?id=142971&action=edit
Kernel GPF stack trace

Encountered GPF under normal circumstances - no heavy load (CPU, IO, net). 

HTB configuration is very simple: 1 HTB class with SFQ qdisc and filter on
source port 80:

tc qdisc add dev eth0 root handle 1: htb default 30
tc class add dev eth0 parent 1: classid 1:1 htb rate $LIMIT burst 1500k cburst
1500k
tc qdisc add dev eth0 parent 1:1 handle 10: sfq perturb 10
tc filter add dev eth0 protocol ip parent 1:0 prio 1 u32 match ip sport 80
0xffff flowid 1:1

Relevant part of vmcore-dmesg.txt attached.

-- 
You are receiving this mail because:
You are the assignee for the bug.
