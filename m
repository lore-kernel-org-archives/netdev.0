From: Ben Greear <greearb@candelatech.com>
Subject: TCP connection stops after high load.
Date: Wed, 11 Apr 2007 11:50:18 -0700
Message-ID: <461D2DEA.4010806@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:40754 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932081AbXDKSuT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 14:50:19 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l3BIoIUH008926
	for <netdev@vger.kernel.org>; Wed, 11 Apr 2007 11:50:18 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Back in May of last year, I reported this problem, but worked
around it at the time by changing the kernel memory settings
in the networking stack.  I reproduced the problem again today
with the previously working kernel memory settings..which is not
supprising since I just papered over the bug last time.

The problem is that I set up a TCP connection with bi-directional traffic
of around 800Mbps, doing large (20k - 64k writes and reads) between two ports on
the same machine (this 2.6.18.2 kernel is tainted with my full patch set,
but I also reproduced with only the non-tainted send-to-self patch applied
last may on the 2.6.16 kernel, so I assume the bug is not particular to my patch
set).

At first, all is well, but within 5-10 minutes, the TCP connection will stall
and I only see a massive amount of duplicate ACKs on the link.  Before,
I sometimes saw OOM messages, but this time there are no OOM messages.  The system
has a two-port pro/1000 fibre NIC, 1GB RAM, kernel 2.6.18.2 + hacks, etc.
Stopping and starting the connection allows traffic to flow again (if briefly).
Starting a new connection works fine even if the old one is still stalled,
so it's not a global memory exhaustion problem.

So, I would like to dig into this problem myself since no one else
is reporting this type of problem, but I am quite ignorant of the TCP
stack implementation.  Based on the dup-acks I see on the wire, I assume
the TCP state machine is messed up somehow.  Could anyone point me to
likely places in the TCP stack to start looking for this bug?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

