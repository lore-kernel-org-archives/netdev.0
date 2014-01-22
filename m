From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 69231] New: tc class overhead is displayed incorrectly
Date: Wed, 22 Jan 2014 15:46:20 -0800
Message-ID: <20140122154620.68d25d64@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:48746 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539AbaAVXqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 18:46:24 -0500
Received: by mail-pa0-f42.google.com with SMTP id kl14so1071659pab.29
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 15:46:24 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id qz9sm28322877pbc.3.2014.01.22.15.46.23
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 15:46:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Begin forwarded message:

Date: Wed, 22 Jan 2014 06:57:49 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 69231] New: tc class overhead is displayed incorrectly


https://bugzilla.kernel.org/show_bug.cgi?id=69231

            Bug ID: 69231
           Summary: tc class overhead is displayed incorrectly
           Product: Networking
           Version: 2.5
    Kernel Version: 3.13
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: gabriel.zigelboim.work@gmail.com
        Regression: No

Configuring HTB to do shaping for 3000kb/s with 4 bytes overhead. Test shows
shaping is done correctly (exact amount of bytes are received including CFS)
however when checking TC configuration $overhead$ value is displayed
incorrectly showing configuration of 0 bytes
. 
Enter the following commands:
sudo  tc qdisc add dev eth1 root handle 1: htb default 10
sudo  tc class add dev eth1 parent 1: classid 1:10 htb rate 3000kbit burst
10000 cburst 10000 overhead 4
sudo  tc qdisc add dev eth1 parent 1:10 handle 10:0 pfifo limit 10
tc -s -d class show dev eth1

Result:
class htb 1:10 root leaf 10: prio 0 quantum 37500 rate 3000Kbit ceil 3000Kbit
burst 9999b/1 mpu 0b overhead 0b cburst 9999b/1 mpu 0b overhead 0b level 0
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: 416656 ctokens: 416656

uname -a
Linux cto-linux-11 3.13.0-031300-generic #201401192235 SMP Mon Jan 20 03:36:48
UTC 2014 x86_64 x86_64 x86_64 GNU/Linux
